# Pig graph pangenome and structural variant analysis

This repository contains scripts and workflow notes associated with a pig graph pangenome and structural variant study. The code is organized as a reproducibility-oriented paper repository rather than a single fully automated workflow, because the original analyses were run on large sequencing, assembly, genotype, and transcriptome datasets.

## Main analyses covered

1. Graph pangenome construction and graph annotation
2. Long-read and assembly-based SV/SNP/Indel discovery
3. Population-level SV calling, filtering, allele frequency, LD, Fst, phylogeny, and structure analyses
4. VG/Giraffe-based short-read mapping and graph genotyping
5. SV panel construction and imputation evaluation
6. RNA-seq processing, expression normalization, cis-eQTL mapping, and eQTL visualization
7. ASE, GRN construction, cis-heritability partitioning, allele fold-change, and functional annotation

## GWAS and fine-mapping

GWAS and fine-mapping scripts are maintained in a separate repository and are not duplicated here:

- https://github.com/JJWang259/sv-association-pipeline/

See `docs/gwas_finemapping.md` for how the external association pipeline connects to this repository.

## Repository structure

The main scripts are organized as top-level numbered modules, from `00_graph_pangenome_construction/` to `14_functional_annotation/`. See `docs/workflow_overview.md` and `docs/file_description.md` for details.

## Usage notes

Most scripts contain study-specific file names, paths, and sample lists from the original analysis environment. Before re-running, replace the placeholder or original paths with local paths to your reference genome, VCF files, BAM/CRAM files, expression matrices, covariate files, and output directories.

## Data availability

Large data files, indexed annotation tracks, and real result matrices are not stored in this GitHub repository. See `docs/data_availability.md` and the associated manuscript/database for genotype, SV, eQTL, GWAS, and RNA-seq resources.

## Citation

Please cite the associated manuscript when using this repository. A draft citation metadata file is provided in `CITATION.cff` and should be updated after the final title/DOI are available.

## Contact

QI Bao  
GitHub: @baoqinetwon
