#!/usr/bin/env bash
# Sequence conservation analysis around candidate variants or regions.
# Adapt input BED, conservation bigWig/bedGraph, and output paths before running.
set -euo pipefail

REGIONS=${REGIONS:-candidate_regions.bed}
CONSERVATION=${CONSERVATION:-phastcons.bedGraph.gz}
OUTDIR=${OUTDIR:-sequence_conservation}

mkdir -p ${OUTDIR}

# Intersect candidate regions with conservation scores.
bedtools intersect \
    -a ${REGIONS} \
    -b ${CONSERVATION} \
    -wa -wb \
    > ${OUTDIR}/regions.conservation.intersect.tsv

# Summarize scores per region.
awk 'BEGIN{OFS="\t"}{key=$1":"$2"-"$3; sum[key]+=$7; n[key]+=1} END{for(k in sum) print k, sum[k]/n[k], n[k]}' \
    ${OUTDIR}/regions.conservation.intersect.tsv \
    > ${OUTDIR}/regions.conservation.mean.tsv
