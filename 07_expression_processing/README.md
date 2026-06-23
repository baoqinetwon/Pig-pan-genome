# 07_expression_processing

RNA-seq expression quantification and preprocessing for downstream eQTL mapping.

This module contains scripts and workflow notes for processing RNA-seq data from multiple pig tissues, generating gene-level expression matrices, normalizing expression values, and preparing phenotype files required by OmiGA cis-eQTL mapping.

## Purpose

The goal of this module is to generate high-quality, normalized gene expression phenotypes from RNA-seq data. These expression phenotypes are used in downstream analyses, especially:

- tissue-specific expression profiling
- expression PCA or sample-level quality control
- preparation of eQTL phenotype BED files
- generation of normalized expression matrices for cis-eQTL mapping

## Input data

Typical input files include:

```text
RNA-seq FASTQ files
reference genome FASTA
reference gene annotation file, such as Ensembl Sscrofa11.1 v113 GTF/GFF3
sample information table
sample-to-tissue metadata
```

For eQTL analysis, only individuals with matched genotype and RNA-seq data should be retained.

## Main workflow

### 1. RNA-seq read preprocessing and quality control

Raw RNA-seq reads are first checked and cleaned when necessary.

Typical steps include:

- check raw read quality
- remove low-quality reads or adapters if needed
- summarize sequencing quality for each sample
- confirm sample and tissue labels

### 2. RNA-seq alignment and transcript quantification

Clean RNA-seq reads are aligned to the pig reference genome using STAR, and gene-level read counts are generated from the aligned BAM files using featureCounts.

Typical outputs include:

```text
aligned BAM files
per-sample gene count files
mapping statistics
```

The reference annotation used in this study is based on Ensembl Sscrofa11.1 gene annotation, version 113.

### 3. Gene-level read count matrix construction

Per-sample gene counts are merged into tissue-specific gene expression matrices.

Typical output:

```text
${tissue}.gene.counts.txt
```

Rows represent genes and columns represent RNA-seq samples.

### 4. Expression filtering

Lowly expressed genes are removed before normalization and eQTL mapping. Filtering is performed separately for each tissue.

The expression thresholds used in this study were:

```python
count_threshold = 6
tpm_threshold = 0.1
sample_frac_threshold = 0.2
sample_count_threshold = 10
```

Genes were retained if they satisfied both expression criteria in a sufficient number of samples:

```text
TPM >= 0.1 and read count >= 6 in at least 20% of samples
```

A minimum of 10 samples was also required when applying the sample-count threshold. In practice, the required number of samples was defined as the larger value between 20% of the tissue sample size and 10 samples.

### 5. Expression normalization

After expression filtering, gene expression levels were quantile-normalized for downstream cis-eQTL mapping.

In this study, quantile normalization was performed in R using the `qqnorm` function.

Common outputs include:

```text
TPM expression matrix
filtered expression matrix
quantile-normalized expression matrix
```

The quantile-normalized matrix is used to prepare the phenotype BED file for cis-eQTL mapping.

### 6. Phenotype BED preparation for OmiGA

The normalized expression matrix is converted into OmiGA-compatible BED format.

The phenotype BED file should contain gene genomic coordinates followed by normalized expression values across samples.

Example output:

```text
omiga_${tissue}.expression.bed.gz
```

This file is used as the `--phenotype` input in OmiGA.

### 7. Expression quality control and visualization

Expression matrices can be evaluated using sample-level visualization and clustering.

Typical analyses include:

- PCA of expression profiles
- t-SNE or other dimension-reduction visualization
- tissue-specific clustering
- identification of outlier RNA-seq samples

## Outputs

Typical outputs from this module include:

```text
per-sample RNA-seq QC summaries
gene read count matrices
TPM expression matrices
filtered expression matrices
quantile-normalized expression matrices
OmiGA-compatible expression BED files
expression PCA or t-SNE result files
```

## Connection to eQTL mapping

The final expression BED files generated here are used in `08_eqtl_mapping/` for OmiGA cis-eQTL analysis.

Example:

```bash
OmiGA --mode cis \
    --genotype 02_genotype/joint3.filled \
    --phenotype 01_phenotype/omgia_duodenum.expression.bed.gz \
    --covariates 03_covariant/Cov_duodenum.txt \
    --prefix joint \
    --output-dir j3_duodenum_cis
```

## Software installation

RNA-seq processing tools can be installed with conda:

```bash
conda create -n expression_processing -c conda-forge -c bioconda \
    fastp=0.22.0 star=2.7.9a subread=2.0.6 stringtie=2.1.7 samtools
```

R packages for expression normalization and matrix processing can be installed in R as needed:

```r
install.packages(c("data.table", "dplyr", "tidyr"))
```

## Notes

- Expression processing should be performed separately for each tissue.
- Genes were retained with TPM >= 0.1 and read count >= 6 in at least 20% of samples, with a minimum of 10 samples.
- Quantile normalization of gene expression levels was performed using the `qqnorm` function in R.
- Sample IDs must be consistent between genotype files, expression matrices, covariate files, and phenotype BED files.
- Gene coordinates in the phenotype BED file must match the genome build used for genotype data.
