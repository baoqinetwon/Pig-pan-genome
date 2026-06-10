#!/usr/bin/env bash
# Merge structural variant calls from multiple samples or callers.
# This is a standardized wrapper for study-specific SV merging steps.
set -euo pipefail

VCF_LIST=${VCF_LIST:-sv_vcf_list.txt}
REF=${REF:-/path/to/reference.fa}
OUTDIR=${OUTDIR:-merged_sv}
THREADS=${THREADS:-16}

mkdir -p ${OUTDIR}

# Example: merge normalized VCFs with bcftools.
bcftools merge \
    --threads ${THREADS} \
    -m none \
    -l ${VCF_LIST} \
    -Oz \
    -o ${OUTDIR}/merged.raw.vcf.gz

tabix -p vcf -f ${OUTDIR}/merged.raw.vcf.gz

# Optional normalization.
bcftools norm \
    --threads ${THREADS} \
    -f ${REF} \
    -m -both \
    -Oz \
    -o ${OUTDIR}/merged.normalized.vcf.gz \
    ${OUTDIR}/merged.raw.vcf.gz

tabix -p vcf -f ${OUTDIR}/merged.normalized.vcf.gz
