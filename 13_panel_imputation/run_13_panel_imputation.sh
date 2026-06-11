#!/usr/bin/env bash
set -euo pipefail

# Run the complete panel construction and imputation workflow.
# Edit paths and input file names in each sub-script before running.

bash 01_prepare_snp_panel.sh
bash 02_filter_sv_panel.sh
bash 03_merge_snp_sv_by_chr.sh
bash 04_phase_reference_panel.sh

# The following two scripts are for target-sample imputation and summary extraction.
# Run them after preparing target SNP VCFs.
# bash 05_impute_target_samples.sh
# bash 06_extract_imputation_summary.sh
