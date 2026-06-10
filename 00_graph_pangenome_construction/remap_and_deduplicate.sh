#!/usr/bin/env bash
# Remap and deduplicate structural variants after graph/panel construction.
# Adapt all paths before running.
set -euo pipefail

REF=${REF:-/path/to/reference.fa}
VCF=${VCF:-/path/to/input.vcf.gz}
OUTDIR=${OUTDIR:-remap_dedup}
THREADS=${THREADS:-16}

mkdir -p ${OUTDIR}

# Sort and normalize candidate SV VCF.
bcftools sort ${VCF} -Oz -o ${OUTDIR}/input.sorted.vcf.gz
tabix -p vcf -f ${OUTDIR}/input.sorted.vcf.gz

# Normalize alleles against reference.
bcftools norm \
  --threads ${THREADS} \
  -f ${REF} \
  -m -both \
  -Oz \
  -o ${OUTDIR}/input.normalized.vcf.gz \
  ${OUTDIR}/input.sorted.vcf.gz

tabix -p vcf -f ${OUTDIR}/input.normalized.vcf.gz

# Remove duplicate records by CHROM, POS, REF, and ALT.
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%ID\n' ${OUTDIR}/input.normalized.vcf.gz \
  | awk '!seen[$1"\t"$2"\t"$3"\t"$4]++ {print $5}' \
  > ${OUTDIR}/dedup.keep.ids

bcftools view -i 'ID=@'${OUTDIR}'/dedup.keep.ids' \
  ${OUTDIR}/input.normalized.vcf.gz \
  -Oz -o ${OUTDIR}/input.normalized.dedup.vcf.gz

tabix -p vcf -f ${OUTDIR}/input.normalized.dedup.vcf.gz
