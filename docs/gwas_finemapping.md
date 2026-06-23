# GWAS and fine-mapping

Genome-wide association analysis and fine-mapping are maintained in an external repository:

https://github.com/JJWang259/sv-association-pipeline/

That repository should be cited or referenced for association-analysis steps, including:

- GWAS model fitting
- candidate-region definition
- Bayesian fine-mapping
- fine-mapping result summarization
- enrichment of associated/fine-mapped variants
- variant effect estimation where applicable

## Software installation

The main GWAS and fine-mapping tools used in this study were SLEMM and BFMAP:

```bash
git clone https://github.com/JJWang259/sv-association-pipeline.git
```

Install common dependencies with conda:

```bash
conda create -n gwas_finemap -c conda-forge -c bioconda \
    plink2 bcftools=1.13 r-base
```

Install R/Python helper packages as required by the external association pipeline:

```bash
pip install numpy pandas scipy
```

For genetic-effect enrichment, GEMRICH can be installed from GitHub:

```bash
git clone https://github.com/jiang18/gemrich.git
```

This repository keeps only the graph pangenome, SV discovery, graph genotyping, population SV, eQTL, and downstream functional-analysis scripts, so that the division between variant resource construction and trait-association analysis remains clear.
