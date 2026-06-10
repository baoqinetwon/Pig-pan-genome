#!/usr/bin/env bash
# Population structure, phylogeny, ADMIXTURE, and Fst analysis for SV genotypes.
# Adapt input VCF, population map, and output paths before running.
set -euo pipefail

VCF=${VCF:-population.sv.vcf.gz}
POP_MAP=${POP_MAP:-sample_population.txt}
OUTDIR=${OUTDIR:-population_sv_results}
THREADS=${THREADS:-16}

mkdir -p ${OUTDIR}/{pca,tree,admixture,fst}

# Convert VCF to PLINK format.
plink --vcf ${VCF} \
    --double-id \
    --allow-extra-chr \
    --make-bed \
    --out ${OUTDIR}/population_sv

# PCA.
plink --bfile ${OUTDIR}/population_sv \
    --allow-extra-chr \
    --pca 20 \
    --out ${OUTDIR}/pca/population_sv

# LD pruning for population analyses.
plink --bfile ${OUTDIR}/population_sv \
    --allow-extra-chr \
    --indep-pairwise 50 10 0.2 \
    --out ${OUTDIR}/population_sv.pruned

plink --bfile ${OUTDIR}/population_sv \
    --allow-extra-chr \
    --extract ${OUTDIR}/population_sv.pruned.prune.in \
    --make-bed \
    --out ${OUTDIR}/population_sv.pruned

# ADMIXTURE.
for K in $(seq 2 10); do
    admixture --cv ${OUTDIR}/population_sv.pruned.bed ${K} \
        | tee ${OUTDIR}/admixture/K${K}.log
done

# Phylogenetic tree input.
VCF2Dis -InPut ${VCF} -OutPut ${OUTDIR}/tree/population_sv.dis

# Pairwise or window-based Fst with vcftools.
vcftools --gzvcf ${VCF} \
    --weir-fst-pop population1.samples \
    --weir-fst-pop population2.samples \
    --fst-window-size 100000 \
    --fst-window-step 10000 \
    --out ${OUTDIR}/fst/pop1_vs_pop2
