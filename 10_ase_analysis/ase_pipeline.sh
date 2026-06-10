#!/usr/bin/env bash
# Main allele-specific expression analysis workflow.
# Adapt RNA BAMs, phased genotypes, annotation, and output directory before running.
set -euo pipefail

BAM_LIST=${BAM_LIST:-rna_bam.list}
VCF=${VCF:-phased_genotypes.vcf.gz}
GTF=${GTF:-annotation.gtf}
REF=${REF:-reference.fa}
OUTDIR=${OUTDIR:-ase_analysis}
THREADS=${THREADS:-8}

mkdir -p ${OUTDIR}/counts ${OUTDIR}/results

# Example workflow using WASP/GATK ASEReadCounter-style counting.
while read -r sample bam; do
  gatk ASEReadCounter \
    -R ${REF} \
    -I ${bam} \
    -V ${VCF} \
    -O ${OUTDIR}/counts/${sample}.ase_counts.tsv

done < ${BAM_LIST}

# Combine ASE counts and run downstream statistical analysis.
Rscript ase_summary.R \
  --count_dir ${OUTDIR}/counts \
  --annotation ${GTF} \
  --out ${OUTDIR}/results/ase_summary.tsv
