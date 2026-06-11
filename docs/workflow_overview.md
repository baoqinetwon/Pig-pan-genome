# Workflow overview

This repository is organized as modular analysis scripts for the pig graph pangenome and structural variant study.

The modules are listed below in the logical analysis order used in the study. Folder names retain their current numbered prefixes so that existing paths remain stable.

1. Discover structural variants from long-read sequencing and genome assemblies (`01_sv_discovery/`).
2. Discover SNPs and Indels from genome assemblies and long-read sequencing (`02_snp_indel_discovery/`).
3. Perform population-level SV filtering, allele-frequency estimation, Fst, phylogeny, and population-structure analysis (`03_population_sv_analysis/`).
4. Calculate LD and annotate SVs with genomic features, repeats, enrichment signals, and map information (`04_ld_and_feature_annotation/`).
5. Build the graph pangenome, prepare graph-compatible VCF files, construct VG/Giraffe indexes, and annotate graph records (`00_graph_pangenome_construction/`).
6. Genotype SVs from short-read WGS using VG/Giraffe and perform genotype-level filtering (`05_graph_genotyping/`).
7. Process RNA-seq data, normalize expression, visualize expression patterns, and prepare expression matrices for QTL analysis (`07_expression_processing/`).
8. Perform genotype preprocessing, GRM construction, cis-eQTL mapping, breed-interaction eQTL analysis, and eQTL visualization (`08_eqtl_mapping/`).
9. Conduct allele-specific expression analysis using RNA-seq and matched genotype data (`10_ase_analysis/`).
10. Estimate allelic fold-change and summarize eQTL effect-size patterns (`13_effect_size_analysis/`).
11. Perform functional annotation, enrichment analysis, and sequence conservation analysis (`14_functional_annotation/`).
12. Estimate cis-expression heritability and partition variance components across variant classes (`12_heritability_partitioning/`).

GWAS and fine-mapping scripts are maintained in the external `sv-association-pipeline` repository and are referenced here only for connection to the broader study workflow.
