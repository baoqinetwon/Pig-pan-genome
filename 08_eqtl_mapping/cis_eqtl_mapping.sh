#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Joint variant eQTL mapping with OmiGA
# ============================================================
# This script performs two steps:
#   1. Standard cis-QTL mapping
#   2. Conditional independent cis-QTL mapping
#
# Adapt tissue-specific expression and covariate files before running.

THREADS=36

GENOTYPE="../01_raw_gt_maf005_geno01_biallele/02_rmMiss/joint.filled"
PHENOTYPE="tLiver.expr_tmm_qt.bed.gz"
COVARIATES="Cov_liver.txt"
PREFIX="joint"

CIS_OUTDIR="01_cis_eqtl"
COND_OUTDIR="02_condition_independ_cis_eqtl"

mkdir -p ${CIS_OUTDIR} ${COND_OUTDIR}

# ------------------------------------------------------------
# 1. Standard cis-QTL mapping
# ------------------------------------------------------------

OmiGA \
    --mode cis \
    --genotype ${GENOTYPE} \
    --phenotype ${PHENOTYPE} \
    --prefix ${PREFIX} \
    --covariates ${COVARIATES} \
    --output-dir ${CIS_OUTDIR} \
    --threads ${THREADS}

# ------------------------------------------------------------
# 2. Conditional independent cis-QTL mapping
# ------------------------------------------------------------

OmiGA \
    --mode cis_independent \
    --genotype ${GENOTYPE} \
    --phenotype ${PHENOTYPE} \
    --prefix ${PREFIX} \
    --covariates ${COVARIATES} \
    --cis-file ${CIS_OUTDIR}/${PREFIX}.cis_qtl.txt.gz \
    --qtl-map-model a+A \
    --output-dir ${COND_OUTDIR} \
    --threads ${THREADS}
