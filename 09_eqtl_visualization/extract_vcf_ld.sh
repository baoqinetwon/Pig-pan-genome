#!/usr/bin/env bash
# Extract regional VCF and calculate local LD for eQTL visualization.
# Adapt region, VCF, and output paths before running.
set -euo pipefail

VCF=${VCF:-genotype.vcf.gz}
REGION=${REGION:-chr1:1000000-2000000}
OUT_PREFIX=${OUT_PREFIX:-region_eqtl}
THREADS=${THREADS:-8}

bcftools view \
    --threads ${THREADS} \
    -r ${REGION} \
    -Oz \
    -o ${OUT_PREFIX}.region.vcf.gz \
    ${VCF}

tabix -p vcf -f ${OUT_PREFIX}.region.vcf.gz

plink --vcf ${OUT_PREFIX}.region.vcf.gz \
    --double-id \
    --allow-extra-chr \
    --r2 gz \
    --ld-window 99999 \
    --ld-window-kb 1000 \
    --ld-window-r2 0 \
    --out ${OUT_PREFIX}.ld
