#!/usr/bin/env bash
# Calculate AF/MAF and extract frequency tables from SV VCF.
# Adapt VCF and output prefix before running.
set -euo pipefail

VCF=${VCF:-population.sv.filtered.vcf.gz}
OUT_PREFIX=${OUT_PREFIX:-population.sv.af_maf}

bcftools +fill-tags ${VCF} -Oz -o ${OUT_PREFIX}.vcf.gz -- -t AF,MAF,AC,AN
tabix -p vcf -f ${OUT_PREFIX}.vcf.gz

bcftools query -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%INFO/AC\t%INFO/AN\t%INFO/AF\t%INFO/MAF\n' \
  ${OUT_PREFIX}.vcf.gz \
  > ${OUT_PREFIX}.tsv
