# 05_graph_pangenome_construction

Graph pangenome construction and VG/Giraffe index generation.

This module contains scripts for preparing graph-compatible input files, building the graph pangenome, and generating indexes required for graph-based short-read mapping and SV genotyping.

## Main workflow

1. Prepare graph-compatible variant input files
2. Construct the graph pangenome
3. Generate VG/Giraffe indexes
4. Prepare graph files for downstream short-read mapping and genotyping

## Software installation

Install vg and BCFtools with conda:

```bash
conda create -n graph_pangenome -c conda-forge -c bioconda vg=1.51.0 bcftools=1.13
```

If PanPop is required for graph-related post-processing, install it from the project repository used in the analysis environment:

```bash
git clone <PanPop_repository_url>
```

## Notes

- This directory focuses on graph pangenome construction and index preparation.
- Adapt reference paths, variant input paths, sample lists, thread numbers, and output directories before running.
