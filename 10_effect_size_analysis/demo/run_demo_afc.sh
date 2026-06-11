#!/usr/bin/env bash
set -euo pipefail

# Demo command for allelic fold-change estimation.
# Replace AFC_PY with the path to aFC.py if it is not in the current directory.

AFC_PY=${AFC_PY:-../aFC.py}

python ${AFC_PY} \
    --count_o 1 \
    --vcf demo.phased.vcf \
    --pheno demo.phenotype.bed \
    --qtl demo.evariant.txt \
    --o demo_aFC.txt \
    --cov demo_covariant.txt \
    --boot 100 \
    --log_xform 0
