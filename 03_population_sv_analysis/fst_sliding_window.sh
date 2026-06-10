#!/usr/bin/env bash
# Sliding-window Fst analysis for population SV datasets.
# Adapt population sample lists, VCF paths, and window settings before running.
set -euo pipefail

VCF=${VCF:-population.sv.vcf.gz}
POP1=${POP1:-population1.samples.txt}
POP2=${POP2:-population2.samples.txt}
OUT_PREFIX=${OUT_PREFIX:-pop1_vs_pop2}
WINDOW=${WINDOW:-100000}
STEP=${STEP:-10000}

vcftools \
  --gzvcf ${VCF} \
  --weir-fst-pop ${POP1} \
  --weir-fst-pop ${POP2} \
  --fst-window-size ${WINDOW} \
  --fst-window-step ${STEP} \
  --out ${OUT_PREFIX}

# Optional site-level weighted Fst.
vcftools \
  --gzvcf ${VCF} \
  --weir-fst-pop ${POP1} \
  --weir-fst-pop ${POP2} \
  --out ${OUT_PREFIX}.site
