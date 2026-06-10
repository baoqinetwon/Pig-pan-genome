#!/usr/bin/env bash
# Long-read SV detection workflow.
# Adapt BAM files, sample names, reference genome, and output directory before running.
set -euo pipefail

BAM_LIST=${BAM_LIST:-bam.list}
REF=${REF:-/path/to/reference.fa}
OUTDIR=${OUTDIR:-longread_sv_calls}
THREADS=${THREADS:-16}

mkdir -p ${OUTDIR}/{sniffles2,cutesv,pbsv,svim}

while read -r sample bam; do
    sniffles --input ${bam} \
        --vcf ${OUTDIR}/sniffles2/${sample}.sniffles2.vcf \
        --threads ${THREADS} \
        --sample-id ${sample}

    cuteSV ${bam} ${REF} ${OUTDIR}/cutesv/${sample}.cutesv.vcf ${OUTDIR}/cutesv/${sample}.workdir \
        --threads ${THREADS} \
        --sample ${sample}

    pbsv discover ${bam} ${OUTDIR}/pbsv/${sample}.svsig.gz
    pbsv call ${REF} ${OUTDIR}/pbsv/${sample}.svsig.gz ${OUTDIR}/pbsv/${sample}.pbsv.vcf

    svim alignment ${OUTDIR}/svim/${sample} ${bam} ${REF}
done < ${BAM_LIST}
