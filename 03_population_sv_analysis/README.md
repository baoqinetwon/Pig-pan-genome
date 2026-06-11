# 03_population_sv_analysis

This module contains downstream population-genomic analyses based on the discovered SV set.

## Main analyses

This module includes scripts for:

- SV filtering and quality control
- SV ID normalization
- allele-frequency estimation
- SV density visualization
- PCA
- phylogeny
- admixture
- Fst analysis

## Notes

Population-scale ONT SV discovery using Sniffles2 multi-sample calling is maintained in:

```bash
01_sv_discovery/multi_sample_sniffles2_calling.sh
```

This separation keeps SV discovery in `01_sv_discovery/` and downstream population-genomic analyses in `03_population_sv_analysis/`.
