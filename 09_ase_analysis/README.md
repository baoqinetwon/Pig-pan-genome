# 09_ase_analysis

Allele-specific expression (ASE) and allelic fold-change analysis using matched RNA-seq and genotype data.

This module describes the ASE workflow used in this study. The main analysis is based on a masked reference genome, STAR RNA-seq mapping, read-backed haplotype phasing, gene-level haplotypic expression counting, and cis-variant allelic fold-change estimation.

## Main workflow

### 1. Build a SNP-masked reference genome

To reduce reference-mapping bias in RNA-seq alignment, known SNP sites were used to mask the reference genome before STAR mapping.

First, split the filtered SNP VCF by chromosome:

```bash
for chr in {1..18} X; do
    vcftools \
        --gzvcf jx_268.snp.filtered_fY.sort.vcf.gz \
        --chr ${chr} \
        --recode \
        --recode-INFO-all \
        --stdout \
    | bgzip -@ 8 -c > jx268_chr${chr}.vcf.gz
done
```

Then generate masked chromosome FASTA files:

```bash
for chr in {1..18} X; do
    bedtools maskfasta \
        -fi ~/PGG_netwon/final_merge/backone_genome/new/${chr}.fa \
        -fo chr${chr}.masked.fa \
        -bed jx268_chr${chr}.vcf.gz
done
```

The masked chromosome FASTA files are then merged into a combined masked reference genome, for example:

```text
ss11_masked_chr1-X.fa
```

### 2. Build STAR index from the masked genome

STAR genome index was built using the masked reference genome and gene annotation file.

```bash
STAR \
    --runThreadN 16 \
    --runMode genomeGenerate \
    --genomeDir ./ \
    --genomeFastaFiles ss11_masked_chr1-X.fa \
    --sjdbGTFfile Sus_scrofa.Sscrofa11.1.100_chr1-X.gtf
```

### 3. Map RNA-seq reads using STAR

Clean paired-end RNA-seq reads were mapped to the masked genome using STAR.

```bash
ls *_1_clean.fq.gz | while read i; do
    i=${i/_1_clean.fq.gz/}

    STAR \
        --runThreadN 8 \
        --genomeDir /public/home/baoqi/SRWHS/jiangxi_tran/genome \
        --sjdbGTFfile /public/home/baoqi/SRWHS/jiangxi_tran/genome/Sus_scrofa.Sscrofa11.1.100_chr1-X.gtf \
        --quantMode TranscriptomeSAM \
        --outSAMtype BAM SortedByCoordinate \
        --outSAMunmapped Within \
        --readFilesCommand zcat \
        --outFilterMismatchNmax 3 \
        --readFilesIn ${i}_1_clean.fq.gz ${i}_2_clean.fq.gz \
        --outFileNamePrefix ./${i}-STAR \
        --outTmpDir ~/SRWHS/jiangxi_tran/clean/tmp/ \
        --limitBAMsortRAM 120000000000
done
```

### 4. Add read groups and mark duplicates

Read groups were added to the STAR-aligned BAM files, followed by duplicate marking.

```bash
ls *unique.bam | while read id; do
    gatk AddOrReplaceReadGroups \
        -I ${id} \
        -O ${id}_rg_added.bam \
        -RGID 4 \
        -RGLB lib1 \
        -RGPL illumina \
        -RGPU run \
        -RGSM 20 \
        -CREATE_INDEX true \
        -VALIDATION_STRINGENCY SILENT \
        -SORT_ORDER coordinate
done
```

```bash
ls *added.bam | while read id; do
    gatk MarkDuplicates \
        -I ${id} \
        -O ${id}.dedup.bam \
        -CREATE_INDEX true \
        -VALIDATION_STRINGENCY SILENT \
        --READ_NAME_REGEX null \
        -M dedupped_${id}-STARsorted.unique.marked_dup_metrics.txt
done
```

### 5. Haplotype phasing with `phaser.py`

Read-backed haplotype phasing was performed using RNA-seq BAM files and the phased SNP VCF.

```bash
python /public/home/baoqi/SRWHS/jiangxi_tran/bam/bam268/phaser.py \
    --bam ../SAMEA111507628-STARAligned.sortedByCoord.out.bam.unique.bam_rg_added.bam.dedup.bam \
    --sample SAMEA111507327 \
    --o ph_SAMEA111507327 \
    --vcf span298_snp.phasing.sort.vcf.gz \
    --paired_end 1 \
    --mapq 255 \
    --baseq 10 \
    --threads 8 \
    --temp_dir tmp2 \
    --gw_phase_vcf 1 \
    --write_vcf 0 \
    --output_read_ids 0
```

Main inputs:

```text
RNA-seq deduplicated BAM
phased SNP VCF
sample ID
```

Main outputs:

```text
sample-level haplotypic count files
read-backed phased ASE information
```

### 6. Generate gene-level haplotypic expression counts

Gene-level haplotype counts were generated using `phaser_gene_ae.py` and gene coordinates.

```bash
ls *txt | while read id; do
    python phaser_gene_ae.py \
        --haplotypic_counts ${id} \
        --features gene.sort.bed \
        --o ${id}.genease.txt
done
```

Here, `gene.sort.bed` contains sorted gene-level genomic intervals.

### 7. Merge gene-level ASE results across samples

Gene-level haplotypic expression results from all samples were merged into a matrix.

```bash
python phaser_expr_matrix.py \
    --gene_ae_dir dirfile \
    --features gene.sort.bed \
    --t 5 \
    --o phaser_expr.298
```

`dirfile` is the directory containing all sample-level `phaser.gene_ae.txt` files.

### 8. Calculate cis-variant allelic fold change

Allelic fold change for cis variants was calculated using `phaser_cis_var.py`.

```bash
python phaser_cis_var.py \
    --bed span298_ase.gw_phased.bed.gz \
    --vcf span298_snp.phasing.sort.vcf.gz \
    --pairs liver_cisqtl.txt \
    --map sample.map.txt \
    --o liver_aFC.txt \
    --t 16
```

Main inputs:

```text
span298_ase.gw_phased.bed.gz
span298_snp.phasing.sort.vcf.gz
cis-QTL pair file
sample map file
```

Main output:

```text
liver_aFC.txt
```

## Outputs

Typical outputs from this module include:

```text
masked reference genome
STAR genome index
STAR-aligned RNA-seq BAM files
read-group-added BAM files
deduplicated BAM files
sample-level phaser output
gene-level ASE count files
merged gene-level haplotypic expression matrix
cis-variant allelic fold-change table
```

## Notes

- The SNP-masked genome is used to reduce reference allele mapping bias in ASE analysis.
- STAR mapping is performed against the masked reference genome.
- `phaser.py` uses RNA-seq reads and phased SNP genotypes to assign reads to haplotypes.
- `phaser_gene_ae.py` summarizes haplotypic read counts at the gene level.
- `phaser_expr_matrix.py` merges gene-level ASE results across samples.
- `phaser_cis_var.py` calculates allelic fold change for cis-regulatory variant-gene pairs.
- Sample IDs must be consistent among BAM files, phased VCF files, cis-QTL pair files, and sample mapping files.
