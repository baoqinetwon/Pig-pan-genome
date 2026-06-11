# 10_effect_size_analysis

Allelic fold-change (aFC) estimation for cis-eQTL variants.

This module describes the effect-size analysis used in this study. The main workflow estimates allelic fold-change for cis-regulatory variant-gene pairs using `aFC.py`, together with phased genotype data, TMM-normalized expression phenotypes, cis-eQTL pair files, and covariates.

## Purpose

The purpose of this module is to quantify the magnitude and direction of cis-regulatory effects. For each cis variant-gene pair, `aFC.py` estimates the allelic fold-change associated with the alternative allele while accounting for covariates.

This analysis is used to summarize regulatory effect sizes of cis-eQTL variants and compare the relative effect magnitudes of different variant classes when variant annotations are available.

## Input data

Typical input files include:

```text
phased genotype VCF
TMM-normalized expression phenotype BED
cis-eQTL pair file
covariate file
sample information or sample map, if required
```

Example files:

```text
jx_268_miss01_maf005_biallele.phased2.vcf.gz
cecum.expr_tmm3.bed.gz
cecum_cis.cis_qtl.txt.gz.txt
covariate_cecum.txt
```

## Main workflow

### 1. Prepare phased genotype VCF

The genotype VCF should contain phased genotypes for the samples used in the expression analysis.

Example:

```text
jx_268_miss01_maf005_biallele.phased2.vcf.gz
```

The VCF sample IDs should match the sample IDs in the expression BED and covariate file.

### 2. Prepare expression phenotype BED

Expression phenotypes are provided in BED format. In this workflow, TMM-normalized expression values are used as input to `aFC.py`.

Example:

```text
cecum.expr_tmm3.bed.gz
```

### 3. Prepare cis-eQTL pair file

The cis-eQTL pair file defines the variant-gene pairs for which allelic fold-change is estimated.

Example:

```text
cecum_cis.cis_qtl.txt.gz.txt
```

This file is usually generated from the cis-eQTL mapping results in `08_eqtl_mapping/`.

### 4. Prepare covariates

Covariates are included to account for major confounding factors in expression analysis.

Example:

```text
covariate_cecum.txt
```

The covariate file should use the same sample IDs and sample order convention as the expression phenotype file.

### 5. Run `aFC.py`

Example command:

```bash
python aFC.py \
    --count_o 1 \
    --vcf jx_268_miss01_maf005_biallele.phased2.vcf.gz \
    --pheno cecum.expr_tmm3.bed.gz \
    --qtl cecum_cis.cis_qtl.txt.gz.txt \
    --o aFC_cecum_log2afc_datalog2.txt \
    --cov covariate_cecum.txt \
    --boot 100 \
    --log_xform 0
```

In this example, `--boot 100` performs bootstrap estimation with 100 replicates.

If log2 transformation is required before aFC estimation, use:

```bash
--log_xform 1 --log_base 2
```

Do not specify `--log_xform` twice in the same command. Use either `--log_xform 0` or `--log_xform 1 --log_base 2` depending on the input expression scale.

## Output

Main output:

```text
aFC_cecum_log2afc_datalog2.txt
```

The output table contains allelic fold-change estimates for cis variant-gene pairs. These estimates can be used to summarize regulatory effect sizes across tissues or variant classes.

## Tissue-specific analysis

The same analysis should be repeated separately for each tissue by replacing the phenotype BED, cis-eQTL pair file, covariate file, and output prefix.

Example template:

```bash
TISSUE=cecum

python aFC.py \
    --count_o 1 \
    --vcf jx_268_miss01_maf005_biallele.phased2.vcf.gz \
    --pheno ${TISSUE}.expr_tmm3.bed.gz \
    --qtl ${TISSUE}_cis.cis_qtl.txt.gz.txt \
    --o aFC_${TISSUE}.txt \
    --cov covariate_${TISSUE}.txt \
    --boot 100 \
    --log_xform 0
```

## Downstream summary

After obtaining aFC estimates, results can be summarized by:

```text
variant class, such as SNP, indel, or SV
tissue
lead eVariant or significant cis-eQTL pair
effect direction
effect magnitude
absolute allelic fold-change
```

These summaries can be integrated with cis-eQTL results and variant annotations to compare the regulatory effect sizes of different variant classes.

## Notes

- This module focuses on aFC estimation using `aFC.py`.
- Expression input in this workflow uses TMM-normalized expression values.
- Phased genotypes are required for reliable allelic fold-change estimation.
- Sample IDs must be consistent across genotype VCF, expression BED, QTL pair file, and covariate file.
- Run the analysis separately for each tissue.
