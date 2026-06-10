#!/usr/bin/env bash
# Split phastCons/conservation tracks into chromosome or chunk-level files.
# Adapt input path and chunking strategy before running.
set -euo pipefail

INPUT=${INPUT:-phastcons.bedGraph.gz}
OUTDIR=${OUTDIR:-phastcons_chunks}
mkdir -p ${OUTDIR}

# Split by chromosome.
zcat ${INPUT} | awk -v outdir=${OUTDIR} '{print > outdir"/"$1".phastcons.bedGraph"}'

# Compress and index outputs where appropriate.
for f in ${OUTDIR}/*.phastcons.bedGraph; do
  bgzip -f ${f}
  tabix -p bed -f ${f}.gz || true
done
