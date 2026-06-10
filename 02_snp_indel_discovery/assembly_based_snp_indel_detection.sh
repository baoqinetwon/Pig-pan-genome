#!/usr/bin/env bash
# Assembly-based SNP/Indel detection using nucmer/MUMmer.
# Adapt reference/query assemblies and output paths before running.
set -euo pipefail

REF=${REF:-/path/to/reference.fa}
QUERY_LIST=${QUERY_LIST:-assembly.list}
OUTDIR=${OUTDIR:-assembly_snp_indel}
THREADS=${THREADS:-16}

mkdir -p ${OUTDIR}

while read -r sample query; do
    prefix=${OUTDIR}/${sample}

    nucmer --maxmatch -t ${THREADS} -p ${prefix} ${REF} ${query}
    delta-filter -1 ${prefix}.delta > ${prefix}.filter.delta
    show-snps -ClrTH ${prefix}.filter.delta > ${prefix}.snps

    # Convert MUMmer SNP table to VCF.
    python MUMmerSNPs2VCF.py \
        --snps ${prefix}.snps \
        --ref ${REF} \
        --sample ${sample} \
        --out ${prefix}.snp_indel.vcf

done < ${QUERY_LIST}
