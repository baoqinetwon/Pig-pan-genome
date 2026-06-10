#!/usr/bin/env bash
# Long-read SNP/Indel detection workflow.
# Adapt BAM list, reference genome, and output directory before running.
set -euo pipefail

BAM_LIST=${BAM_LIST:-bam.list}
REF=${REF:-/path/to/reference.fa}
OUTDIR=${OUTDIR:-longread_snp_indel}
THREADS=${THREADS:-16}

mkdir -p ${OUTDIR}

while read -r sample bam; do
  bcftools mpileup \
    --threads ${THREADS} \
    -Ou \
    -f ${REF} \
    ${bam} \
  | bcftools call \
    --threads ${THREADS} \
    -mv -Oz \
    -o ${OUTDIR}/${sample}.snp_indel.vcf.gz

  tabix -p vcf -f ${OUTDIR}/${sample}.snp_indel.vcf.gz

done < ${BAM_LIST}
