#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# PanPop post-processing for graph-genotyped VCFs
# ============================================================
# This script is run after graph-based SV genotyping.
# It processes the genotyped VCF generated from graph-based mapping
# and SV genotyping, rather than preparing input before genotyping.
#
# Main steps:
#   1. Merge per-sample genotyped VCFs, if a VCF list is provided
#   2. Optionally extract target samples
#   3. Retain INS and DEL records
#   4. Retain SVs with length >= 50 bp
#   5. Retain biallelic records
#   6. Keep genotype information and generate final indexed VCF
#
# Input options:
#   GENOTYPED_VCF : already merged graph-genotyped VCF
#   VCF_LIST      : optional list of per-sample graph-genotyped VCFs
#
# If VCF_LIST is provided, VCFs are merged first. Otherwise,
# GENOTYPED_VCF is used directly.

THREADS=${THREADS:-16}
GENOTYPED_VCF=${GENOTYPED_VCF:-02_graph_genotyping/vcf/graph_sv.genotyped.vcf.gz}
VCF_LIST=${VCF_LIST:-}
SAMPLE_LIST=${SAMPLE_LIST:-}
OUTDIR=${OUTDIR:-03_panpop_processed}
MIN_SVLEN=${MIN_SVLEN:-50}

mkdir -p ${OUTDIR}

# ------------------------------------------------------------
# 1. Prepare merged graph-genotyped VCF
# ------------------------------------------------------------

if [[ -n "${VCF_LIST}" ]]; then
    echo "Merging per-sample graph-genotyped VCFs from ${VCF_LIST}"

    bcftools merge \
        --threads ${THREADS} \
        -m none \
        -l ${VCF_LIST} \
        -Oz -o ${OUTDIR}/graph_sv.genotyped.merged.vcf.gz

    tabix -p vcf -f ${OUTDIR}/graph_sv.genotyped.merged.vcf.gz
    INPUT_VCF=${OUTDIR}/graph_sv.genotyped.merged.vcf.gz
else
    echo "Using existing merged graph-genotyped VCF: ${GENOTYPED_VCF}"
    INPUT_VCF=${GENOTYPED_VCF}
fi

# ------------------------------------------------------------
# 2. Optional sample extraction
# ------------------------------------------------------------

if [[ -n "${SAMPLE_LIST}" ]]; then
    bcftools view \
        --threads ${THREADS} \
        -S ${SAMPLE_LIST} \
        ${INPUT_VCF} \
        -Oz -o ${OUTDIR}/graph_sv.genotyped.sample_subset.vcf.gz

    tabix -p vcf -f ${OUTDIR}/graph_sv.genotyped.sample_subset.vcf.gz
    INPUT_VCF=${OUTDIR}/graph_sv.genotyped.sample_subset.vcf.gz
fi

# ------------------------------------------------------------
# 3. Retain INS/DEL SVs and length >= 50 bp
# ------------------------------------------------------------

bcftools view \
    --threads ${THREADS} \
    -i 'INFO/SVTYPE="INS" || INFO/SVTYPE="DEL"' \
    ${INPUT_VCF} \
| bcftools view \
    --threads ${THREADS} \
    -i "ABS(INFO/SVLEN)>=${MIN_SVLEN}" \
    -Oz -o ${OUTDIR}/graph_sv.genotyped.ins_del.len${MIN_SVLEN}.vcf.gz

tabix -p vcf -f ${OUTDIR}/graph_sv.genotyped.ins_del.len${MIN_SVLEN}.vcf.gz

# ------------------------------------------------------------
# 4. Retain biallelic genotyped SV records
# ------------------------------------------------------------

bcftools view \
    --threads ${THREADS} \
    -m2 -M2 \
    ${OUTDIR}/graph_sv.genotyped.ins_del.len${MIN_SVLEN}.vcf.gz \
    -Oz -o ${OUTDIR}/graph_sv.genotyped.biallelic.vcf.gz

tabix -p vcf -f ${OUTDIR}/graph_sv.genotyped.biallelic.vcf.gz

# ------------------------------------------------------------
# 5. Simplify VCF while retaining genotype calls
# ------------------------------------------------------------

bcftools annotate \
    --threads ${THREADS} \
    --remove QUAL,FILTER,^INFO/SVTYPE,^INFO/SVLEN,^INFO/END,^FORMAT/GT \
    ${OUTDIR}/graph_sv.genotyped.biallelic.vcf.gz \
    -Oz -o ${OUTDIR}/graph_sv.genotyped.panpop_processed.vcf.gz

tabix -p vcf -f ${OUTDIR}/graph_sv.genotyped.panpop_processed.vcf.gz

bcftools stats \
    ${OUTDIR}/graph_sv.genotyped.panpop_processed.vcf.gz \
    > ${OUTDIR}/graph_sv.genotyped.panpop_processed.stats.txt
