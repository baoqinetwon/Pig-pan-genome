#!/usr/bin/env bash
# Construct genomic relationship matrix for OmiGA eQTL mapping.
# Adapt binary genotype prefix and output prefix before running.
set -euo pipefail

GENOTYPE_PREFIX=${GENOTYPE_PREFIX:-genotype_for_grm}
OUT_PREFIX=${OUT_PREFIX:-additive_grm}
THREADS=${THREADS:-16}

mph --make_grm \
    --binary_genotype ${GENOTYPE_PREFIX} \
    --num_threads ${THREADS} \
    --out ${OUT_PREFIX}
