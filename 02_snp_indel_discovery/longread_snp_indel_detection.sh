#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Long-read SNP/Indel detection using pbmm2 and DeepVariant
# ============================================================
# Workflow:
#   1. Align PacBio HiFi reads to the reference genome using pbmm2
#   2. Sort BAM during alignment
#   3. Call SNPs and Indels using DeepVariant with the PACBIO model
#
# Example input:
#   BMA_hifi.fastq.gz
#
# Example output:
#   01_bam/BMA_pbmm.bam
#   02_deepvariant/BMA.vcf.gz

THREADS=${THREADS:-52}

SAMPLE=${SAMPLE:-BMA}
REF_FA=${REF_FA:-/public/home/baoqi/assembly/Duroc/Duroc.fa}
REF_MMI=${REF_MMI:-/public/home/baoqi/assembly/Duroc/Duroc.mmi}
FASTQ=${FASTQ:-BMA_hifi.fastq.gz}

BAM_DIR=${BAM_DIR:-01_bam}
VCF_DIR=${VCF_DIR:-02_deepvariant}

DEEPVARIANT_SIF=${DEEPVARIANT_SIF:-/public/software/singularity/docker-images/deepvariant-gpu.1.4.0.sif}
SINGULARITY=${SINGULARITY:-/public/software/singularity/bin/singularity}

mkdir -p ${BAM_DIR} ${VCF_DIR}

# ------------------------------------------------------------
# 1. Align HiFi reads with pbmm2
# ------------------------------------------------------------

pbmm2 align \
    --preset HIFI \
    -j ${THREADS} \
    --sort \
    --sort-threads ${THREADS} \
    --sample ${SAMPLE} \
    ${REF_MMI} \
    ${FASTQ} \
    ${BAM_DIR}/${SAMPLE}_pbmm.bam

# ------------------------------------------------------------
# 2. SNP/Indel calling with DeepVariant GPU
# ------------------------------------------------------------
# Use GPU by adding '--nv' to singularity exec.

ls ${BAM_DIR}/*.bam | while read -r bam
 do
    file=$(basename ${bam})
    sample=${file%%.*}

    echo "Calling SNPs/Indels for ${sample} from ${file}"

    ${SINGULARITY} exec --nv --network=none -n ${DEEPVARIANT_SIF} \
        run_deepvariant \
        --model_type=PACBIO \
        --ref=${REF_FA} \
        --reads=${bam} \
        --output_vcf=${VCF_DIR}/${sample}.vcf.gz \
        --num_shards=${THREADS}
 done
