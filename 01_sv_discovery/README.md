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
- Sniffles2
- cuteSV
- Debreak
- optional IRIS polishing for VCFs from all four callers
- SURVIVOR merge across callers

PacBio HiFi reads are aligned to the reference genome with NGMLR using `-x pacbio` before SV calling.

Input BAM list format:

```text
sample_id    path/to/sample.hifi.ngmlr.bam
```

A one-column BAM list is also supported; in that case, the sample name is inferred from the BAM filename. HiFi BAM files should be coordinate-sorted and indexed.

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
${OUTDIR}/sniffles2/${sample}.sniffles2.vcf
${OUTDIR}/cutesv/${sample}.cutesv.vcf
${OUTDIR}/debreak/${sample}/
${OUTDIR}/iris/${sample}.{pbsv,sniffles2,cutesv,debreak}.polished.vcf
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

`assembly_based_sv_detection.sh` detects structural variants by aligning each assembled genome to the reference genome with nucmer and calling assembly-based variants with Assemblytics. The Assemblytics BED output is then converted with SURVIVOR for downstream VCF-based analyses.

The workflow contains three steps:

1. Align each genome assembly to the reference with nucmer using `--maxmatch -l 500 -c 500`
2. Detect 50–100,500 bp assembly-based variants with Assemblytics
3. Convert the Assemblytics structural-variant BED file with `SURVIVOR convertAssemblytics`

Input assemblies must be FASTA files placed directly under `ASSEMBLY_DIR`:

```text
accession_genome/
├── sample1.fa
├── sample2.fa
└── sample3.fa
```

The sample name is taken from the part of the FASTA filename before the first period. For example, `sample1.hap1.fa` is assigned the sample name `sample1`.

Example usage:

```bash
REF=/path/to/Duroc.fa \
ASSEMBLY_DIR=/path/to/accession_genome \
THREADS=56 \
ASSEMBLYTICS=/path/to/Assemblytics-1.2.1/scripts/Assemblytics \
bash assembly_based_sv_detection.sh
```

The main adjustable parameters are:

```text
UNIQUE_ANCHOR_LENGTH=500
MIN_VARIANT_SIZE=50
MAX_VARIANT_SIZE=100500
SURVIVOR_MIN_SIZE=50
```

For each assembly, the main intermediate and output files are:

```text
${sample}.delta
${sample}.Assemblytics_structural_variants.bed
${sample}
```

Here, `${sample}.delta` is the nucmer alignment, `${sample}.Assemblytics_structural_variants.bed` contains the Assemblytics calls, and `${sample}` is the SURVIVOR-converted output filename specified by the current script.

Outputs are written to the directory from which the script is executed. Use a separate working directory if the input directory contains many assemblies or if existing files with the same sample prefixes must be preserved.

## Software installation

The key tools can be installed with conda or pip when available. Some tools, such as Guppy and pbsv, are usually installed from the vendor or project release package.

```bash
conda create -n sv_discovery -c conda-forge -c bioconda \
    ngmlr=0.2.7 sniffles=2.0.7 survivor=1.0.7 \
    pbsv=2.9.0 cutesv=2.0.3 mummer4=4.0.0 bedtools=2.30.0

pip install debreak==1.0.2 iris==1.0.2
```

Short-read SV callers used for comparison can be installed in a separate environment:

```bash
conda create -n short_read_sv -c conda-forge -c bioconda \
    manta=1.6.0 delly=0.7.6 wham=1.7.0 lumpy-sv=0.2.13
```

Assemblytics can be installed from the project repository:

```bash
git clone https://github.com/MariaNattestad/Assemblytics.git
```

Guppy should be installed from the Oxford Nanopore release package matching the sequencing environment, for example Guppy v6.3.

## Notes

- Population ONT SV discovery is performed with Sniffles2 multi-sample mode.
- PacBio long-read SV detection is performed per sample using `longread_sv_detection.sh`.
