#!/usr/bin/env bash
# Calculate LD using a fixed variant-count window.
# Adapt input PLINK files and window parameters before running.
set -euo pipefail

BFILE=${BFILE:-population_snp_sv}
OUTDIR=${OUTDIR:-ld_by_count}
THREADS=${THREADS:-16}
LD_WINDOW=${LD_WINDOW:-20}

mkdir -p ${OUTDIR}

plink --bfile ${BFILE} \
  --double-id \
  --allow-extra-chr \
  --r2 gz \
  --ld-window ${LD_WINDOW} \
  --ld-window-kb 999999 \
  --ld-window-r2 0 \
  --out ${OUTDIR}/snp_sv_ld_count \
  --threads ${THREADS}
