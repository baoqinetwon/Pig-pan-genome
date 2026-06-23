# 12_heritability_partitioning

cis-expression heritability estimation using MPH.

This module estimates gene-level cis-expression heritability from genotype data and expression phenotypes. The workflow mainly includes GRM construction for each gene, generation of GRM list files, and REML-based heritability estimation using `mph`.

In this analysis, five gene-level models were compared by constructing GRMs from different variant sets:

```text
snp
indel
sv
snp + indel
snp + indel + sv
```

These models were used to evaluate the cis-expression heritability explained by each variant class and by combined variant classes.

## Main workflow

### 1. Prepare gene-level variant ID files

For each gene, variant ID files are prepared separately according to variant class or model.

Example file types:

```text
${gene}.snp.id
${gene}.indel.id
${gene}.sv.id
${gene}.snp_indel.id
${gene}.snp_indel_sv.id
```

Each `.id` file contains the variants used to construct one gene-specific GRM.

### 2. Build GRMs for each gene and model

GRMs are generated from the binary genotype file using `mph --make_grm`.

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
*.id                                  Variant list for each gene and model
joint                                 Binary genotype prefix
```

Main outputs:

```text
01_grm/*.grm.bin
01_grm/*.grm.N.bin
01_grm/*.grm.iid
```

### 3. Generate GRM list files

For each GRM, generate a list file used as `--grm_list` input for MPH REML.

```bash
cd 01_grm

ls ./*.grm.iid | xargs -I {} -P 56 sh -c '
    id=$(basename "{}" .grm.iid)
    echo "./01_grm/$id" > "${id}.list"
'
```

Each `${id}.list` contains the prefix of one gene-specific GRM.

### 4. Estimate cis-expression heritability

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
04_result_l/${id}.snp.*
04_result_l/${id}.indel.*
04_result_l/${id}.sv.*
04_result_l/${id}.snp_indel.*
04_result_l/${id}.snp_indel_sv.*
```

### 5. Compare five models

The five models are compared at the gene level and then summarized across genes within each tissue.

```text
snp model              GRM built from SNPs only
indel model            GRM built from indels only
sv model               GRM built from SVs only
snp_indel model        GRM built from SNPs and indels
snp_indel_sv model     GRM built from SNPs, indels, and SVs
```

For each gene, the estimated h2 from different models can be extracted and combined into a summary table:

```text
gene    snp    indel    sv    snp_indel    snp_indel_sv
```

This table is then used to compare the cis-expression heritability explained by different variant classes and combined models.

## Software installation

MPH was used for cis-expression heritability estimation:

```bash
conda create -n mph_h2 -c conda-forge -c bioconda bcftools=1.13 plink2
```

Install MPH from the project release or source package used in the analysis environment:

```bash
git clone <MPH_repository_url>
# then follow the MPH build or installation instructions
```

For small-effect contribution partitioning, GCTA can be installed separately:

```bash
conda install -c bioconda gcta
```

## Notes

- `*.id` files should contain the variant set used for each gene and model.
- The sample order in genotype, phenotype, covariate, and GRM files must be consistent.
- The `--trait` name should match the gene ID in the MPH phenotype file.
- This example uses liver expression phenotypes; other tissues can be analyzed by replacing the phenotype file, covariate file, and output directory.
- For fair model comparison, the same gene set should be used across the five models whenever possible.
