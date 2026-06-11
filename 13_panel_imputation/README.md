# 13_panel_imputation

This directory contains the main scripts used for SNP–SV reference panel construction and downstream genotype imputation.

## Workflow

1. `01_prepare_snp_panel.sh`  
   Merge SNP VCFs from multiple cohorts, reheader, sort samples, and perform sample-level QC using heterozygosity and IBD.

2. `02_filter_sv_panel.sh`  
   Filter SVs to retain autosomal biallelic INS/DEL variants with appropriate length, allele count, and missing rate.

3. `03_merge_snp_sv_by_chr.sh`  
   Extract SNPs and SVs from the same sample set and merge them into chromosome-level SNP–SV VCF files.

4. `04_phase_reference_panel.sh`  
   Phase and self-impute the SNP–SV panel using Beagle, then generate final chromosome-level phased reference panel VCFs.

5. `05_impute_target_samples.sh`  
   Use the phased SNP–SV reference panel to impute target samples, such as HiFi-derived chip SNP genotypes or array-genotyped cohorts.

6. `06_extract_imputation_summary.sh`  
   Extract imputed SNP/SV files, DR2, MAF, and genotype matrices for downstream evaluation.

## Final panel output

The final reference panel files are:

```bash
panel_2337_reference/panel_2337.chr${CHR}.snp.sv.phased.final.vcf.gz
```

These phased SNP–SV VCFs are used as the reference panel for downstream genotype imputation.
