# 02_snp_indel_discovery

This module contains scripts for SNP and Indel discovery from genome assemblies and long-read sequencing data.

## Main scripts

### 1. `longread_snp_indel_detection.sh`

Detect SNPs and Indels from long-read sequencing data.

The script supports two long-read data types:

1. PacBio HiFi reads
2. Oxford Nanopore Technologies (ONT) reads

Set `READ_TYPE=HIFI` or `READ_TYPE=ONT` before running.

---

## PacBio HiFi SNP/Indel calling

For PacBio HiFi data, the workflow includes two steps:

1. Align HiFi reads to the reference genome using `pbmm2 align --preset HIFI`
2. Call SNPs and Indels from the sorted BAM file using DeepVariant with `--model_type=PACBIO`

Example alignment command:

```bash
pbmm2 align \
    --preset HIFI \
    -j 52 \
    --sort \
    --sort-threads 52 \
    --sample BMA \
    /path/to/Duroc.mmi \
    BMA_hifi.fastq.gz \
    01_bam/BMA_pbmm.bam
```

Example DeepVariant command using GPU Singularity image:

```bash
singularity exec --nv --network=none -n deepvariant-gpu.1.4.0.sif \
    run_deepvariant \
    --model_type=PACBIO \
    --ref=/path/to/Duroc.fa \
    --reads=01_bam/BMA_pbmm.bam \
    --output_vcf=02_variant_calling/BMA.hifi.deepvariant.vcf.gz \
    --num_shards=52
```

---

## ONT SNP/Indel calling

For ONT long-read data, SNPs and Indels are detected using Clair3:

- https://github.com/HKU-BAL/Clair3

The ONT workflow includes two steps:

1. Align ONT reads to the reference genome using `minimap2 -x map-ont`
2. Call SNPs and Indels using Clair3 with an ONT model

Example ONT alignment command:

```bash
minimap2 \
    -ax map-ont \
    -t 52 \
    /path/to/Duroc.fa \
    sample.ont.fastq.gz \
| samtools sort \
    -@ 52 \
    -o 01_bam/sample.ont.minimap2.bam

samtools index -@ 52 01_bam/sample.ont.minimap2.bam
```

Example Clair3 command:

```bash
run_clair3.sh \
    --bam_fn=01_bam/sample.ont.minimap2.bam \
    --ref_fn=/path/to/Duroc.fa \
    --threads=52 \
    --platform=ont \
    --model_path=/path/to/clair3/ont/model \
    --output=02_variant_calling/sample.ont.clair3
```

## Inputs

- Long-read FASTQ files, including PacBio HiFi or ONT reads
- Reference genome FASTA, for example `Duroc.fa`
- pbmm2/minimap2 index for HiFi alignment, for example `Duroc.mmi`
- DeepVariant GPU Singularity image for PacBio HiFi SNP/Indel calling
- Clair3 and ONT model for ONT SNP/Indel calling

## Outputs

- Sorted BAM files:

```bash
01_bam/${SAMPLE}_pbmm.bam
01_bam/${SAMPLE}.ont.minimap2.bam
```

- SNP/Indel calling results:

```bash
02_variant_calling/${SAMPLE}.hifi.deepvariant.vcf.gz
02_variant_calling/${SAMPLE}.ont.clair3/
```

## Notes

- PacBio HiFi SNP/Indel calling uses DeepVariant with the `PACBIO` model.
- ONT SNP/Indel calling uses Clair3 with `--platform=ont`.
- GPU acceleration for DeepVariant is enabled by adding `--nv` to `singularity exec`.
- Replace sample names, reference paths, index paths, Singularity image paths, and Clair3 model paths according to the local computing environment.
