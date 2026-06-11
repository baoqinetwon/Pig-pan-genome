#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 06_extract_imputation_summary.sh
# Extract DR2, MAF, SNP/SV VCFs, and genotype matrices
# ============================================================

THREADS=10
HEADER=header.txt

INDIR=05_imputed_target
OUTDIR=06_imputation_summary
TARGET_PREFIX=chip.target

mkdir -p ${OUTDIR}

for CHR in {1..18}
do
    echo "Summarizing imputation results for chromosome ${CHR}"

    IMPUTED=${INDIR}/${TARGET_PREFIX}.PGVRP.chr${CHR}.snp.sv.imputed.vcf.gz

    # 1. Reheader and add MAF tag
    bcftools reheader \
        -h ${HEADER} \
        ${IMPUTED} \
        -o ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.snp.sv.imputed.reheadered.vcf.gz

    bcftools +fill-tags \
        ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.snp.sv.imputed.reheadered.vcf.gz \
        --threads ${THREADS} \
        -Oz -o ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.snp.sv.imputed.maf.vcf.gz \
        -- -t MAF

    tabix -p vcf ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.snp.sv.imputed.maf.vcf.gz

    # 2. Extract imputed SNPs
    bcftools view \
        --threads ${THREADS} \
        -v snps \
        ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.snp.sv.imputed.maf.vcf.gz \
        -Oz -o ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.snp.imputed.maf.vcf.gz

    tabix -p vcf ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.snp.imputed.maf.vcf.gz

    # 3. Extract imputed SVs
    bcftools view \
        --threads ${THREADS} \
        -V snps \
        ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.snp.sv.imputed.maf.vcf.gz \
        -Oz -o ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.sv.imputed.maf.vcf.gz

    tabix -p vcf ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.sv.imputed.maf.vcf.gz

    # 4. Extract DR2
    bcftools query \
        -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/DR2\t%INFO/MAF\n' \
        ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.snp.sv.imputed.maf.vcf.gz \
        > ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.snp.sv.DR2_MAF.txt

    bcftools query \
        -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/DR2\t%INFO/MAF\n' \
        ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.sv.imputed.maf.vcf.gz \
        > ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.sv.DR2_MAF.txt

    # 5. Extract genotype matrix for downstream evaluation
    bcftools query \
        -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/DR2\t%INFO/MAF[\t%GT]\n' \
        ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.sv.imputed.maf.vcf.gz \
        > ${OUTDIR}/${TARGET_PREFIX}.chr${CHR}.sv.imputed.genotypes.txt
done
