#!/usr/bin/env bash
# Genotype preprocessing for SV-eQTL mapping.
# Adapt sample lists, VCF paths, and filtering thresholds before running.
set -euo pipefail

VCF=${VCF:-graph_genotyped_sv.vcf.gz}
SAMPLES=${SAMPLES:-rna_matched_samples.txt}
OUT_PREFIX=${OUT_PREFIX:-sv_eqtl_genotype}
THREADS=${THREADS:-16}

# Keep RNA-matched individuals and biallelic SVs.
bcftools view \
    --threads ${THREADS} \
    -S ${SAMPLES} \
    -m2 -M2 \
    -Oz \
    -o ${OUT_PREFIX}.matched.biallelic.vcf.gz \
    ${VCF}

tabix -p vcf -f ${OUT_PREFIX}.matched.biallelic.vcf.gz

# Apply missingness and MAF filters.
bcftools +fill-tags ${OUT_PREFIX}.matched.biallelic.vcf.gz \
    -Oz -o ${OUT_PREFIX}.matched.biallelic.tags.vcf.gz -- -t MAF,F_MISSING

bcftools filter \
    --threads ${THREADS} \
    -i 'INFO/MAF >= 0.01 && INFO/F_MISSING <= 0.1' \
    -Oz \
    -o ${OUT_PREFIX}.filtered.vcf.gz \
    ${OUT_PREFIX}.matched.biallelic.tags.vcf.gz

tabix -p vcf -f ${OUT_PREFIX}.filtered.vcf.gz

# Export dosage/genotype matrix if required by downstream tools.
plink --vcf ${OUT_PREFIX}.filtered.vcf.gz \
    --double-id \
    --allow-extra-chr \
    --make-bed \
    --out ${OUT_PREFIX}.filtered
