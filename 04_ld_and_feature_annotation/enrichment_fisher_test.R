# Fisher exact test for genomic feature enrichment.
# Adapt input count table before running.

library(data.table)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: Rscript enrichment_fisher_test.R <count_table.tsv> <output.tsv>")
}

input <- args[1]
output <- args[2]

dt <- fread(input)
# Required columns:
# feature, sv_in_feature, sv_not_in_feature, bg_in_feature, bg_not_in_feature

res <- dt[, {
  mat <- matrix(
    c(sv_in_feature, sv_not_in_feature, bg_in_feature, bg_not_in_feature),
    nrow = 2,
    byrow = TRUE
  )
  ft <- fisher.test(mat)
  list(
    odds_ratio = as.numeric(ft$estimate),
    pvalue = ft$p.value
  )
}, by = feature]

res[, padj := p.adjust(pvalue, method = "BH")]
fwrite(res, output, sep = "\t")
