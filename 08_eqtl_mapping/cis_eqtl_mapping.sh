#!/usr/bin/env bash
# cis-eQTL mapping with OmiGA.
# Source file: eQTL_analyses/eQTL.sh
# Adapt tissue names, genotype files, covariates, GRM, and gene annotation paths before running.
set -euo pipefail

tissue="muscle"
thread=10
workdir="/path/to/eqtl_analysis"
expression="${workdir}/${tissue}.expression.normalized.txt"
covariates="${workdir}/${tissue}.covariates.txt"
gene_anno="${workdir}/gene_annotation.txt"
genotype="${workdir}/genotype.vcf.gz"
grm="${workdir}/additive.grm"
outdir="${workdir}/cis_eqtl_${tissue}"

mkdir -p ${outdir}

OmiGA \
  --mode cis \
  --vcf ${genotype} \
  --pheno ${expression} \
  --covar ${covariates} \
  --gene-annot ${gene_anno} \
  --grm ${grm} \
  --window 1000000 \
  --calcu-variant-threshold \
  --thread ${thread} \
  --out ${outdir}/${tissue}.cis_eqtl
