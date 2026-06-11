#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Multi-sample SV calling for population-scale ONT data
# ============================================================
# This script performs population-level SV discovery from ONT BAM files
# using Sniffles2 in two steps:
#   1. Generate one SNF file for each sample
#   2. Jointly call SVs from all SNF files
#
# Input BAM list format:
#   sample_id    path/to/sample.bam
#
# Example:
#   Duroc001     01_bam/Duroc001.ont.minimap2.bam

BAM_LIST=${BAM_LIST:-bam.list}
OUTDIR=${OUTDIR:-sniffles2_multisample}
THREADS=${THREADS:-16}

mkdir -p ${OUTDIR}/single_sample ${OUTDIR}/population

# ------------------------------------------------------------
# 1. Generate per-sample SNF files
# ------------------------------------------------------------

while read -r sample bam
 do
    echo "Generating SNF for ${sample}"

    sniffles \
        --input ${bam} \
        --snf ${OUTDIR}/single_sample/${sample}.snf \
        --threads ${THREADS} \
        --sample-id ${sample}
 done < ${BAM_LIST}

ls ${OUTDIR}/single_sample/*.snf > ${OUTDIR}/snf.list

# ------------------------------------------------------------
# 2. Joint SV calling across population ONT samples
# ------------------------------------------------------------

sniffles \
    --input ${OUTDIR}/snf.list \
    --vcf ${OUTDIR}/population/population.sv.vcf \
    --threads ${THREADS}

bgzip -@ ${THREADS} -f ${OUTDIR}/population/population.sv.vcf
tabix -p vcf -f ${OUTDIR}/population/population.sv.vcf.gz
