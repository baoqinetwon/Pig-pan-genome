# File description

The original uploaded project files were reorganized into standardized module directories. Most command-record files were converted to `.sh`, `.R`, or `.md` files with clearer names.

Large data files and third-party software archives were intentionally excluded from upload. See `docs/data_availability.md` for recommended data handling.

## Module order and descriptions

| Order | Module | Main content |
|---:|---|---|
| 1 | [`01_sv_discovery/`](../01_sv_discovery/) | Long-read and assembly-based SV discovery, SV filtering, and comparison of read-based and assembly-based SV calls. |
| 2 | [`02_snp_indel_discovery/`](../02_snp_indel_discovery/) | SNP/Indel discovery from genome assemblies and long-read sequencing, including MUMmer/nucmer result conversion. |
| 3 | [`03_population_sv_analysis/`](../03_population_sv_analysis/) | Multi-sample SV calling, filtering, ID normalization, allele-frequency estimation, SV density, PCA, phylogeny, admixture, and Fst analyses. |
| 4 | [`04_ld_and_feature_annotation/`](../04_ld_and_feature_annotation/) | LD calculation, maximum-LD extraction, common/rare SV LD visualization, feature annotation, enrichment tests, permutation tests, and map visualization. |
| 5 | [`05_graph_pangenome_construction/`](../05_graph_pangenome_construction/) | Graph-compatible VCF preparation, graph pangenome construction, VG/Giraffe index generation, deduplication, and graph annotation. |
| 6 | [`06_graph_genotyping/`](../06_graph_genotyping/) | VG/Giraffe mapping, graph-based SV genotyping, multiallelic splitting, genotype filtering, SV length filtering, and depth summarization. |
| 7 | [`07_expression_processing/`](../07_expression_processing/) | RNA-seq quantification, expression normalization, PCA/t-SNE visualization, and preparation of expression matrices for QTL analysis. |
| 8 | [`08_eqtl_mapping/`](../08_eqtl_mapping/) | Genotype preprocessing, GRM construction, cis-eQTL mapping, breed-interaction eQTL analysis, TensorQTL preparation, and gene/TSS coordinate extraction. |
| 9 | [`09_ase_analysis/`](../09_ase_analysis/) | Allele-specific expression analysis using RNA-seq and matched genotype data. |
| 10 | [`10_effect_size_analysis/`](../10_effect_size_analysis/) | Allelic fold-change estimation and summarization of eQTL effect-size patterns. |
| 11 | [`11_functional_annotation/`](../11_functional_annotation/) | Functional enrichment, sequence conservation, fold-change calculation, and phastCons/conservation chunk processing. |
| 12 | [`12_heritability_partitioning/`](../12_heritability_partitioning/) | cis-heritability estimation, variance-component modeling, and summarization of heritability results across variant classes. |
| 13 | [`13_panel_imputation/`](../13_panel_imputation/) | Two-step SNP/SV imputation and evaluation of imputation accuracy using validation samples. |
