#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# PanPop VCF processing before graph-based SV genotyping
# ============================================================
# This script post-processes PanPop-derived SV records and prepares
# an analysis-ready SV VCF for downstream graph-based genotyping.
#
# Main steps:
#   1. Keep target samples, if a sample list is provided
#   2. Retain INS and DEL records
#   3. Retain SVs with length >= 50 bp
#   4. Split or retain biallelic records for downstream genotyping
#   5. Keep genotype information and generate an indexed VCF
#
# Input:
#   PANPOP_VCF : raw PanPop VCF
#   SAMPLE_LIST: optional sample list; leave empty to keep all samples
#
# Output:
#   ${OUTDIR}/panpop.sv.processed.vcf.gz

THREADS=${THREADS:-16}
PANPOP_VCF=${PANPOP_VCF:-panpop.raw.vcf.gz}
SAMPLE_LIST=${SAMPLE_LIST:-}
OUTDIR=${OUTDIR:-01_panpop_processed}
MIN_SVLEN=${MIN_SVLEN:-50}

mkdir -p ${OUTDIR}

# ------------------------------------------------------------
# 1. Optional sample extraction
# ------------------------------------------------------------

if [[ -n "${SAMPLE_LIST}" ]]; then
    bcftools view \
        --threads ${THREADS} \
        -S ${SAMPLE_LIST} \
        ${PANPOP_VCF} \
        -Oz -o ${OUTDIR}/panpop.sample_subset.vcf.gz
else
    bcftools view \
        --threads ${THREADS} \
        ${PANPOP_VCF} \
        -Oz -o ${OUTDIR}/panpop.sample_subset.vcf.gz
fi

tabix -p vcf -f ${OUTDIR}/panpop.sample_subset.vcf.gz

# ------------------------------------------------------------
# 2. Retain INS/DEL SVs and length >= 50 bp
# ------------------------------------------------------------

bcftools view \
    --threads ${THREADS} \
    -i 'INFO/SVTYPE="INS" || INFO/SVTYPE="DEL"' \
    ${OUTDIR}/panpop.sample_subset.vcf.gz \
| bcftools view \
    --threads ${THREADS} \
    -i "ABS(INFO/SVLEN)>=${MIN_SVLEN}" \
    -Oz -o ${OUTDIR}/panpop.ins_del.len${MIN_SVLEN}.vcf.gz

tabix -p vcf -f ${OUTDIR}/panpop.ins_del.len${MIN_SVLEN}.vcf.gz

# ------------------------------------------------------------
# 3. Retain biallelic records for graph genotyping
# ------------------------------------------------------------

bcftools view \
    --threads ${THREADS} \
    -m2 -M2 \
    ${OUTDIR}/panpop.ins_del.len${MIN_SVLEN}.vcf.gz \
    -Oz -o ${OUTDIR}/panpop.sv.biallelic.vcf.gz

tabix -p vcf -f ${OUTDIR}/panpop.sv.biallelic.vcf.gz

# ------------------------------------------------------------
# 4. Simplify FORMAT fields and generate final processed VCF
# ------------------------------------------------------------

bcftools annotate \
    --threads ${THREADS} \
    --remove QUAL,FILTER,^INFO/SVTYPE,^INFO/SVLEN,^INFO/END,^FORMAT/GT \
    ${OUTDIR}/panpop.sv.biallelic.vcf.gz \
    -Oz -o ${OUTDIR}/panpop.sv.processed.vcf.gz

tabix -p vcf -f ${OUTDIR}/panpop.sv.processed.vcf.gz

bcftools stats \
    ${OUTDIR}/panpop.sv.processed.vcf.gz \
    > ${OUTDIR}/panpop.sv.processed.stats.txt
