# 04_ld_and_feature_annotation

LD analysis and genomic feature annotation for structural variants.

This module includes scripts for LD calculation by distance or variant count, extraction of maximum LD values, common/rare SV LD visualization, feature annotation, LOLA enrichment, Fisher tests, permutation tests, and map visualization.

## External annotation resources

The following public annotation resources were used for genomic feature annotation and enrichment analyses.

### Gene annotation

Gene annotations were based on the Ensembl gene annotation for the pig reference genome Sscrofa11.1, version 113.

Example resource:

```text
Ensembl Sus scrofa gene annotation, release 113
```

### Repeat elements

Repeat elements for Sscrofa11.1 were retrieved from the UCSC database:

```text
https://hgdownload.soe.ucsc.edu/goldenPath/susScr11/database/
```

These repeat annotations were used to annotate SV overlap with repetitive elements and to support enrichment analyses related to repeat-associated SVs.

### Chromatin states

To test the regulatory impacts of SVs, public chromatin state data across 14 pig tissues were collected from the UCSC Genome Browser session:

```text
http://genome.ucsc.edu/s/zhypan/susScr11_15_state_14_tissues_new
```

These chromatin state annotations were used to evaluate SV enrichment in regulatory genomic features across pig tissues.

## Notes

- LD can be calculated using either physical-distance windows or variant-count windows.
- Distance-based LD uses a fixed genomic distance around each SV, whereas count-based LD uses a fixed number of nearby variants.
- Feature annotation and enrichment analyses require consistent chromosome names and coordinate systems across SV VCFs, gene annotations, repeat annotations, and chromatin state files.
