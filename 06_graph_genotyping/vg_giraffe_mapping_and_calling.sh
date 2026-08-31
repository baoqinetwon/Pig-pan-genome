#!/usr/bin/env bash
# SV merge and graph genotyping using PanPop/VG
# Source file: SV_merge_using_Panpop
# Adapt paths, reference files, and sample lists before running.
set -euo pipefail

# Clean paired-end FASTQ files
ls ./*_f1.fq.gz | while read i; do
    i=${i/_f1.fq.gz/}
    fastp -w 56 \
        -i ${i}_f1.fq.gz -o ${i}_R1.clean.fq.gz \
        -I ${i}_r2.fq.gz -O ${i}_R2.clean.fq.gz
done

# Map reads to graph and call variants
ls ./*_R1.clean.fq.gz | while read i; do
    i=${i/_R1.clean.fq.gz/}
    vg giraffe \
         -t 16 \
        -Z /path/to/PGG.giraffe.gbz \
        -m /path/to/PGG.min \
        -d /path/to/PGG.dist \
        -f ${i}_R1.clean.fq.gz \
        -f ${i}_R2.clean.fq.gz \
        > ${i}-pan.gam

    vg pack \
        -t 96 \
        -x /path/to/PGG.giraffe.gbz \
        -g ${i}-pan.gam \
        -o ${i}-pan.pack

    vg call \
        -t 96 \
        -r /path/to/PGG.snarls \
        -z /path/to/PGG.giraffe.gbz \
        -a \
        -k ${i}-pan.pack \
        -s ${i} \
        > ${i}-pan.vcf
done

# Split multiallelic sites
ls *vcf | while read id; do
    bcftools norm --threads 16 -m -both ${id} -o ${id}.split.vcf
done

# Extract SVs >=50 bp and merge sample VCFs
ls *split.vcf | while read id; do
    python extract_sv_len50.py ${id} > ${id}.indel50.vcf
done

ls *indel50.vcf | while read id; do
    bgzip -@ 16 ${id}
done

ls *indel50.vcf.gz | while read id; do
    tabix -f ${id}
done

ls *indel50.vcf.gz > sample.txt
bcftools merge -m none --threads 16 -l sample.txt -Oz -o panel.vcf.gz

# Depth-based soft filtering; replace avDP with the cohort average depth.
bcftools filter -i 'INFO/DP > avDP/3 & avDP*3 > INFO/DP' input.vcf.gz -o filtered.vcf

# Merge SVs using PanPop
perl /path/to/panpop-main/bin/PART_run.pl \
    --in_vcf input.vcf.gz \
    -o OUTDIR_RUN1 \
    -r /path/to/reference.fa \
    -t 56 \
    --tmpdir TMPDIR

perl /path/to/panpop-main/bin/PART_run.pl \
    --in_vcf OUTDIR_RUN1/3.final.vcf.gz \
    -o OUTDIR_RUN2 \
    -r /path/to/reference.fa \
    -t 56 \
    --tmpdir TMPDIR \
    -not_first_merge
