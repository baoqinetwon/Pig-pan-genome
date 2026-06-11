#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 04_phase_reference_panel.sh
# Phase and self-impute chromosome-level SNP-SV panel
# ============================================================

THREADS=20
MEM=190g
BEAGLE=/path/to/beagle.jar

HEADER=header_panel_2337.txt
INDIR=03_chr_snp_sv
OUTDIR=04_phased_reference_panel

mkdir -p ${OUTDIR}

for CHR in {1..18}
do
    echo "Phasing chromosome ${CHR}"

    # 1. Phase and self-impute SNP-SV panel
    java -Xmx${MEM} -jar ${BEAGLE} \
        gt=${INDIR}/panel_2337.chr${CHR}.snp.sv.sorted.vcf.gz \
        out=${OUTDIR}/panel_2337.chr${CHR}.snp.sv.phased \
        impute=true \
        window=4.0 \
        ne=100 \
        nthreads=${THREADS}

    # 2. Reheader phased VCF
    bcftools reheader \
        -h ${HEADER} \
        ${OUTDIR}/panel_2337.chr${CHR}.snp.sv.phased.vcf.gz \
        -o ${OUTDIR}/panel_2337.chr${CHR}.snp.sv.phased.reheadered.vcf.gz

    tabix -p vcf ${OUTDIR}/panel_2337.chr${CHR}.snp.sv.phased.reheadered.vcf.gz

    # 3. Extract and filter phased SNPs
    bcftools view \
        --threads ${THREADS} \
        -v snps \
        ${OUTDIR}/panel_2337.chr${CHR}.snp.sv.phased.reheadered.vcf.gz \
        -Oz -o ${OUTDIR}/panel_2337.chr${CHR}.snp.phased.vcf.gz

    vcftools \
        --gzvcf ${OUTDIR}/panel_2337.chr${CHR}.snp.phased.vcf.gz \
        --min-alleles 2 \
        --max-alleles 2 \
        --max-missing 0.9 \
        --maf 0.01 \
        --recode \
        --recode-INFO-all \
        --out ${OUTDIR}/panel_2337.chr${CHR}.snp.phased.filtered

    bgzip -f ${OUTDIR}/panel_2337.chr${CHR}.snp.phased.filtered.recode.vcf
    tabix -p vcf ${OUTDIR}/panel_2337.chr${CHR}.snp.phased.filtered.recode.vcf.gz

    # 4. Extract phased SVs
    bcftools view \
        --threads ${THREADS} \
        -V snps \
        ${OUTDIR}/panel_2337.chr${CHR}.snp.sv.phased.reheadered.vcf.gz \
        -Oz -o ${OUTDIR}/panel_2337.chr${CHR}.sv.phased.vcf.gz

    tabix -p vcf ${OUTDIR}/panel_2337.chr${CHR}.sv.phased.vcf.gz

    # 5. Merge filtered phased SNPs and phased SVs as final reference panel
    bcftools concat \
        --threads ${THREADS} \
        -a -d snps \
        ${OUTDIR}/panel_2337.chr${CHR}.snp.phased.filtered.recode.vcf.gz \
        ${OUTDIR}/panel_2337.chr${CHR}.sv.phased.vcf.gz \
        -Oz -o ${OUTDIR}/panel_2337.chr${CHR}.snp.sv.phased.merged.vcf.gz

    bcftools sort \
        ${OUTDIR}/panel_2337.chr${CHR}.snp.sv.phased.merged.vcf.gz \
        -Oz -o ${OUTDIR}/panel_2337.chr${CHR}.snp.sv.phased.final.vcf.gz

    tabix -p vcf ${OUTDIR}/panel_2337.chr${CHR}.snp.sv.phased.final.vcf.gz
done
