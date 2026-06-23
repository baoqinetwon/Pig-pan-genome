#!/usr/bin/env bash
# nucmer + Assemblytics based assembly SV detection.
set -euo pipefail

REF=${REF:-/public/home/baoqi/assembly/Duroc/Duroc.fa}
ASSEMBLY_DIR=${ASSEMBLY_DIR:-../accession_genome}
THREADS=${THREADS:-56}
ASSEMBLYTICS=${ASSEMBLYTICS:-${HOME}/software/Assemblytics-1.2.1/scripts/Assemblytics}

# Assemblytics parameters
UNIQUE_ANCHOR_LENGTH=${UNIQUE_ANCHOR_LENGTH:-500}
MIN_VARIANT_SIZE=${MIN_VARIANT_SIZE:-50}
MAX_VARIANT_SIZE=${MAX_VARIANT_SIZE:-100500}

# SURVIVOR convertAssemblytics parameter
SURVIVOR_MIN_SIZE=${SURVIVOR_MIN_SIZE:-50}

# nucmer + Assemblytics
ls "${ASSEMBLY_DIR}"/*fa | while read -r id; do
  file=$(basename "${id}")
  sample=${file%%.*}
  echo "${file} ${sample}"

  nucmer --maxmatch -l 500 -c 500 -t "${THREADS}" \
    "${REF}" "${id}" \
    --prefix="${sample}"

  "${ASSEMBLYTICS}" \
    "${sample}.delta" \
    "${sample}" \
    "${UNIQUE_ANCHOR_LENGTH}" \
    "${MIN_VARIANT_SIZE}" \
    "${MAX_VARIANT_SIZE}"

  SURVIVOR convertAssemblytics \
    "${sample}.Assemblytics_structural_variants.bed" \
    "${SURVIVOR_MIN_SIZE}" \
    "${sample}"
done
