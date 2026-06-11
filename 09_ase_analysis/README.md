# 09_ase_analysis

Allele-specific expression (ASE) analysis using RNA-seq data and matched genotype data.

This module contains scripts and workflow notes for detecting allele-specific expression at heterozygous variants and summarizing ASE signals across tissues, genes, and variant classes.

## Purpose

ASE analysis is used to evaluate whether the two alleles of a gene show imbalanced expression within the same individual. Compared with standard eQTL mapping, ASE analysis is less affected by between-individual environmental or trans effects and can provide complementary evidence for cis-regulatory effects of nearby variants, including SVs.

## Input data

Typical input files include:

```text
RNA-seq BAM files
matched genotype VCF
sample information table
gene annotation file
phased genotype file, optional
list of heterozygous sites per sample
```

The genotype and RNA-seq sample IDs should be consistent. ASE analysis should be performed only for individuals with matched genotype and RNA-seq data.

## Main workflow

### 1. Prepare matched samples

Match RNA-seq samples to genotype samples and generate a tissue-specific sample list.

Typical steps include:

- confirm sample identity between WGS and RNA-seq data
- retain samples with both genotype and RNA-seq data
- split samples by tissue when needed
- prepare sample metadata for downstream grouping

### 2. Select informative heterozygous sites

ASE is evaluated at heterozygous variants because both alleles are present in the same individual.

Typical steps include:

- extract heterozygous SNPs or small variants for each sample
- optionally restrict sites to genes or exonic regions
- remove low-quality genotype sites
- keep sites with sufficient RNA-seq read coverage

### 3. Count allele-specific RNA-seq reads

For each heterozygous site, count reads supporting the reference and alternative alleles from RNA-seq alignments.

Typical outputs include:

```text
sample-level allele count table
ref allele read count
alt allele read count
total allele-specific read depth
```

Common filters include:

- minimum total read depth
- minimum allele-specific read count
- mapping quality filter
- base quality filter
- removal of sites with severe mapping bias when applicable

### 4. Test allelic imbalance

Allelic imbalance can be evaluated at the variant level or aggregated at the gene level.

Typical analyses include:

- binomial test or beta-binomial test for allele imbalance
- gene-level aggregation of ASE sites
- multiple-testing correction within tissue or gene sets
- identification of ASE genes in each tissue

### 5. Summarize ASE by gene and tissue

ASE signals are summarized across samples and tissues.

Typical summaries include:

- number of ASE sites per sample
- number of ASE genes per tissue
- overlap of ASE genes among tissues
- allele imbalance direction and magnitude
- consistency between ASE signals and cis-eQTL results

### 6. Integrate ASE with SV and eQTL results

ASE results can be combined with SV-eQTL analysis to provide additional support for cis-regulatory SVs.

Typical integration analyses include:

- overlap between ASE genes and eGenes
- ASE patterns near lead eVariants or eSVs
- comparison of allelic imbalance across genotype groups
- prioritization of candidate regulatory SVs supported by both eQTL and ASE evidence

## Outputs

Typical outputs from this module include:

```text
matched RNA-seq and genotype sample list
heterozygous site list per sample
allele-specific read count table
variant-level ASE test result
gene-level ASE summary table
tissue-specific ASE gene list
ASE and eQTL overlap summary
figures summarizing ASE patterns
```

## Notes

- ASE analysis should be performed separately for each tissue.
- Genotype, RNA-seq BAM, and gene annotation files must use the same genome build and chromosome naming style.
- Only heterozygous sites are informative for ASE analysis.
- Sites with low RNA-seq coverage should be removed before allelic imbalance testing.
- ASE results are best interpreted together with cis-eQTL mapping, SV annotation, and candidate regulatory variant analyses.
