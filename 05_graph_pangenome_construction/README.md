# 05_graph_pangenome_construction

Graph pangenome construction and VG/Giraffe index generation.

This module contains scripts for preparing graph-compatible input files, building the graph pangenome, and generating indexes required for graph-based short-read mapping and SV genotyping.

## Main workflow

1. Prepare graph-compatible variant input files
2. Construct the graph pangenome
3. Generate VG/Giraffe indexes
4. Prepare graph files for downstream short-read mapping and genotyping

## Notes

- This directory focuses on graph pangenome construction and index preparation.
- Adapt reference paths, variant input paths, sample lists, thread numbers, and output directories before running.
