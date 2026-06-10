#!/usr/bin/env bash
# Main workflow for locus-level eQTL visualization.
# Adapt region, VCF, eQTL summary statistics, gene annotation, and output directory before running.
set -euo pipefail

REGION=${REGION:-chr1:1000000-2000000}
VCF=${VCF:-genotypes.vcf.gz}
EQTL=${EQTL:-cis_eqtl_summary.tsv}
GENE_BED=${GENE_BED:-gene_annotation.bed}
OUTDIR=${OUTDIR:-eqtl_locus_plot}
THREADS=${THREADS:-8}

mkdir -p ${OUTDIR}

# Extract local genotype data.
bcftools view \
  --threads ${THREADS} \
  -r ${REGION} \
  ${VCF} \
  -Oz -o ${OUTDIR}/region.genotypes.vcf.gz

tabix -p vcf -f ${OUTDIR}/region.genotypes.vcf.gz

# Extract genes in the target region.
chrom=${REGION%%:*}
range=${REGION#*:}
start=${range%-*}
end=${range#*-}
awk -v chr=${chrom} -v s=${start} -v e=${end} '$1==chr && $3>=s && $2<=e' ${GENE_BED} \
  > ${OUTDIR}/region.genes.bed

# Plot locus-level eQTL signals.
Rscript plot_eqtl_ld_gene.R \
  --eqtl ${EQTL} \
  --vcf ${OUTDIR}/region.genotypes.vcf.gz \
  --genes ${OUTDIR}/region.genes.bed \
  --region ${REGION} \
  --out ${OUTDIR}/eqtl_locus.pdf
