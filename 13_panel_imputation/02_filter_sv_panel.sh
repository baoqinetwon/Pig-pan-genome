#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 02_filter_sv_panel.sh
# Filter SVs for reference panel construction
# ============================================================

THREADS=20

SV_RAW=panel_all3061_sv.rname2.1-18.anno.vcf.gz
SAMPLE_LIST=2337_panel.sample.sorted.txt
OUTDIR=02_sv_qc

mkdir -p ${OUTDIR}

# 1. Retain INS and DEL only
bcftools view \
    -i 'SVTYPE="INS" || SVTYPE="DEL"' \
    ${SV_RAW} \
    -Oz -o ${OUTDIR}/panel_3061.chr1-18.sv.ins.del.vcf.gz

tabix -p vcf ${OUTDIR}/panel_3061.chr1-18.sv.ins.del.vcf.gz

# 2. Filter by SV length, allele count, and final panel samples
bcftools view \
    -i 'INFO/SVLEN>=50 && INFO/SVLEN<=30000000' \
    -e 'AC==1 || AC==2' \
    -S ${SAMPLE_LIST} \
    ${OUTDIR}/panel_3061.chr1-18.sv.ins.del.vcf.gz \
    -Oz -o ${OUTDIR}/panel_2337.chr1-18.sv.filtered.vcf.gz

tabix -p vcf ${OUTDIR}/panel_2337.chr1-18.sv.filtered.vcf.gz

# 3. Retain variants with genotype missing rate <= 20%
vcftools \
    --gzvcf ${OUTDIR}/panel_2337.chr1-18.sv.filtered.vcf.gz \
    --max-missing 0.8 \
    --recode \
    --recode-INFO-all \
    --out ${OUTDIR}/panel_2337.chr1-18.sv.filtered.miss

bgzip -f ${OUTDIR}/panel_2337.chr1-18.sv.filtered.miss.recode.vcf
tabix -p vcf ${OUTDIR}/panel_2337.chr1-18.sv.filtered.miss.recode.vcf.gz

# 4. Retain biallelic SVs
bcftools view \
    -m2 -M2 \
    ${OUTDIR}/panel_2337.chr1-18.sv.filtered.miss.recode.vcf.gz \
    -Oz -o ${OUTDIR}/panel_2337.chr1-18.sv.only_bi.vcf.gz

tabix -p vcf ${OUTDIR}/panel_2337.chr1-18.sv.only_bi.vcf.gz

bcftools stats \
    ${OUTDIR}/panel_2337.chr1-18.sv.only_bi.vcf.gz \
    > ${OUTDIR}/panel_2337.chr1-18.sv.only_bi.stats.txt
