#!/usr/bin/env bash
# Assembly-based SV detection using whole-genome alignments.
# Adapt assembly list, reference genome, and output directory before running.
set -euo pipefail

ASSEMBLY_LIST=${ASSEMBLY_LIST:-assemblies.list}
REF=${REF:-/path/to/reference.fa}
OUTDIR=${OUTDIR:-assembly_sv_detection}
THREADS=${THREADS:-16}

mkdir -p ${OUTDIR}/{alignments,sv_calls}

while read -r sample assembly; do
  # Whole-genome alignment with minimap2.
  minimap2 -t ${THREADS} -ax asm5 ${REF} ${assembly} \
    | samtools sort -@ ${THREADS} -o ${OUTDIR}/alignments/${sample}.bam
  samtools index ${OUTDIR}/alignments/${sample}.bam

  # SV calling from assembly-to-reference alignment.
  sniffles \
    --input ${OUTDIR}/alignments/${sample}.bam \
    --vcf ${OUTDIR}/sv_calls/${sample}.assembly.sv.vcf \
    --threads ${THREADS} \
    --sample-id ${sample}
done < ${ASSEMBLY_LIST}
