#!/usr/bin/env bash
# Main RNA-seq quantification workflow.
# Adapt FASTQ paths, STAR genome index, GTF annotation, and output directory before running.
set -euo pipefail

FASTQ_DIR=${FASTQ_DIR:-/path/to/fastq}
STAR_INDEX=${STAR_INDEX:-/path/to/star_index}
GTF=${GTF:-/path/to/annotation.gtf}
OUTDIR=${OUTDIR:-rna_quantification}
THREADS=${THREADS:-16}

mkdir -p ${OUTDIR}/star ${OUTDIR}/stringtie ${OUTDIR}/featurecounts

# STAR alignment.
ls ${FASTQ_DIR}/*_1_clean.fq.gz | while read -r r1; do
  prefix=${r1%_1_clean.fq.gz}
  sample=$(basename ${prefix})
  r2=${prefix}_2_clean.fq.gz

  STAR \
    --runThreadN ${THREADS} \
    --genomeDir ${STAR_INDEX} \
    --sjdbGTFfile ${GTF} \
    --quantMode TranscriptomeSAM \
    --outSAMtype BAM SortedByCoordinate \
    --outSAMunmapped Within \
    --readFilesCommand zcat \
    --outFilterMismatchNmax 3 \
    --readFilesIn ${r1} ${r2} \
    --outFileNamePrefix ${OUTDIR}/star/${sample}.

done

# Transcript-level/gene-level abundance with StringTie.
ls ${OUTDIR}/star/*.bam | while read -r bam; do
  sample=$(basename ${bam} .bam)
  stringtie \
    -p ${THREADS} \
    -e -B \
    -G ${GTF} \
    -o ${OUTDIR}/stringtie/${sample}.gtf \
    -A ${OUTDIR}/stringtie/${sample}.gene_abundance.tsv \
    ${bam}
done

# Gene count matrix with featureCounts.
featureCounts \
  -T ${THREADS} \
  -p \
  -t exon \
  -g gene_id \
  -a ${GTF} \
  -o ${OUTDIR}/featurecounts/gene_counts.txt \
  ${OUTDIR}/star/*.bam
