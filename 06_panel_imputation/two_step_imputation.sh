#!/usr/bin/env bash
# Two-step SNP/SV imputation workflow.
# Source file: impute.two_step.sh
# Adapt paths, reference files, and sample lists before running.
set -euo pipefail

#SBATCH --job-name=imputed
#SBATCH --partition=low,big,amd
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --error=chr%a_%j.err
#SBATCH --output=chr%a_%j.out
#SBATCH --array=1-18

CHROM=${SLURM_ARRAY_TASK_ID:-1}

chip_dir="/path/to/chip_vcf"
panel_dir="/path/to/reference_panel"
out_dir="/path/to/output"
beagle_jar="/path/to/beagle.jar"

mkdir -p ${out_dir}/two ${out_dir}/snp_output ${out_dir}/sv_output

tabix -p vcf -f ${panel_dir}/chr${CHROM}.vcf.gz

# First step: impute chip SNPs against the SNP/SV panel.
java -jar ${beagle_jar} \
    gt=${chip_dir}/sample.snp.chr${CHROM}.phased.vcf.gz \
    ref=${panel_dir}/chr${CHROM}.vcf.gz \
    out=${out_dir}/chr${CHROM}.snp_sv_imputed_step1 \
    impute=true \
    ap=true \
    gp=true \
    seed=1234 \
    ne=1000 \
    nthreads=10

tabix -p vcf -f ${out_dir}/chr${CHROM}.snp_sv_imputed_step1.vcf.gz

bcftools +fill-tags ${out_dir}/chr${CHROM}.snp_sv_imputed_step1.vcf.gz \
    -Oz -o ${out_dir}/chr${CHROM}.snp_sv_imputed_step1.maf.vcf.gz -- -t MAF

bcftools view -v snps ${out_dir}/chr${CHROM}.snp_sv_imputed_step1.maf.vcf.gz \
    -Oz -o ${out_dir}/two/chr${CHROM}.snp_imputed_step1.maf.vcf.gz

# Retain high-confidence SNPs for second-step SV imputation.
bcftools filter -i 'INFO/DR2 >= 0.99 && INFO/MAF >= 0.01' --threads 10 \
    -Oz -o ${out_dir}/two/chr${CHROM}.snp_imputed_step1.maf.DR2_99.vcf.gz \
    ${out_dir}/two/chr${CHROM}.snp_imputed_step1.maf.vcf.gz

tabix -p vcf -f ${out_dir}/two/chr${CHROM}.snp_imputed_step1.maf.DR2_99.vcf.gz

# Second step: SV imputation.
java -jar ${beagle_jar} \
    gt=${out_dir}/two/chr${CHROM}.snp_imputed_step1.maf.DR2_99.vcf.gz \
    ref=${panel_dir}/chr${CHROM}.vcf.gz \
    out=${out_dir}/two/chr${CHROM}.snp_sv_imputed_step2 \
    impute=true \
    ap=true \
    gp=true \
    seed=1234 \
    ne=1000 \
    nthreads=10

tabix -p vcf -f ${out_dir}/two/chr${CHROM}.snp_sv_imputed_step2.vcf.gz

bcftools +fill-tags ${out_dir}/two/chr${CHROM}.snp_sv_imputed_step2.vcf.gz \
    -Oz -o ${out_dir}/two/chr${CHROM}.snp_sv_imputed_step2.maf.vcf.gz -- -t MAF

# Extract SVs and filter by DR2.
bcftools view -i 'INFO/SVTYPE="INS" || INFO/SVTYPE="DEL"' \
    ${out_dir}/two/chr${CHROM}.snp_sv_imputed_step2.maf.vcf.gz \
    -Oz -o ${out_dir}/sv_output/chr${CHROM}.sv_imputed.vcf.gz

bcftools filter -i 'INFO/DR2 >= 0.60' --threads 10 \
    -Oz -o ${out_dir}/sv_output/chr${CHROM}.sv_imputed.DR2_60.vcf.gz \
    ${out_dir}/sv_output/chr${CHROM}.sv_imputed.vcf.gz
