#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 05_impute_target_samples.sh
# Impute target samples using the phased SNP-SV reference panel
# ============================================================

THREADS=10
BEAGLE=/path/to/beagle.jar

REFDIR=04_phased_reference_panel
TARGET_DIR=target_chip_snp_vcf
OUTDIR=05_imputed_target

mkdir -p ${OUTDIR}

# Example:
# target genotype file should contain SNPs available in chip or low-density genotype data.
# Replace TARGET_PREFIX according to the target dataset, such as HiFi validation samples or 50K-array samples.
TARGET_PREFIX=chip.target

for CHR in {1..18}
do
    echo "Imputing chromosome ${CHR}"

    java -jar ${BEAGLE} \
        gt=${TARGET_DIR}/${TARGET_PREFIX}.chr${CHR}.vcf.gz \
        ref=${REFDIR}/panel_2337.chr${CHR}.snp.sv.phased.final.vcf.gz \
        out=${OUTDIR}/${TARGET_PREFIX}.panel_2337.chr${CHR}.snp.sv.imputed \
        impute=true \
        ap=true \
        gp=true \
        seed=1234 \
        ne=1000 \
        nthreads=${THREADS}
done
