#!/usr/bin/env bash
# cis-heritability analysis with MPH.
# Source file: cis_heritability
# Adapt paths, reference files, and sample lists before running.
set -euo pipefail

# Extract cis-variants for each gene.
awk '{print > $4".bed"}' ../genes_flank1MB.bed

ls *bed | while read id; do
    bcftools view -R ${id} joint.vcf.gz -o ${id}.eachgene.vcf
done

ls *vcf | while read id; do
    awk '{print $3}' ${id} > ${id}.id
done

# Construct GRMs.
mkdir -p 01_grm
ls *.id | xargs -I {} -P 56 sh -c 'mph --make_grm \
  --binary_genotype /path/to/binary_genotype_prefix \
  --snp_info {} \
  --num_threads 14 \
  --out 01_grm/{}'

# Build GRM list files.
cd 01_grm
ls ./*.grm.iid | xargs -I {} -P 56 sh -c '
    id=$(basename "{}" .grm.iid)
    echo "./01_grm/$id" > "${id}.list"
'

# Estimate cis-heritability.
mkdir -p 04_result_l
ls *list | xargs -I {} -P 52 sh -c '
    file="{}"
    id=$(basename "$file" .bed.eachgene.vcf.id.list)
    mph --reml \
        --grm_list "$file" \
        --phenotype /path/to/Liver.mph.csv \
        --covariate_file /path/to/Cov_liver.csv \
        --covariate_names all \
        --trait "$id" \
        --num_threads 1 \
        --num_random 500 \
        --out "04_result_l/${id}.snp_indel_sv"
'

# Extract PVE and log-likelihood summaries.
Rscript extract_info_fromMPH.R
