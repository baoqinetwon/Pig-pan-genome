# 01_sv_discovery

This module contains scripts for long-read and assembly-based structural variant discovery.

## Main workflows

### 1. Population-scale ONT SV discovery using Sniffles2

`multi_sample_sniffles2_calling.sh` is used for multi-sample SV calling from population-scale ONT data.

The workflow includes two steps:

1. Generate one `.snf` file for each ONT sample using Sniffles2
2. Jointly call SVs across all samples from the SNF file list

Input BAM list format:

```text
sample_id    path/to/sample.bam
```

Example:

```text
Duroc001     01_bam/Duroc001.ont.minimap2.bam
```

Example usage:

```bash
BAM_LIST=bam.list \
OUTDIR=sniffles2_multisample \
THREADS=16 \
bash multi_sample_sniffles2_calling.sh
```

Main output:

```bash
sniffles2_multisample/population/population.sv.vcf.gz
```

### 2. PacBio long-read SV detection

`longread_sv_detection.sh` is used for per-sample SV detection from PacBio long-read alignments.

The script supports both PacBio CCS/HiFi and PacBio CLR data:

```bash
READ_TYPE=HIFI
READ_TYPE=CLR
```

The workflow includes multiple SV callers and merging steps:

- pbsv
- SVIM
- Sniffles2
- cuteSV
- Debreak
- optional IRIS polishing for Debreak VCFs
- SURVIVOR merge across callers

Input BAM list format:

```text
sample_id    path/to/sample.sorted.bam
```

A one-column BAM list is also supported; in that case, the sample name is inferred from the BAM filename.

Example usage for PacBio HiFi data:

```bash
BAM_LIST=pacbio_bam.list \
REF=/path/to/Duroc.fa \
OUTDIR=pacbio_hifi_sv_calls \
READ_TYPE=HIFI \
THREADS=56 \
bash longread_sv_detection.sh
```

Example usage for PacBio CLR data:

```bash
BAM_LIST=pacbio_bam.list \
REF=/path/to/Duroc.fa \
OUTDIR=pacbio_clr_sv_calls \
READ_TYPE=CLR \
THREADS=56 \
bash longread_sv_detection.sh
```

Main outputs:

```bash
${OUTDIR}/pbsv/${sample}.pbsv.vcf
${OUTDIR}/svim/${sample}/variants.vcf
${OUTDIR}/sniffles2/${sample}.sniffles2.vcf
${OUTDIR}/cutesv/${sample}.cutesv.vcf
${OUTDIR}/debreak/${sample}/
${OUTDIR}/survivor/${sample}.merged.vcf
```

Platform-specific cuteSV parameters are used for PacBio HiFi and PacBio CLR data.

For PacBio CLR data:

```text
--max_cluster_bias_INS 100
--diff_ratio_merging_INS 0.3
--max_cluster_bias_DEL 200
--diff_ratio_merging_DEL 0.5
```

For PacBio CCS/HiFi data:

```text
--max_cluster_bias_INS 1000
--diff_ratio_merging_INS 0.9
--max_cluster_bias_DEL 1000
--diff_ratio_merging_DEL 0.5
```

### 3. Assembly-based SV discovery

Assembly-based SV discovery scripts are used to identify SVs from genome assemblies and compare read-based and assembly-based SV discovery results.

## Notes

- Population ONT SV discovery is performed with Sniffles2 multi-sample mode.
- PacBio long-read SV detection is performed per sample using `longread_sv_detection.sh`.
- This module focuses on SV discovery. Downstream population-genomic analyses, including allele-frequency estimation, SV density visualization, PCA, phylogeny, admixture, and Fst analyses, are maintained in `03_population_sv_analysis/`.
