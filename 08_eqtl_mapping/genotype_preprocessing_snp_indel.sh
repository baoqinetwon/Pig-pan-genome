#!/usr/bin/env bash
# SNP/Indel genotype preprocessing for cis-eQTL mapping.
# Adapt sample lists, VCF paths, and filtering thresholds before running.
set -euo pipefail

VCF=${VCF:-snp_indel.genotypes.vcf.gz}
SAMPLES=${SAMPLES:-rna_matched_samples.txt}
OUT_PREFIX=${OUT_PREFIX:-snp_indel_eqtl_genotype}
THREADS=${THREADS:-16}

bcftools view \
  --threads ${THREADS} \
  -S ${SAMPLES} \
  -m2 -M2 \
  -Oz -o ${OUT_PREFIX}.matched.biallelic.vcf.gz \
  ${VCF}

tabix -p vcf -f ${OUT_PREFIX}.matched.biallelic.vcf.gz

bcftools +fill-tags ${OUT_PREFIX}.matched.biallelic.vcf.gz \
  -Oz -o ${OUT_PREFIX}.matched.biallelic.tags.vcf.gz -- -t MAF,F_MISSING

bcftools filter \
  --threads ${THREADS} \
  -i 'INFO/MAF >= 0.01 && INFO/F_MISSING <= 0.1' \
  -Oz -o ${OUT_PREFIX}.filtered.vcf.gz \
  ${OUT_PREFIX}.matched.biallelic.tags.vcf.gz

tabix -p vcf -f ${OUT_PREFIX}.filtered.vcf.gz

plink --vcf ${OUT_PREFIX}.filtered.vcf.gz \
  --double-id \
  --allow-extra-chr \
  --make-bed \
  --out ${OUT_PREFIX}.filtered
