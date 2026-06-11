# 10_effect_size_analysis

Allelic fold-change and eQTL effect-size analyses.

This module contains scripts and workflow notes for estimating and summarizing the effect sizes of regulatory variants, including SNPs, indels, and structural variants (SVs), across tissues.

## Purpose

The goal of this module is to quantify the magnitude and direction of variant effects on gene expression. These analyses are used to compare effect-size patterns among variant classes and to evaluate whether SVs tend to have stronger regulatory effects than SNPs or indels.

Effect-size analyses are complementary to eQTL discovery. While eQTL mapping identifies significant variant-gene associations, effect-size analysis focuses on how large and in which direction those effects are.

## Input data

Typical input files include:

```text
cis-eQTL summary statistics
lead eVariant or significant eVariant list
eGene list
variant annotation table
variant class information, such as SNP, indel, and SV
normalized expression matrix
sample genotype matrix or dosage file
```

For tissue-specific analyses, inputs should be prepared separately for each tissue.

## Main workflow

### 1. Collect significant eQTL results

Start from cis-eQTL mapping results generated in `08_eqtl_mapping/`.

Typical input files include:

```text
nominal cis-eQTL results
gene-level significant eQTL results
lead eVariant per eGene
variant-level effect estimates
```

The lead eVariant for each eGene can be used to summarize the primary regulatory effect.

### 2. Annotate variant classes

Each eVariant is annotated by variant type.

Typical variant classes include:

- SNP
- indel
- SV
- INS
- DEL
- repeat-associated SV
- non-repeat SV

This step allows comparison of effect-size distributions across variant classes.

### 3. Estimate allelic fold change

Allelic fold change measures the expression difference associated with alternative alleles.

Typical analyses include:

- estimate effect size from genotype-expression regression
- calculate allelic fold change for significant eVariants
- summarize effect direction, positive or negative
- compare absolute effect sizes among SNPs, indels, and SVs

### 4. Summarize lead eVariant effect sizes

For each eGene, the lead eVariant can be selected and used for downstream summary.

Typical summaries include:

- effect-size distribution of lead eSNPs, eIndels, and eSVs
- absolute effect-size comparison among variant classes
- tissue-specific effect-size patterns
- distance between eVariants and transcription start sites

### 5. Compare large-effect and small-effect variants

Variants can be grouped by effect size to evaluate enrichment or biological relevance.

Typical analyses include:

- define large-effect and small-effect eVariants
- compare functional annotations between effect-size groups
- evaluate whether SVs are enriched among large-effect regulatory variants
- summarize effect-size patterns around regulatory genomic features

### 6. Visualize effect-size patterns

Typical figures include:

```text
boxplots of absolute effect sizes by variant class
density plots of eQTL effect-size distributions
distance-to-TSS plots
LOESS curves of effect size along genomic distance
barplots of large-effect eVariant proportions
```

## Outputs

Typical outputs from this module include:

```text
variant-class annotated eQTL table
lead eVariant effect-size table
allelic fold-change table
tissue-specific effect-size summaries
large-effect and small-effect eVariant lists
effect-size comparison figures
```

## Connection to other modules

This module mainly uses outputs from:

```text
08_eqtl_mapping/
09_ase_analysis/
04_ld_and_feature_annotation/
```

The effect-size summaries can be integrated with ASE, chromatin-state annotations, repeat annotations, and SV-eQTL examples to support interpretation of candidate regulatory SVs.

## Notes

- Effect-size analysis should be performed separately for each tissue before cross-tissue comparison.
- Variant class annotation must be consistent with the SV, SNP, and indel definitions used in eQTL mapping.
- Direction of effect depends on allele coding, so genotype coding and reference/alternative allele definitions should be checked before biological interpretation.
- Absolute effect size is useful for comparing effect magnitude, whereas signed effect size is needed for interpreting directionality.
