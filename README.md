# Pig graph pangenome and structural variant analysis

This repository contains scripts and workflow notes associated with a pig graph pangenome and structural variant study. The code is organized as a reproducibility-oriented paper repository rather than a single fully automated workflow, because the original analyses were run on large sequencing, assembly, genotype, and transcriptome datasets.

## Main analyses covered

The modules are organized as top-level numbered directories following the major analysis order used in the study.

1. Long-read and assembly-based SV discovery (`01_sv_discovery/`)
2. SNP and Indel discovery (`02_snp_indel_discovery/`)
3. Population-level SV analysis (`03_population_sv_analysis/`)
4. LD analysis and genomic feature annotation (`04_ld_and_feature_annotation/`)
5. Graph pangenome construction (`05_graph_pangenome_construction/`)
6. Graph-based short-read mapping and SV genotyping (`06_graph_genotyping/`)
7. RNA-seq expression processing (`07_expression_processing/`)
8. cis-eQTL mapping (`08_eqtl_mapping/`)
9. Allele-specific expression analysis (`09_ase_analysis/`)
10. eQTL effect-size and allelic fold-change analysis (`10_effect_size_analysis/`)
11. Sequence conservation score calculation (`11_sequence_conservation/`)
12. cis-expression heritability partitioning (`12_heritability_partitioning/`)
13. SV panel construction and imputation evaluation (`13_panel_imputation/`)

## GWAS and fine-mapping

GWAS and fine-mapping scripts are maintained in a separate repository and are not duplicated here:

- https://github.com/JJWang259/sv-association-pipeline/

See `docs/gwas_finemapping.md` for how the external association pipeline connects to this repository.

## Repository structure

| Order | Module | Description |
|---:|---|---|
| 1 | [`01_sv_discovery/`](01_sv_discovery/) | Long-read and assembly-based structural variant discovery. |
| 2 | [`02_snp_indel_discovery/`](02_snp_indel_discovery/) | SNP and Indel discovery from genome assemblies and long-read sequencing. |
| 3 | [`03_population_sv_analysis/`](03_population_sv_analysis/) | Population-level SV analysis, including PCA, phylogeny, admixture, and Fst analysis. |
| 4 | [`04_ld_and_feature_annotation/`](04_ld_and_feature_annotation/) | LD analysis, genomic feature annotation, repeat annotation, and regulatory-feature enrichment. |
| 5 | [`05_graph_pangenome_construction/`](05_graph_pangenome_construction/) | Graph pangenome construction and VG/Giraffe index generation. |
| 6 | [`06_graph_genotyping/`](06_graph_genotyping/) | VG/Giraffe-based short-read mapping, graph-based SV genotyping, and PanPop PART-based post-processing. |
| 7 | [`07_expression_processing/`](07_expression_processing/) | RNA-seq expression quantification and preprocessing for downstream eQTL mapping. |
| 8 | [`08_eqtl_mapping/`](08_eqtl_mapping/) | Genotype preprocessing, GRM construction, cis-eQTL mapping, and conditional independent cis-eQTL analysis. |
| 9 | [`09_ase_analysis/`](09_ase_analysis/) | Allele-specific expression analysis using masked-genome RNA-seq mapping and phaser-based haplotypic expression counting. |
| 10 | [`10_effect_size_analysis/`](10_effect_size_analysis/) | Allelic fold-change estimation for cis-eQTL variants using `aFC.py`. |
| 11 | [`11_sequence_conservation/`](11_sequence_conservation/) | Sequence conservation score calculation using hg38 phastCons100way scores lifted to susScr11. |
| 12 | [`12_heritability_partitioning/`](12_heritability_partitioning/) | cis-expression heritability estimation and variant-class variance-component modeling. |
| 13 | [`13_panel_imputation/`](13_panel_imputation/) | SV panel construction, two-step imputation, and imputation accuracy evaluation. |

See `docs/workflow_overview.md` and `docs/file_description.md` for details.

## Usage notes

Most scripts contain study-specific file names, paths, and sample lists from the original analysis environment. Before re-running, replace the placeholder or original paths with local paths to your reference genome, VCF files, BAM/CRAM files, expression matrices, covariate files, and output directories.

## Data availability

Large data files, indexed annotation tracks, and real result matrices are not stored in this GitHub repository. See `docs/data_availability.md` and the associated manuscript/database for genotype, SV, eQTL, GWAS, and RNA-seq resources.

## Citation

Please cite the associated manuscript when using this repository:

Bao Q†, Wen H†, Zeng L†, Yang L, Wang J, He S, Yin H, Jiang Y, Qu X, Wang Z, Li X, Yang X, Teng J, Zhao P, Zhang D, Liu D, Cao G, Yu T, Ding R, Wang C, Zhang W, Tan Z, Zhu Y, Xia Y, Wang J, Zhao X, Tiezzi F, Gini C, Huang Y, See G, Schwab C, Xu R, Chen Z, Zhao Y, Xiang H, Zhou H, Ding X, Zhang Z, Tang Z, Li K, Maltecca C, Fang L*, Jiang J*, Yi G*. Long-read sequencing reveals the impact of structural variation on gene expression and complex traits in pigs. (under review)

## Contact

### 👤 Qi Bao

🏛️ Agricultural Genomics Institute at Shenzhen (AGIS), Chinese Academy of Agricultural Sciences, Shenzhen, China.  
📧 E-mail: baoqinetwon@163.com

### 👤 Dr. Guoqiang Yi

🏛️ Agricultural Genomics Institute at Shenzhen (AGIS), Chinese Academy of Agricultural Sciences, Shenzhen, China.  
📧 E-mail: yiguoqiang@caas.cn
