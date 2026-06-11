#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Long-read SNP/Indel detection
# ============================================================
# Workflow:
#   PacBio HiFi:
#     1. Align HiFi reads using pbmm2 --preset HIFI
#     2. Call SNPs/Indels using DeepVariant --model_type=PACBIO
#
#   Oxford Nanopore Technologies (ONT):
#     1. Align ONT reads using minimap2 -x map-ont
#     2. Call SNPs/Indels using Clair3
#
# Set READ_TYPE=HIFI or READ_TYPE=ONT before running.

READ_TYPE=${READ_TYPE:-HIFI}      # HIFI or ONT
THREADS=${THREADS:-52}

SAMPLE=${SAMPLE:-BMA}
REF_FA=${REF_FA:-/public/home/baoqi/assembly/Duroc/Duroc.fa}
REF_MMI=${REF_MMI:-/public/home/baoqi/assembly/Duroc/Duroc.mmi}
FASTQ=${FASTQ:-BMA_hifi.fastq.gz}

BAM_DIR=${BAM_DIR:-01_bam}
VCF_DIR=${VCF_DIR:-02_variant_calling}

SINGULARITY=${SINGULARITY:-/public/software/singularity/bin/singularity}
DEEPVARIANT_SIF=${DEEPVARIANT_SIF:-/public/software/singularity/docker-images/deepvariant-gpu.1.4.0.sif}

# Clair3 settings for ONT SNP/Indel calling
CLAIR3=${CLAIR3:-run_clair3.sh}
CLAIR3_MODEL=${CLAIR3_MODEL:-/path/to/clair3/ont/model}
CLAIR3_PLATFORM=${CLAIR3_PLATFORM:-ont}

mkdir -p ${BAM_DIR} ${VCF_DIR}

case ${READ_TYPE} in

    HIFI|HiFi|hifi)
        echo "Running PacBio HiFi SNP/Indel detection for ${SAMPLE}"

        # ------------------------------------------------------------
        # 1. Align HiFi reads with pbmm2
        # ------------------------------------------------------------

        pbmm2 align \
            --preset HIFI \
            -j ${THREADS} \
            --sort \
            --sort-threads ${THREADS} \
            --sample ${SAMPLE} \
            ${REF_MMI} \
            ${FASTQ} \
            ${BAM_DIR}/${SAMPLE}_pbmm.bam

        samtools index -@ ${THREADS} ${BAM_DIR}/${SAMPLE}_pbmm.bam

        # ------------------------------------------------------------
        # 2. SNP/Indel calling with DeepVariant GPU
        # ------------------------------------------------------------
        # Use GPU by adding '--nv' to singularity exec.

        ${SINGULARITY} exec --nv --network=none -n ${DEEPVARIANT_SIF} \
            run_deepvariant \
            --model_type=PACBIO \
            --ref=${REF_FA} \
            --reads=${BAM_DIR}/${SAMPLE}_pbmm.bam \
            --output_vcf=${VCF_DIR}/${SAMPLE}.hifi.deepvariant.vcf.gz \
            --num_shards=${THREADS}
        ;;

    ONT|ont)
        echo "Running ONT SNP/Indel detection for ${SAMPLE}"

        # ------------------------------------------------------------
        # 1. Align ONT reads with minimap2
        # ------------------------------------------------------------

        minimap2 \
            -ax map-ont \
            -t ${THREADS} \
            ${REF_FA} \
            ${FASTQ} \
        | samtools sort \
            -@ ${THREADS} \
            -o ${BAM_DIR}/${SAMPLE}.ont.minimap2.bam

        samtools index -@ ${THREADS} ${BAM_DIR}/${SAMPLE}.ont.minimap2.bam

        # ------------------------------------------------------------
        # 2. SNP/Indel calling with Clair3
        # ------------------------------------------------------------

        ${CLAIR3} \
            --bam_fn=${BAM_DIR}/${SAMPLE}.ont.minimap2.bam \
            --ref_fn=${REF_FA} \
            --threads=${THREADS} \
            --platform=${CLAIR3_PLATFORM} \
            --model_path=${CLAIR3_MODEL} \
            --output=${VCF_DIR}/${SAMPLE}.ont.clair3
        ;;

    *)
        echo "ERROR: unsupported READ_TYPE=${READ_TYPE}. Use READ_TYPE=HIFI or READ_TYPE=ONT." >&2
        exit 1
        ;;
esac
