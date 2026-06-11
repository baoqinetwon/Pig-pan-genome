#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Graph-based short-read mapping and SV genotyping
# ============================================================
# This script maps short-read sequencing data to the graph pangenome
# using VG/Giraffe and extracts graph-based SV genotypes.
#
# Main steps:
#   1. Map paired-end short reads with vg giraffe
#   2. Convert GAM to sorted BAM/CRAM if needed
#   3. Pack read support on graph paths
#   4. Call graph-based genotypes with vg call
#   5. Filter and index the output VCF
#
# Input FASTQ list format:
#   sample_id    read1.fq.gz    read2.fq.gz
#
# Required graph index files:
#   XG, GBWT, GGBWT/GBZ, MIN, DIST, and related VG/Giraffe indexes

THREADS=${THREADS:-16}
FASTQ_LIST=${FASTQ_LIST:-fastq.list}
OUTDIR=${OUTDIR:-02_graph_genotyping}

# Graph index files. Replace these paths before running.
GBZ=${GBZ:-graph.gbz}
XG=${XG:-graph.xg}
MIN=${MIN:-graph.min}
DIST=${DIST:-graph.dist}
SNARLS=${SNARLS:-graph.snarls}

# Processed SV VCF from panpop_processing.sh
SV_VCF=${SV_VCF:-01_panpop_processed/panpop.sv.processed.vcf.gz}

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
        -v ${SV_VCF} \
        -t ${THREADS} \
        > ${OUTDIR}/vcf/${sample}.graph_sv.raw.vcf

    bgzip -@ ${THREADS} -f ${OUTDIR}/vcf/${sample}.graph_sv.raw.vcf
    tabix -p vcf -f ${OUTDIR}/vcf/${sample}.graph_sv.raw.vcf.gz

    # ------------------------------------------------------------
    # 4. Basic VCF filtering and normalization
    # ------------------------------------------------------------

    bcftools view \
        --threads ${THREADS} \
        -i 'GT!="./."' \
        ${OUTDIR}/vcf/${sample}.graph_sv.raw.vcf.gz \
        -Oz -o ${OUTDIR}/vcf/${sample}.graph_sv.filtered.vcf.gz

    tabix -p vcf -f ${OUTDIR}/vcf/${sample}.graph_sv.filtered.vcf.gz
 done < ${FASTQ_LIST}
