# 06_graph_genotyping

Graph-based short-read mapping and SV genotyping.

This module contains two main parts in the following order:

1. Graph-based short-read mapping and SV genotyping using VG/Giraffe
2. PanPop post-processing of the graph-genotyped VCF

## Main scripts

### 1. `graph_sv_genotyping.sh`

This script performs graph-based short-read mapping and SV genotyping.

Main steps:

1. Map paired-end short reads to the graph pangenome using `vg giraffe`
2. Pack read support using `vg pack`
3. Call graph-based SV genotypes using `vg call`
4. Compress and index per-sample graph-genotyped VCF files

Input FASTQ list format:

```text
sample_id    read1.fq.gz    read2.fq.gz
```

Example usage:

```bash
FASTQ_LIST=fastq.list \
GBZ=graph.gbz \
XG=graph.xg \
MIN=graph.min \
DIST=graph.dist \
SNARLS=graph.snarls \
GRAPH_SV_SITE_VCF=graph_sv_sites.vcf.gz \
OUTDIR=02_graph_genotyping \
THREADS=16 \
bash graph_sv_genotyping.sh
```

Main outputs:

```bash
02_graph_genotyping/gam/${sample}.gam
02_graph_genotyping/pack/${sample}.pack
02_graph_genotyping/vcf/${sample}.graph_sv.raw.vcf.gz
```

The per-sample graph-genotyped VCF files are then merged and processed using `panpop_processing.sh`.

### 2. `panpop_processing.sh`

This script is run after graph-based SV genotyping. It processes the graph-genotyped VCF rather than preparing input before genotyping.

To standardize the representation of graph-derived SVs, the raw graph-genotyped records are further refined using the PanPop Realign and Thin (PART) module. This post-processing step is used to generate a standardized graph-derived SV genotype set for downstream analyses.

Main steps:

1. Merge per-sample graph-genotyped VCFs, if a VCF list is provided
2. Optionally extract target samples
3. Refine graph-derived SV records using the PanPop Realign and Thin (PART) module
4. Retain INS and DEL records
5. Retain SVs with length >= 50 bp
6. Retain biallelic records
7. Simplify VCF fields while retaining genotype calls
8. Generate a final indexed graph-genotyped VCF

Input options:

```bash
GENOTYPED_VCF=02_graph_genotyping/vcf/graph_sv.genotyped.vcf.gz
VCF_LIST=graph_genotyped_vcf.list
```

If `VCF_LIST` is provided, per-sample VCFs are merged first. Otherwise, `GENOTYPED_VCF` is used directly.

Example usage:

```bash
VCF_LIST=graph_genotyped_vcf.list \
SAMPLE_LIST=sample.list \
OUTDIR=03_panpop_processed \
THREADS=16 \
bash panpop_processing.sh
```

Main output:

```bash
03_panpop_processed/graph_sv.genotyped.panpop_processed.vcf.gz
```

## Required graph index files

The graph-based genotyping step requires VG/Giraffe graph index files generated during graph pangenome construction, including:

```text
graph.gbz
graph.xg
graph.min
graph.dist
graph.snarls
```

## Notes

- `graph_sv_genotyping.sh` performs sample-level graph mapping and SV genotyping.
- `panpop_processing.sh` is a downstream post-processing step for the graph-genotyped VCF.
- The correct order is graph genotyping first, followed by PanPop PART-based post-processing.
- Adapt graph index paths, FASTQ paths, graph SV site VCF paths, sample lists, thread numbers, and output directories before running.
