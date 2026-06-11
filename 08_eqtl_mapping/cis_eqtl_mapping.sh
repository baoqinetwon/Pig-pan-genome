#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Joint variant cis-eQTL mapping with OmiGA
# ============================================================
# This script performs two steps:
#   1. Standard cis-QTL mapping by chromosome
#   2. Multiple-testing correction for cis-QTL results
#
# Example shown for duodenum tissue. Adapt genotype, phenotype,
# covariate files, and output directories for other tissues.

GENOTYPE="02_genotype/joint3.filled"
PHENOTYPE="01_phenotype/omgia_duodenum.expression.bed.gz"
COVARIATES="03_covariant/Cov_duodenum.txt"
PREFIX="joint"

CIS_OUTDIR="j3_duodenum_cis"
MT_OUTDIR="duodenum_cis_eqtl_joint_clipper"

mkdir -p ${CIS_OUTDIR} ${MT_OUTDIR}

# ------------------------------------------------------------
# 1. Standard cis-QTL mapping by chromosome
# ------------------------------------------------------------

seq 1 18 | xargs -I {} -P 8 bash -c '
    OmiGA --mode cis \
        --genotype "'${GENOTYPE}'" \
        --chrom {} \
        --phenotype "'${PHENOTYPE}'" \
        --prefix "'${PREFIX}'" \
        --covariates "'${COVARIATES}'" \
        --output-dir "'${CIS_OUTDIR}'" \
        --threads 7 \
        --calcu-variant-threshold \
        --permutations 1000 \
        --rm-collinear-covar 0.95
'

# ------------------------------------------------------------
# 2. Multiple-testing correction for cis-QTL mapping results
# ------------------------------------------------------------

OmiGA --mode cis_mt \
    --threads 16 \
    --cis-file ${CIS_OUTDIR}/${PREFIX}.cis_qtl.txt.gz \
    --multiple-testing clipper \
    --prefix ${PREFIX} \
    --output-dir ${MT_OUTDIR}
