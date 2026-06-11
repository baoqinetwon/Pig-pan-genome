# 13_panel_imputation

PGVRP reference panel construction and SV genotype imputation.

This directory contains the main scripts used to construct the SNP-SV reference panel, phase the panel, impute target samples, and summarize imputation results. In this workflow, the final SNP-SV reference panel is referred to as **PGVRP**.

## Main workflow

### 1. Prepare SNP panel

```bash
bash 01_prepare_snp_panel.sh
```

This step merges SNP VCFs from multiple cohorts, reheaders the merged VCF, converts the VCF to PLINK format, and performs sample-level QC using heterozygosity and IBD statistics.

Main output:

```text
PGVRP_panel.sample.sorted.txt
```

### 2. Filter SV panel

```bash
bash 02_filter_sv_panel.sh
```

This step filters the raw SV VCF and keeps high-confidence SVs for PGVRP construction.

Main filters include:

```text
INS and DEL only
autosomal chromosomes
SV length >= 50 bp
SV length <= 30 Mb
remove very rare alleles, such as AC = 1 or AC = 2
retain PGVRP samples
missing rate <= 20%
biallelic SVs only
```

Main output:

```text
02_sv_qc/PGVRP.chr1-18.sv.only_bi.vcf.gz
```

### 3. Merge SNPs and SVs by chromosome

```bash
bash 03_merge_snp_sv_by_chr.sh
```

This step extracts SNPs and SVs from the same PGVRP sample set and merges them into chromosome-level SNP-SV VCF files.

Main output:

```text
03_chr_snp_sv/PGVRP.chr${CHR}.snp.sv.sorted.vcf.gz
```

### 4. Phase the PGVRP reference panel

```bash
bash 04_phase_reference_panel.sh
```

This step phases and self-imputes the chromosome-level SNP-SV VCFs using Beagle, then generates the final phased PGVRP reference panel.

Main output:

```text
04_phased_reference_panel/PGVRP.chr${CHR}.snp.sv.phased.final.vcf.gz
```

### 5. Impute target samples

```bash
bash 05_impute_target_samples.sh
```

This step uses the phased PGVRP reference panel to impute target samples, such as HiFi-derived chip SNP genotypes or array-genotyped cohorts.

Main output:

```text
05_imputed_target/${TARGET_PREFIX}.PGVRP.chr${CHR}.snp.sv.imputed.vcf.gz
```

### 6. Extract imputation summary

```bash
bash 06_extract_imputation_summary.sh
```

This step summarizes the imputed results, including SNP/SV extraction, DR2, MAF, and genotype matrices for downstream evaluation.

Main outputs:

```text
06_imputation_summary/${TARGET_PREFIX}.chr${CHR}.snp.imputed.maf.vcf.gz
06_imputation_summary/${TARGET_PREFIX}.chr${CHR}.sv.imputed.maf.vcf.gz
06_imputation_summary/${TARGET_PREFIX}.chr${CHR}.snp.sv.DR2_MAF.txt
06_imputation_summary/${TARGET_PREFIX}.chr${CHR}.sv.DR2_MAF.txt
06_imputation_summary/${TARGET_PREFIX}.chr${CHR}.sv.imputed.genotypes.txt
```

## Run order

The full panel-construction workflow can be run with:

```bash
bash run_13_panel_imputation.sh
```

Target-sample imputation and summary extraction should be run after target SNP VCFs are prepared.

## Notes

- `PGVRP` is used consistently as the reference panel name in this directory.
- Replace Beagle paths, input VCF paths, headers, sample lists, and target genotype prefixes before running.
- Chromosome-level analysis is performed for autosomes 1-18 in the provided scripts.
