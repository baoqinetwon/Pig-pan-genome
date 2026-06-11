#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Conditional independent cis-QTL mapping with OmiGA
# ============================================================
# This script identifies conditionally independent cis-QTL signals
# using the standard cis-QTL mapping results as input.
#
# Adapt tissue-specific genotype, phenotype, covariate files,
# cis-QTL result file, and output directory before running.

THREADS=36

GENOTYPE="../01_raw_gt_maf005_geno01_biallele/02_rmMiss/joint.filled"
PHENOTYPE="tLiver.expr_tmm_qt.bed.gz"
COVARIATES="Cov_liver.txt"
PREFIX="joint"

CIS_FILE="01_cis_eqtl/joint.cis_qtl.txt.gz"
OUTDIR="02_condition_independ_cis_eqtl"

mkdir -p ${OUTDIR}

OmiGA --mode cis_independent \
    --genotype ${GENOTYPE} \
    --phenotype ${PHENOTYPE} \
    --prefix ${PREFIX} \
    --covariates ${COVARIATES} \
    --cis-file ${CIS_FILE} \
    --threads ${THREADS} \
    --qtl-map-model a+A \
    --output-dir ${OUTDIR}
