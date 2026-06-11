# 12_heritability_partitioning

cis-expression heritability estimation using MPH.

This module estimates gene-level cis-expression heritability from genotype data and expression phenotypes. The workflow mainly includes GRM construction for each gene, generation of GRM list files, and REML-based heritability estimation using `mph`.

## Main workflow

### 1. Build GRMs for each gene

Each `*.id` file contains the variant list used to build a gene-specific GRM. GRMs are generated from the binary genotype file using `mph --make_grm`.

```bash
ls *.id | xargs -I {} -P 56 sh -c '
    mph --make_grm \
        --binary_genotype ~/SVanalysis/04_RNA-SEQ/qtTMM/06_eqtl/02_genotype/joint \
        --snp_info {} \
        --num_threads 14 \
        --out 01_grm/{}
'
```

Main inputs:

```text
*.id                                  Variant list for each gene
joint                                 Binary genotype prefix
```

Main outputs:

```text
01_grm/*.grm.bin
01_grm/*.grm.N.bin
01_grm/*.grm.iid
```

### 2. Generate GRM list files

For each GRM, generate a list file used as `--grm_list` input for MPH REML.

```bash
cd 01_grm

ls ./*.grm.iid | xargs -I {} -P 56 sh -c '
    id=$(basename "{}" .grm.iid)
    echo "./01_grm/$id" > "${id}.list"
'
```

Each `${id}.list` contains the prefix of one gene-specific GRM.

### 3. Estimate cis-expression heritability

Heritability is estimated with `mph --reml` using the GRM list, tissue-specific expression phenotype, and covariates.

Example for liver:

```bash
mkdir 04_result_l

ls *list | xargs -I {} -P 52 sh -c '
    file="{}"
    id=$(basename "$file" .bed.eachgene.vcf.id.list)

    mph --reml \
        --grm_list "$file" \
        --phenotype /public/home/baoqi/SVanalysis/04_RNA-SEQ/qtTMM/01_mph_phenotype/Liver.mph.csv \
        --covariate_file /public/home/baoqi/SVanalysis/04_RNA-SEQ/qtTMM/02_covariant/Cov_liver.csv \
        --covariate_names all \
        --trait "$id" \
        --num_threads 1 \
        --num_random 500 \
        --out "04_result_l/${id}.snp_indel_sv"
'
```

Main inputs:

```text
GRM list file
Liver.mph.csv
Cov_liver.csv
gene ID used as --trait
```

Main outputs:

```text
04_result_l/${id}.snp_indel_sv.*
```

## Notes

- `*.id` files should contain the variant set used for each gene.
- The sample order in genotype, phenotype, covariate, and GRM files must be consistent.
- The `--trait` name should match the gene ID in the MPH phenotype file.
- This example uses liver expression phenotypes; other tissues can be analyzed by replacing the phenotype file, covariate file, and output directory.
