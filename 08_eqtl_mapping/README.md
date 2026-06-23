# 08_eqtl_mapping

This module contains scripts for joint-variant cis-eQTL mapping using OmiGA.

## Main scripts

### 1. `cis_eqtl_mapping.sh`

Run standard cis-QTL mapping by chromosome and then perform multiple-testing correction.

The workflow includes two steps:

1. Standard cis-QTL mapping using `OmiGA --mode cis`
2. Multiple-testing correction using `OmiGA --mode cis_mt` with `--multiple-testing clipper`

Example settings in the script:

```bash
GENOTYPE="02_genotype/joint3.filled"
PHENOTYPE="01_phenotype/omgia_duodenum.expression.bed.gz"
COVARIATES="03_covariant/Cov_duodenum.txt"
CIS_OUTDIR="j3_duodenum_cis"
MT_OUTDIR="duodenum_cis_eqtl_joint_clipper"
```

The standard cis-QTL mapping step is run by chromosome using:

```bash
seq 1 18 | xargs -I {} -P 8 bash -c '...'
```

This allows chromosomes 1–18 to be processed in parallel.

### 2. `conditional_independent_cis_eqtl.sh`

Run conditional independent cis-QTL mapping using `OmiGA --mode cis_independent`.

This step takes the standard cis-QTL result file as input:

```bash
--cis-file 01_cis_eqtl/joint.cis_qtl.txt.gz
```

and identifies conditionally independent cis-QTL signals using:

```bash
--qtl-map-model a+A
```

Example settings in the script:

```bash
GENOTYPE="../01_raw_gt_maf005_geno01_biallele/02_rmMiss/joint.filled"
PHENOTYPE="tLiver.expr_tmm_qt.bed.gz"
COVARIATES="Cov_liver.txt"
OUTDIR="02_condition_independ_cis_eqtl"
```

## Software installation

OmiGA was used for cis-eQTL mapping. According to the official OmiGA documentation, OmiGA should be installed by downloading the precompiled binaries and configuring the executable following the installation manual:

```text
https://omiga.bio/#/Download
https://omiga.bio/#/Installation
```

A typical setup is:

```bash
# Download the OmiGA binary package from the official download page,
# then unpack it and add the executable directory to PATH.
export PATH=/path/to/OmiGA/bin:$PATH

OmiGA --help
```

Other command-line dependencies can be installed with conda:

```bash
conda create -n eqtl_mapping -c conda-forge -c bioconda bcftools=1.13
```

## Notes

- Replace the genotype, phenotype, covariate, and output paths according to tissue and analysis batch.
- Install OmiGA from the official precompiled binary package rather than from `pip`.
- The `cis_eqtl_mapping.sh` script is used for standard cis-eQTL discovery and multiple-testing correction.
- The `conditional_independent_cis_eqtl.sh` script is used as a separate downstream step for conditional independent cis-QTL mapping.
