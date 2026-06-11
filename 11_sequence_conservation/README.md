# 11_sequence_conservation

Sequence conservation score calculation for genomic intervals.

This module focuses on calculating sequence conservation scores for pig genomic regions, such as SVs, indels, or other target intervals. Conservation scores are derived from UCSC phastCons100way data and lifted from human hg38 coordinates to the pig reference genome susScr11.

## Main script

```bash
sequence_conservation_score.sh
```

## Main workflow

### 1. Download hg38 phastCons100way scores

The conservation score data are downloaded from UCSC:

```text
http://hgdownload.cse.ucsc.edu/goldenpath/hg38/phastCons100way/hg38.100way.phastCons/
```

Example:

```bash
wget -c http://hgdownload.cse.ucsc.edu/goldenpath/hg38/phastCons100way/hg38.100way.phastCons/chr1.phastCons100way.wigFix.gz
```

### 2. Convert wigFix to BED

The wigFix conservation files are converted to BED format using `wig2bed` from BEDOPS.

Example:

```bash
wig2bed --max-mem 64G < chr1.phastCons100way.wigFix > chr1.phastCons100way.wigFix.bed
```

### 3. Split large BED files if needed

Large conservation BED files can be split into smaller chunks before liftOver to improve running efficiency.

If a local chunk-splitting script is available, it can be used before liftOver.

### 4. Lift over conservation scores to susScr11

The hg38 conservation BED files are lifted to pig susScr11 coordinates using UCSC `liftOver`.

The hg38-to-susScr11 chain file can be downloaded from UCSC:

```text
https://hgdownload.soe.ucsc.edu/goldenPath/hg38/liftOver/
```

Example:

```bash
liftOver -minMatch=0.8 \
    chr1.phastCons100way.wigFix.bed \
    hg38ToSusScr11.over.chain.gz \
    chr1.phastCons100way.susScr11.bed \
    chr1.phastCons100way.unmap.txt
```

### 5. Merge lifted conservation BED files

All lifted conservation BED files are merged, sorted, compressed, and indexed.

Example output:

```text
Pig.ALLchr.hg38ToSusScr11.bed.gz
```

### 6. Calculate mean conservation score for target intervals

Mean conservation scores are calculated for target intervals using `bedtools map`.

Example:

```bash
bedtools map \
    -split \
    -sorted \
    -a target_regions.sort.bed \
    -b Pig.ALLchr.hg38ToSusScr11.bed.gz \
    -o mean \
    > target_regions.conservation_score.txt
```

## Input data

Typical input files include:

```text
hg38 phastCons100way wigFix files
hg38ToSusScr11.over.chain.gz
target BED files, such as SV or indel intervals
```

## Outputs

Typical outputs include:

```text
converted phastCons BED files
lifted susScr11 conservation BED files
merged pig conservation score BED file
mean conservation score table for target genomic intervals
```

## Notes

- The conservation score track is originally based on hg38 phastCons100way and is lifted to susScr11.
- `-minMatch=0.8` is used in liftOver by default in the provided script.
- Target interval BED files should be sorted and use the same chromosome naming style as the lifted conservation BED file.
- This module is intended for sequence conservation score calculation rather than general functional enrichment analysis.
