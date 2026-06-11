#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Graph-based short-read mapping and SV genotyping
# ============================================================
# This script performs graph-based short-read mapping and SV genotyping.
# The resulting graph-genotyped VCF is then processed by
# panpop_processing.sh in the next step.
#
# Main steps:
#   1. Map paired-end short reads with vg giraffe
#   2. Pack read support on graph paths
#   3. Call graph-based SV genotypes with vg call
#   4. Compress and index per-sample VCF files
#
# Input FASTQ list format:
#   sample_id    read1.fq.gz    read2.fq.gz
#
# Required graph index files:
#   XG, GBZ, MIN, DIST, SNARLS, and related VG/Giraffe indexes

THREADS=${THREADS:-16}
FASTQ_LIST=${FASTQ_LIST:-fastq.list}
OUTDIR=${OUTDIR:-02_graph_genotyping}

# Graph index files. Replace these paths before running.
GBZ=${GBZ:-graph.gbz}
XG=${XG:-graph.xg}
MIN=${MIN:-graph.min}
DIST=${DIST:-graph.dist}
SNARLS=${SNARLS:-graph.snarls}

# Variant sites included in the graph and used for genotype extraction.
# This file should correspond to the graph-compatible SV site VCF generated
# during graph pangenome construction.
GRAPH_SV_SITE_VCF=${GRAPH_SV_SITE_VCF:-graph_sv_sites.vcf.gz}

mkdir -p ${OUTDIR}/{gam,pack,vcf,log}

while read -r sample fq1 fq2
 do
    [[ -z "${sample}" || "${sample}" =~ ^# ]] && continue

    echo "Graph-based mapping and SV genotyping for ${sample}"

    # ------------------------------------------------------------
    # 1. Graph-based short-read mapping with VG/Giraffe
    # ------------------------------------------------------------

    vg giraffe \
        -Z ${GBZ} \
        -m ${MIN} \
        -d ${DIST} \
        -f ${fq1} \
        -f ${fq2} \
        -t ${THREADS} \
        > ${OUTDIR}/gam/${sample}.gam \
        2> ${OUTDIR}/log/${sample}.giraffe.log

    # ------------------------------------------------------------
    # 2. Pack graph read support
    # ------------------------------------------------------------

    vg pack \
        -x ${XG} \
        -g ${OUTDIR}/gam/${sample}.gam \
        -o ${OUTDIR}/pack/${sample}.pack \
        -t ${THREADS}

    # ------------------------------------------------------------
    # 3. Call graph genotypes
    # ------------------------------------------------------------

    vg call \
        ${XG} \
        -r ${SNARLS} \
        -k ${OUTDIR}/pack/${sample}.pack \
        -s ${sample} \
        -v ${GRAPH_SV_SITE_VCF} \
        -t ${THREADS} \
        > ${OUTDIR}/vcf/${sample}.graph_sv.raw.vcf

    bgzip -@ ${THREADS} -f ${OUTDIR}/vcf/${sample}.graph_sv.raw.vcf
    tabix -p vcf -f ${OUTDIR}/vcf/${sample}.graph_sv.raw.vcf.gz
 done < ${FASTQ_LIST}

# The per-sample VCFs can be merged and further processed with:
#   bash panpop_processing.sh
