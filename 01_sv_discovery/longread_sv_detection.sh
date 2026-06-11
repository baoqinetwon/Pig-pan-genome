#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# SV detection for individual public PacBio long-read samples
# ============================================================
# This script is used for read-based SV discovery from individual
# PacBio long-read datasets downloaded from published studies or
# public repositories.
#
# Different from population-scale ONT multi-sample calling, this
# workflow processes each downloaded PacBio sample separately.
# It assumes that the reads have already been aligned to the
# reference genome and that sorted BAM files are provided.
#
# SV callers included:
#   - Sniffles2
#   - cuteSV
#   - pbsv
#   - SVIM
#
# Input BAM list format:
#   sample_id    path/to/sample.sorted.bam
#
# Example:
#   PacBio01     01_bam/PacBio01.sorted.bam

BAM_LIST=${BAM_LIST:-bam.list}
REF=${REF:-/path/to/reference.fa}
OUTDIR=${OUTDIR:-longread_sv_calls}
THREADS=${THREADS:-16}

mkdir -p ${OUTDIR}/{sniffles2,cutesv,pbsv,svim}

while read -r sample bam
 do
    echo "Calling SVs for ${sample} from ${bam}"

    # ------------------------------------------------------------
    # 1. Sniffles2
    # ------------------------------------------------------------
    sniffles \
        --input ${bam} \
        --vcf ${OUTDIR}/sniffles2/${sample}.sniffles2.vcf \
        --threads ${THREADS} \
        --sample-id ${sample}

    # ------------------------------------------------------------
    # 2. cuteSV
    # ------------------------------------------------------------
    cuteSV \
        ${bam} \
        ${REF} \
        ${OUTDIR}/cutesv/${sample}.cutesv.vcf \
        ${OUTDIR}/cutesv/${sample}.workdir \
        --threads ${THREADS} \
        --sample ${sample}

    # ------------------------------------------------------------
    # 3. pbsv
    # ------------------------------------------------------------
    pbsv discover \
        ${bam} \
        ${OUTDIR}/pbsv/${sample}.svsig.gz

    pbsv call \
        ${REF} \
        ${OUTDIR}/pbsv/${sample}.svsig.gz \
        ${OUTDIR}/pbsv/${sample}.pbsv.vcf

    # ------------------------------------------------------------
    # 4. SVIM
    # ------------------------------------------------------------
    svim alignment \
        ${OUTDIR}/svim/${sample} \
        ${bam} \
        ${REF}
 done < ${BAM_LIST}
