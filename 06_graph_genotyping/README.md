# 06_graph_genotyping

Graph-based short-read mapping and SV genotyping.

This module contains two main parts:

1. PanPop-derived SV VCF processing
2. Graph-based short-read mapping and SV genotyping using VG/Giraffe

## Main scripts

### 1. `panpop_processing.sh`

This script processes PanPop-derived SV records before graph-based genotyping.

Main steps:

1. Optionally extract target samples from the PanPop VCF
2. Retain INS and DEL records
3. Retain SVs with length >= 50 bp
4. Retain biallelic records
5. Simplify VCF fields and generate an indexed VCF

Example usage:

```bash
PANPOP_VCF=panpop.raw.vcf.gz \
SAMPLE_LIST=sample.list \
OUTDIR=01_panpop_processed \
THREADS=16 \
bash panpop_processing.sh
```

Main output:

```bash
01_panpop_processed/panpop.sv.processed.vcf.gz
```

This processed SV VCF is used as the variant input for downstream graph-based SV genotyping.

### 2. `graph_sv_genotyping.sh`

This script performs graph-based short-read mapping and SV genotyping.

Main steps:

1. Map paired-end short reads to the graph pangenome using `vg giraffe`
2. Pack read support using `vg pack`
3. Call graph-based SV genotypes using `vg call`
4. Compress, index, and filter per-sample VCF files

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
SV_VCF=01_panpop_processed/panpop.sv.processed.vcf.gz \
OUTDIR=02_graph_genotyping \
THREADS=16 \
bash graph_sv_genotyping.sh
```

Main outputs:

```bash
02_graph_genotyping/gam/${sample}.gam
02_graph_genotyping/pack/${sample}.pack
02_graph_genotyping/vcf/${sample}.graph_sv.raw.vcf.gz
02_graph_genotyping/vcf/${sample}.graph_sv.filtered.vcf.gz
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

- `panpop_processing.sh` prepares the SV VCF used for graph-based genotyping.
- `graph_sv_genotyping.sh` performs sample-level graph mapping and SV genotyping.
- Downstream merging of per-sample genotypes, genotype-level filtering, missing-rate filtering, and depth summaries can be performed after these two core steps.
- Adapt graph index paths, FASTQ paths, PanPop VCF paths, sample lists, thread numbers, and output directories before running.
