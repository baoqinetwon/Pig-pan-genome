#!/usr/bin/env bash
# Main allele fold-change and eQTL effect-size analysis workflow.
# Adapt eQTL summary statistics, genotype groups, expression matrix, and output directory before running.
set -euo pipefail

EQTL=${EQTL:-lead_eqtl_summary.tsv}
EXPRESSION=${EXPRESSION:-expression_matrix.tsv}
GENOTYPE=${GENOTYPE:-genotype_matrix.tsv}
OUTDIR=${OUTDIR:-effect_size_analysis}

mkdir -p ${OUTDIR}

# Estimate allelic fold-change and summarize effect-size distribution.
Rscript estimate_allele_fold_change.R \
  --eqtl ${EQTL} \
  --expression ${EXPRESSION} \
  --genotype ${GENOTYPE} \
  --out ${OUTDIR}/allele_fold_change.tsv

Rscript summarize_effect_size.R \
  --input ${OUTDIR}/allele_fold_change.tsv \
  --out ${OUTDIR}/effect_size_summary.tsv
