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

### 2. SV detection from individual public PacBio long-read datasets

`longread_sv_detection.sh` is used for read-based SV discovery from individual PacBio long-read datasets downloaded from published studies or public repositories.

This workflow is separate from the population-scale ONT multi-sample calling workflow. It processes each downloaded PacBio sample independently and assumes that sorted BAM files aligned to the reference genome are already available.

The script runs multiple SV callers for each sample:

- Sniffles2
- cuteSV
- pbsv
- SVIM

Input BAM list format:

```text
sample_id    path/to/sample.sorted.bam
```

Example usage:

```bash
BAM_LIST=pacbio_bam.list \
REF=/path/to/reference.fa \
OUTDIR=public_pacbio_sv_calls \
THREADS=16 \
bash longread_sv_detection.sh
```

Main outputs:

```bash
public_pacbio_sv_calls/sniffles2/${sample}.sniffles2.vcf
public_pacbio_sv_calls/cutesv/${sample}.cutesv.vcf
public_pacbio_sv_calls/pbsv/${sample}.pbsv.vcf
public_pacbio_sv_calls/svim/${sample}/
```

### 3. Assembly-based SV discovery

Assembly-based SV discovery scripts are used to identify SVs from genome assemblies and compare read-based and assembly-based SV discovery results.

## Notes

- Population ONT SV discovery is performed with Sniffles2 multi-sample mode.
- Individual public PacBio long-read datasets are processed separately using `longread_sv_detection.sh`.
- This module focuses on SV discovery. Downstream population-genomic analyses, including allele-frequency estimation, SV density visualization, PCA, phylogeny, admixture, and Fst analyses, are maintained in `03_population_sv_analysis/`.
