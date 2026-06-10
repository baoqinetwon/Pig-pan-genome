#!/usr/bin/env bash
# Main gene regulatory network construction workflow.
# Adapt expression matrix, TF list, regulatory features, and output directory before running.
set -euo pipefail

EXPRESSION=${EXPRESSION:-expression_matrix.tsv}
TF_LIST=${TF_LIST:-transcription_factors.txt}
FEATURES=${FEATURES:-regulatory_features.bed}
OUTDIR=${OUTDIR:-grn_construction}
THREADS=${THREADS:-8}

mkdir -p ${OUTDIR}

# Build regulatory network using the project GRN script.
python GRN.py \
  --expression ${EXPRESSION} \
  --tf-list ${TF_LIST} \
  --features ${FEATURES} \
  --threads ${THREADS} \
  --out ${OUTDIR}/grn_edges.tsv

# Optional downstream network summary.
Rscript summarize_grn.R \
  --edges ${OUTDIR}/grn_edges.tsv \
  --out ${OUTDIR}/grn_summary.tsv
