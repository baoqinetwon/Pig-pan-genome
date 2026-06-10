#!/usr/bin/env bash
# Basic population SV filtering workflow.
# Adapt thresholds and paths before running.
set -euo pipefail

VCF=${VCF:-population.sv.vcf.gz}
OUT_PREFIX=${OUT_PREFIX:-population.sv.filtered}
THREADS=${THREADS:-16}

# Retain PASS records when FILTER is available.
bcftools view -f PASS ${VCF} -Oz -o ${OUT_PREFIX}.pass.vcf.gz --threads ${THREADS}
tabix -p vcf -f ${OUT_PREFIX}.pass.vcf.gz

# Fill AF/MAF/AC/AN tags.
bcftools +fill-tags ${OUT_PREFIX}.pass.vcf.gz \
  -Oz -o ${OUT_PREFIX}.tags.vcf.gz -- -t AF,MAF,AC,AN

tabix -p vcf -f ${OUT_PREFIX}.tags.vcf.gz

# Example missingness and MAF filtering.
bcftools view -i 'F_MISSING < 0.2 && MAF > 0.01' \
  ${OUT_PREFIX}.tags.vcf.gz \
  -Oz -o ${OUT_PREFIX}.maf001.miss02.vcf.gz

tabix -p vcf -f ${OUT_PREFIX}.maf001.miss02.vcf.gz
