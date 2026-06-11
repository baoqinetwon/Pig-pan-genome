# 12_heritability_partitioning

cis-expression heritability partitioning using variance-component models.

This module contains scripts and workflow notes for estimating cis-expression heritability and partitioning the genetic contribution of different variant classes, including SNPs, indels, and structural variants (SVs). The analysis is based on gene expression phenotypes, cis-window genotype data, genomic relationship matrices (GRMs), and variance-component modeling.

## Purpose

The purpose of this module is to evaluate how much local genetic variation contributes to gene expression variation and to compare the contribution of different variant classes.

The main questions addressed by this module are:

```text
How much cis-expression heritability can be explained by SNPs?
How much additional variance can be explained after adding indels or SVs?
Do SVs provide independent information beyond nearby SNPs and indels?
How do variant-class-specific contributions differ across tissues?
```

## Input data

Typical input files include:

```text
normalized gene expression matrix
matched genotype files
cis-window variant sets for each gene
variant class annotation, such as SNP, indel, and SV
gene list or eGene list
sample information and covariates
GRM files for each variant class or model
```

Expression and genotype samples must be matched before heritability estimation.

## Main workflow

### 1. Prepare expression phenotypes

Expression phenotypes are prepared separately for each tissue.

Typical inputs are normalized gene expression values generated from `07_expression_processing/`, for example:

```text
muscle.gene.txt
liver.gene.txt
duodenum.gene.txt
```

For eGene-focused analyses, the gene list can be restricted to significant eGenes identified in `08_eqtl_mapping/`.

### 2. Define cis windows for each gene

For each gene, nearby variants within a cis region are selected for heritability estimation.

A typical cis-window definition is:

```text
variants within +/- 1 Mb of the gene transcription start site or gene body
```

The same cis-window definition should be used consistently across SNPs, indels, and SVs.

### 3. Split variants by class

Variants are separated into different classes before GRM construction.

Common variant classes include:

```text
SNP
INDEL
SV
SNP + INDEL
SNP + INDEL + SV
```

Depending on the analysis design, SVs can also be stratified by LD with nearby SNPs, repeat annotation, or other features.

### 4. Construct GRMs

For each gene and each variant class or combined model, a genomic relationship matrix is constructed from the corresponding cis variants.

Typical model inputs include:

```text
SNP GRM
INDEL GRM
SV GRM
SNP + INDEL GRM
SNP + INDEL + SV GRM
```

The GRM construction step should use the same sample order as the expression phenotype file.

### 5. Estimate cis-expression heritability

Variance-component models are fitted to estimate the proportion of expression variance explained by each variant class.

Typical models include:

```text
SNP-only model
SNP + INDEL model
SNP + SV model
SNP + INDEL + SV model
```

For each gene, the model estimates variance components and reports the heritability contribution of each GRM.

### 6. Filter converged models

Model convergence should be checked before downstream summary.

Typical convergence criteria used in the analysis include:

```text
dLLpred < 0.01
dogleg_Newton > 0.999
```

Variance-component estimates are further filtered to keep valid values:

```text
0 < h2 < 1
```

Genes or models that do not pass convergence or valid-range filters should be excluded from final summaries.

### 7. Apply diagonal correction when needed

When GRM diagonals differ among variant classes, variance-component estimates can be adjusted using diagonal statistics.

A typical correction is:

```text
adjusted PVE = raw PVE x GRM diagonal statistic
```

The diagonal correction helps make variance-component estimates more comparable across different GRMs.

### 8. Compare nested or alternative models

Model comparison is used to evaluate whether adding a variant class improves model fit.

Typical comparisons include:

```text
SNP-only vs SNP + INDEL
SNP-only vs SNP + SV
SNP + INDEL vs SNP + INDEL + SV
```

For log-likelihood based comparisons, likelihood-ratio statistics can be calculated as:

```text
LRT = 2 x (logLL_full - logLL_reduced)
```

These comparisons can be summarized across genes and tissues to evaluate the additional contribution of SVs or indels.

### 9. Summarize heritability estimates

Final summaries are generated after convergence filtering and optional diagonal correction.

Typical summaries include:

```text
mean h2 by variant class
median h2 by variant class
distribution of h2 across genes
delta h2 relative to SNP-only model
delta log-likelihood relative to SNP-only model
tissue-specific h2 comparison
```

## Outputs

Typical outputs from this module include:

```text
per-gene variance-component result files
per-gene h2 estimates for SNP, indel, and SV components
model log-likelihood summary tables
convergence-filtered gene lists
diagonal-corrected PVE tables
summary tables by tissue and model
boxplots or violin plots of h2 and delta h2
model-comparison plots based on delta logLL or LRT
```

## Example interpretation

A typical interpretation is:

```text
If the SNP + INDEL + SV model explains more cis-expression variance or has a higher log-likelihood than the SNP-only model, the added variant class may capture regulatory effects not fully tagged by SNPs.
```

However, model interpretation should consider variant density, LD structure, convergence, GRM quality, and sample size.

## Connection to other modules

This module uses outputs from:

```text
07_expression_processing/
08_eqtl_mapping/
04_ld_and_feature_annotation/
```

It can also be integrated with SV annotation, LD analysis, and eQTL effect-size analysis to interpret the contribution of SVs to gene expression regulation.

## Notes

- Heritability partitioning should be performed separately for each tissue.
- Sample order must be identical across expression phenotypes, genotype matrices, and GRMs.
- The same cis-window definition should be used across variant classes.
- Convergence filtering is essential before summarizing h2 estimates.
- When comparing models, use the same gene set across models to avoid biased summaries.
- Variant-class contributions should be interpreted together with LD patterns and variant counts.
