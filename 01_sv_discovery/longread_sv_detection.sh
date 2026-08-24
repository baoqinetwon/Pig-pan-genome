#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# PacBio long-read SV detection
# ============================================================
# This script performs per-sample SV detection from PacBio long-read
# NGMLR alignments using multiple callers.
#
# Supported PacBio read types:
#   READ_TYPE=HIFI  : PacBio CCS/HiFi data
#   READ_TYPE=CLR   : PacBio CLR data
#
# SV callers included:
#   - pbsv
#   - Sniffles2
#   - cuteSV
#   - Debreak
#   - IRIS polishing for all four caller VCFs, optional
#   - SURVIVOR merge across callers
#
# Input BAM list format:
#   sample_id    path/to/sample.hifi.ngmlr.bam
#
# Example:
#   AW           AW.hifi.ngmlr.bam

BAM_LIST=${BAM_LIST:-bam.list}
REF=${REF:-/path/to/Duroc.fa}
OUTDIR=${OUTDIR:-pacbio_sv_calls}
THREADS=${THREADS:-56}
READ_TYPE=${READ_TYPE:-HIFI}       # HIFI or CLR
MIN_SIZE=${MIN_SIZE:-50}
MIN_SUPPORT=${MIN_SUPPORT:-10}
DEBREAK_DEPTH=${DEBREAK_DEPTH:-111}
RUN_IRIS=${RUN_IRIS:-0}            # set to 1 to polish all four caller VCFs with IRIS
RUN_SURVIVOR=${RUN_SURVIVOR:-1}    # set to 1 to merge caller VCFs with SURVIVOR

mkdir -p ${OUTDIR}/{pbsv,sniffles2,cutesv,debreak,iris,survivor,tmp}

# Platform-specific cuteSV parameters
case ${READ_TYPE} in
    HIFI|HiFi|hifi)
        PBSV_HIFI_FLAG="--hifi"
        CUTESV_INS_BIAS=1000
        CUTESV_INS_RATIO=0.9
        CUTESV_DEL_BIAS=1000
        CUTESV_DEL_RATIO=0.5
        ;;
    CLR|clr)
        PBSV_HIFI_FLAG=""
        CUTESV_INS_BIAS=100
        CUTESV_INS_RATIO=0.3
        CUTESV_DEL_BIAS=200
        CUTESV_DEL_RATIO=0.5
        ;;
    *)
        echo "ERROR: unsupported READ_TYPE=${READ_TYPE}. Use READ_TYPE=HIFI or READ_TYPE=CLR." >&2
        exit 1
        ;;
esac

while read -r sample bam
 do
    [[ -z "${sample}" || "${sample}" =~ ^# ]] && continue

    # Allow one-column BAM list. In that case infer sample name from BAM basename.
    if [[ -z "${bam:-}" ]]; then
        bam=${sample}
        file=$(basename ${bam})
        sample=${file%%.*}
    fi

    echo "Calling PacBio SVs for ${sample} from ${bam}"

    # ------------------------------------------------------------
    # 1. pbsv
    # ------------------------------------------------------------
    # Add or replace read groups before pbsv calling.

    rg_bam=${OUTDIR}/pbsv/${sample}.pbsv.bam

    gatk AddOrReplaceReadGroups \
        -I ${bam} \
        -O ${rg_bam} \
        --SORT_ORDER coordinate \
        -SM ${sample} \
        -LB library \
        -PL PACBIO \
        -PU sample

    samtools index -@ ${THREADS} ${rg_bam}

    pbsv discover \
        ${PBSV_HIFI_FLAG} \
        ${rg_bam} \
        ${OUTDIR}/pbsv/${sample}.svsig.gz

    pbsv call \
        ${PBSV_HIFI_FLAG} \
        -m ${MIN_SIZE} \
        -j ${THREADS} \
        ${REF} \
        ${OUTDIR}/pbsv/${sample}.svsig.gz \
        ${OUTDIR}/pbsv/${sample}.pbsv.vcf

    # ------------------------------------------------------------
    # 2. Sniffles2
    # ------------------------------------------------------------

    sniffles \
        -t ${THREADS} \
        --minsupport auto \
        --minsvlen ${MIN_SIZE} \
        --qc-stdev True \
        --detect-large-ins True \
        --long-dup-coverage 1.75 \
        --sample-id ${sample} \
        --input ${bam} \
        --vcf ${OUTDIR}/sniffles2/${sample}.sniffles2.vcf

    # ------------------------------------------------------------
    # 3. cuteSV
    # ------------------------------------------------------------

    cuteSV \
        ${bam} \
        ${REF} \
        ${OUTDIR}/cutesv/${sample}.cutesv.vcf \
        ${OUTDIR}/tmp/${sample}.cutesv.tmp \
        -t ${THREADS} \
        --min_size ${MIN_SIZE} \
        --min_support ${MIN_SUPPORT} \
        --max_cluster_bias_INS ${CUTESV_INS_BIAS} \
        --diff_ratio_merging_INS ${CUTESV_INS_RATIO} \
        --max_cluster_bias_DEL ${CUTESV_DEL_BIAS} \
        --diff_ratio_merging_DEL ${CUTESV_DEL_RATIO}

    # ------------------------------------------------------------
    # 4. Debreak
    # ------------------------------------------------------------

    debreak \
        --bam ${bam} \
        -o ${OUTDIR}/debreak/${sample} \
        --min_size ${MIN_SIZE} \
        --depth ${DEBREAK_DEPTH} \
        -t ${THREADS} \
        --rescue_large_ins \
        --rescue_dup \
        --poa \
        --ref ${REF}

    # ------------------------------------------------------------
    # 5. Optional IRIS polishing for all four caller VCFs
    # ------------------------------------------------------------

    debreak_vcf=$(find ${OUTDIR}/debreak/${sample} -name "*debreak_seq.vcf" | head -n 1 || true)

    caller_names=(pbsv sniffles2 cutesv debreak)
    caller_vcfs=(
        ${OUTDIR}/pbsv/${sample}.pbsv.vcf
        ${OUTDIR}/sniffles2/${sample}.sniffles2.vcf
        ${OUTDIR}/cutesv/${sample}.cutesv.vcf
        ${debreak_vcf}
    )

    if [[ ${RUN_IRIS} -eq 1 ]]; then
        for i in "${!caller_names[@]}"; do
            caller=${caller_names[${i}]}
            caller_vcf=${caller_vcfs[${i}]}
            polished_vcf=${OUTDIR}/iris/${sample}.${caller}.polished.vcf

            if [[ -n "${caller_vcf}" && -s "${caller_vcf}" ]]; then
                iris \
                    genome_in=${REF} \
                    vcf_in=${caller_vcf} \
                    reads_in=${bam} \
                    vcf_out=${polished_vcf} \
                    --pacbio \
                    --rerunracon
            else
                echo "WARNING: no ${caller} VCF found for ${sample}; skip IRIS polishing." >&2
            fi
        done
    fi

    # ------------------------------------------------------------
    # 6. SURVIVOR merge across callers
    # ------------------------------------------------------------

    if [[ ${RUN_SURVIVOR} -eq 1 ]]; then
        merge_list=${OUTDIR}/survivor/${sample}.vcf.list
        : > ${merge_list}

        for i in "${!caller_names[@]}"; do
            caller=${caller_names[${i}]}
            caller_vcf=${caller_vcfs[${i}]}
            polished_vcf=${OUTDIR}/iris/${sample}.${caller}.polished.vcf

            if [[ ${RUN_IRIS} -eq 1 && -s "${polished_vcf}" ]]; then
                echo ${polished_vcf} >> ${merge_list}
            elif [[ -n "${caller_vcf}" && -s "${caller_vcf}" ]]; then
                echo ${caller_vcf} >> ${merge_list}
            fi
        done

        SURVIVOR merge \
            ${merge_list} \
            1000 \
            2 \
            1 \
            1 \
            0 \
            ${MIN_SIZE} \
            ${OUTDIR}/survivor/${sample}.merged.vcf
    fi
 done < ${BAM_LIST}
