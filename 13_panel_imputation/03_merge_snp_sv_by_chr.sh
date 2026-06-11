#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 03_merge_snp_sv_by_chr.sh
# Merge chromosome-level SNP and SV VCFs for PGVRP
# ============================================================

THREADS=20
SNP_VCF=01_snp_qc/PGVRP.genome.snps.reheadered.vcf.gz
SV_VCF=02_sv_qc/PGVRP.chr1-18.sv.only_bi.vcf.gz
SAMPLE_LIST=PGVRP_panel.sample.sorted.txt
OUTDIR=03_chr_snp_sv

mkdir -p ${OUTDIR}

for CHR in {1..18}
do
    echo "Merging SNP and SV for chromosome ${CHR}"

    # Extract biallelic SNPs from PGVRP samples
    bcftools view \
        --threads ${THREADS} \
        -v snps \
        -m2 -M2 \
        -S ${SAMPLE_LIST} \
        -r ${CHR} \
        ${SNP_VCF} \
        -Oz -o ${OUTDIR}/PGVRP.chr${CHR}.snp.vcf.gz

    tabix -p vcf ${OUTDIR}/PGVRP.chr${CHR}.snp.vcf.gz

    # Extract filtered SVs
    bcftools view \
        --threads ${THREADS} \
        -r ${CHR} \
        ${SV_VCF} \
        -Oz -o ${OUTDIR}/PGVRP.chr${CHR}.sv.vcf.gz

    tabix -p vcf ${OUTDIR}/PGVRP.chr${CHR}.sv.vcf.gz

    # Merge SNP and SV VCFs
    bcftools concat \
        --threads ${THREADS} \
        -a -d snps \
        ${OUTDIR}/PGVRP.chr${CHR}.snp.vcf.gz \
        ${OUTDIR}/PGVRP.chr${CHR}.sv.vcf.gz \
        -Oz -o ${OUTDIR}/PGVRP.chr${CHR}.snp.sv.vcf.gz

    bcftools sort \
        ${OUTDIR}/PGVRP.chr${CHR}.snp.sv.vcf.gz \
        -Oz -o ${OUTDIR}/PGVRP.chr${CHR}.snp.sv.sorted.vcf.gz

    tabix -p vcf ${OUTDIR}/PGVRP.chr${CHR}.snp.sv.sorted.vcf.gz
done
