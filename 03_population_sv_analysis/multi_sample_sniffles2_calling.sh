#!/usr/bin/env bash
# Multi-sample SV calling using Sniffles2.
# Adapt BAM list, reference, sample names, and output directory before running.
set -euo pipefail

BAM_LIST=${BAM_LIST:-bam.list}
OUTDIR=${OUTDIR:-sniffles2_multisample}
THREADS=${THREADS:-16}

mkdir -p ${OUTDIR}/single_sample ${OUTDIR}/population

# Generate per-sample SNF files.
while read -r sample bam; do
    sniffles \
        --input ${bam} \
        --snf ${OUTDIR}/single_sample/${sample}.snf \
        --threads ${THREADS} \
        --sample-id ${sample}
done < ${BAM_LIST}

ls ${OUTDIR}/single_sample/*.snf > ${OUTDIR}/snf.list

# Joint calling.
sniffles \
    --input ${OUTDIR}/snf.list \
    --vcf ${OUTDIR}/population/population.sv.vcf \
    --threads ${THREADS}

bgzip -@ ${THREADS} -f ${OUTDIR}/population/population.sv.vcf
tabix -p vcf -f ${OUTDIR}/population/population.sv.vcf.gz
