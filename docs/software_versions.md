# Software versions

This document summarizes the major software packages and versions used in the analyses. Installation notes are provided in the README file of each analysis module.

| No. | Analysis module | Software |
|---:|---|---|
| 1 | ONT-read sequencing, alignment, and SV calling | Guppy v6.3; NGMLR v0.2.7; Sniffles2 v2.0.7; SURVIVOR v1.0.7 |
| 2 | SNP calling from ONT reads | Clair3 v1.1.0; GLnexus v1.4.1 |
| 3 | Identification of unreported SVs | BEDTools v2.30.0 |
| 4 | Population genetics analysis | PLINK2; PHYLIP v3.697; ADMIXTURE v1.3.0; ggtree v3.10.0; VCFtools v0.1.16; gprofiler2 v0.2.3 |
| 5 | Assembly-based detection of small and structural variants | MUMmer toolkit v4.0.0; Assemblytics v1.2.1 |
| 6 | SV calling using PacBio reads | PBSV v2.9.0; Sniffles2 v2.0.7; cuteSV v2.0.3; DeBreak v1.0.2; Iris v1.0.2 |
| 7 | Graph pangenome construction and SV genotyping | vg toolkit v1.51.0; BCFtools v1.13; PanPop |
| 8 | Evaluation of graph pangenome performance | simuG; ART_Illumina; Truvari |
| 9 | SV calling using short reads | Manta v1.6.0; Delly v0.7.6; Wham v1.7.0; Lumpy v0.2.13 |
| 10 | Transcriptome analysis | fastp v0.22.0; STAR v2.7.9a; featureCounts v2.0.6; StringTie v2.1.7 |
| 11 | cis-eQTL mapping | OmiGA v1.0.2 |
| 12 | Heritability estimates of gene expression | MPH v0.54.0 |
| 13 | Construction of pig genomics SV reference panel | Beagle v5.4; BCFtools v1.13 |
| 14 | GWAS and fine-mapping | SLEMM v0.90.1; BFMAP v0.65 |
| 15 | Genetic effect enrichment | GEMRICH |
| 16 | Partitioning small-effect contributions | MPH v0.54.0; GCTA |

## Notes

- `PLINK2`, `PanPop`, `simuG`, `ART_Illumina`, `Truvari`, `GEMRICH`, and `GCTA` were recorded here without fixed version numbers when an exact version was not available from the final analysis notes.
- Module-specific installation examples are kept in the corresponding analysis README files to avoid mixing installation commands with the version summary.
