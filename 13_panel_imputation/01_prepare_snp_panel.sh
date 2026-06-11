#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 01_prepare_snp_panel.sh
# Merge SNP VCFs and perform sample-level QC for PGVRP
# ============================================================

THREADS=20

# Input SNP VCFs from different cohorts
SNP_VCFS=(
    cohort1.snps.vcf.gz
    cohort2.snps.vcf.gz
    cohort3.snps.vcf.gz
    cohort4.snps.vcf.gz
    cohort5.snps.vcf.gz
)

HEADER=header.txt
OUT_PREFIX=PGVRP.genome.snps

mkdir -p 01_snp_qc

# 1. Merge SNP VCFs
bcftools merge --threads ${THREADS} \
    "${SNP_VCFS[@]}" \
    -Oz -o 01_snp_qc/${OUT_PREFIX}.vcf.gz

tabix -p vcf 01_snp_qc/${OUT_PREFIX}.vcf.gz

# 2. Reheader merged SNP VCF
bcftools reheader \
    -h ${HEADER} \
    01_snp_qc/${OUT_PREFIX}.vcf.gz \
    -o 01_snp_qc/${OUT_PREFIX}.reheadered.vcf.gz

tabix -p vcf 01_snp_qc/${OUT_PREFIX}.reheadered.vcf.gz

# 3. Convert to PLINK format for sample QC
plink \
    --vcf 01_snp_qc/${OUT_PREFIX}.reheadered.vcf.gz \
    --vcf-half-call m \
    --allow-extra-chr \
    --double-id \
    --make-bed \
    --out 01_snp_qc/${OUT_PREFIX} \
    --threads ${THREADS}

# 4. Calculate heterozygosity and pairwise relatedness
plink \
    --bfile 01_snp_qc/${OUT_PREFIX} \
    --allow-extra-chr \
    --het \
    --out 01_snp_qc/${OUT_PREFIX}.het \
    --threads ${THREADS}

plink \
    --bfile 01_snp_qc/${OUT_PREFIX} \
    --genome \
    --out 01_snp_qc/${OUT_PREFIX}.ibd \
    --threads ${THREADS}

# Manual / downstream step:
# Remove samples with abnormal heterozygosity, high relatedness, and no overlap with SV samples.
# Final sample list:
#   PGVRP_panel.sample.sorted.txt
