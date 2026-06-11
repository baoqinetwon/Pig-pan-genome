# Demo files for aFC analysis

This directory provides a small demo dataset for `10_effect_size_analysis`.

## Files

```text
demo.phased.vcf        Small phased genotype VCF used by `--vcf`
demo.phenotype.bed     Small TMM-expression phenotype BED used by `--pheno`
demo.evariant.txt      Example cis-eQTL variant-gene pair file used by `--qtl`
demo_covariant.txt     Example covariate matrix used by `--cov`
run_demo_afc.sh        Example command for running `aFC.py`
```

## Example command

```bash
bash run_demo_afc.sh
```

The demo keeps only a few genes and samples to illustrate the expected input format.
For the full analysis, replace these demo files with tissue-specific phased genotype VCF, expression BED, cis-QTL pair file, and covariate file.
