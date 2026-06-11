# 03_population_sv_analysis

This module contains downstream population-genomic analyses based on the curated population-scale SV dataset.

SV discovery itself is not included in this module. Population-scale ONT SV discovery using Sniffles2 multi-sample calling is maintained in:

```bash
01_sv_discovery/multi_sample_sniffles2_calling.sh
```

## Main analyses

This module only retains the following population-genomic analyses:

1. PCA
2. Phylogeny
3. Admixture
4. Fst analysis

## Input data

Typical input files include:

- population-level SV genotype file
- sample information table
- population or breed grouping file

## Workflow overview

### 1. PCA

Use SV genotypes to perform principal component analysis and summarize the major axes of genetic variation among populations or breeds.

### 2. Phylogeny

Construct phylogenetic relationships among samples or populations based on SV genotype data.

### 3. Admixture

Estimate ancestry components and population structure using SV genotype data.

### 4. Fst analysis

Calculate population differentiation statistics and identify highly differentiated SVs or genomic regions between populations.

## Outputs

Typical outputs include:

```text
PCA result files
phylogenetic tree files
admixture result files
Fst statistics and candidate differentiated regions
```

## Notes

- This directory is intended only for PCA, phylogeny, admixture, and Fst analysis based on SV genotypes.
- SV discovery is handled in `01_sv_discovery/`.
- Scripts in this module may require local adjustment of VCF paths, sample grouping files, chromosome names, and software paths before running.
