#!/usr/bin/env bash
# LD analysis between SVs and nearby SNPs by physical distance.
# Adapt genotype files, window size, and output directory before running.
set -euo pipefail

BFILE=${BFILE:-population_snp_sv}
OUTDIR=${OUTDIR:-ld_by_distance}
THREADS=${THREADS:-16}
WINDOW_KB=${WINDOW_KB:-1000}

mkdir -p ${OUTDIR}

plink --bfile ${BFILE} \
    --double-id \
    --allow-extra-chr \
    --r2 gz \
    --ld-window 99999 \
    --ld-window-kb ${WINDOW_KB} \
    --ld-window-r2 0 \
    --out ${OUTDIR}/snp_sv_ld \
    --threads ${THREADS}

# Extract maximum LD for each SV/SNP if needed.
# python extract_max_ld.py ${OUTDIR}/snp_sv_ld.ld.gz > ${OUTDIR}/snp_sv_max_ld.tsv
