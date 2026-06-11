# 03_population_sv_analysis

This module contains downstream population-genomic analyses based on the curated population-scale SV dataset.

SV discovery itself is not included in this module. Population-scale ONT SV discovery using Sniffles2 multi-sample calling is maintained in:

```bash
01_sv_discovery/multi_sample_sniffles2_calling.sh
```

## Input data

The main input is a population-level SV VCF after SV discovery and primary quality control.

Typical input files include:

- population-level SV VCF
- sample information table
- population or breed grouping file
- genome chromosome length file
- optional genomic annotation files

## Main workflow

### 1. SV VCF preprocessing

Prepare the SV VCF for population-genomic analyses.

Typical steps include:

- retain autosomal SVs
- remove low-quality or highly missing variants
- retain target SV types when needed, such as INS and DEL
- normalize or simplify variant IDs
- generate analysis-ready VCF/PLINK files

### 2. Allele-frequency and SV distribution analyses

Summarize SV frequency and genomic distribution across populations or breeds.

Typical analyses include:

- allele-frequency estimation
- breed- or population-level SV counts
- SV density along chromosomes
- SV type and length distribution

### 3. Population structure analyses

Use SV genotypes to infer population relationships.

Typical analyses include:

- PCA
- phylogenetic tree construction
- admixture or ancestry component analysis

### 4. Population differentiation analyses

Identify differentiated SVs or genomic regions between populations.

Typical analyses include:

- pairwise Fst calculation
- window-based Fst summarization
- extraction of highly differentiated SVs or candidate regions

## Outputs

Typical outputs include:

```text
filtered population SV VCFs
SV allele-frequency tables
SV density statistics
PCA input and result files
phylogenetic tree files
admixture result files
Fst statistics and candidate differentiated regions
```

## Notes

- This directory is intended for downstream population-genomic analyses after SV discovery.
- Population-scale ONT SV calling is handled in `01_sv_discovery/`.
- PacBio long-read SV detection is handled in `01_sv_discovery/longread_sv_detection.sh`.
- Scripts in this module may require local adjustment of VCF paths, sample grouping files, chromosome names, and software paths before running.
