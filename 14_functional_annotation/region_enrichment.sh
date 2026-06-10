#!/usr/bin/env bash
# Region enrichment analysis using permutation or Fisher tests.
# Adapt query/background/annotation BED files before running.
set -euo pipefail

QUERY=${QUERY:-query_regions.bed}
BACKGROUND=${BACKGROUND:-background_regions.bed}
ANNOTATION=${ANNOTATION:-annotation_regions.bed}
OUTDIR=${OUTDIR:-region_enrichment}

mkdir -p ${OUTDIR}

# Observed overlap.
bedtools intersect -u -a ${QUERY} -b ${ANNOTATION} > ${OUTDIR}/query.overlap.bed
bedtools intersect -u -a ${BACKGROUND} -b ${ANNOTATION} > ${OUTDIR}/background.overlap.bed

query_total=$(wc -l < ${QUERY})
query_overlap=$(wc -l < ${OUTDIR}/query.overlap.bed)
bg_total=$(wc -l < ${BACKGROUND})
bg_overlap=$(wc -l < ${OUTDIR}/background.overlap.bed)

cat > ${OUTDIR}/enrichment_counts.tsv <<EOF
set\ttotal\toverlap
query\t${query_total}\t${query_overlap}
background\t${bg_total}\t${bg_overlap}
EOF

# Optional: run an R script for Fisher exact test or permutation-based enrichment.
# Rscript enrichment_fisher_test.R ${OUTDIR}/enrichment_counts.tsv ${OUTDIR}/fisher_result.tsv
