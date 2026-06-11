# Imputation accuracy evaluation
# Source file: CR.cor.R
# Adapt input paths and filtering thresholds before running.

library(data.table)
library(ggplot2)

imputed <- fread("/path/to/imputed.vcf.txt")
truth <- fread("/path/to/truth.vcf.txt")

setnames(imputed, c("CHROM", "POS", "REF", "ALT", "INFO", "MAF", paste("Sample", 1:(ncol(imputed)-6), sep = "_")))
setnames(truth, c("CHROM", "POS", "REF", "ALT", "MAF", paste("Sample", 1:(ncol(truth)-5), sep = "_")))

imputed <- imputed[, -ncol(imputed), with = FALSE]
truth <- truth[, -ncol(truth), with = FALSE]
maf_data <- truth[, .(CHROM, POS, MAF)]
imputed[, INFO := as.numeric(INFO)]
imputed <- imputed[INFO >= 0.85]

truth_no_maf <- truth[, !("MAF"), with = FALSE]
imputed_no_maf <- imputed[, !c("MAF", "INFO"), with = FALSE]

matched <- merge(
  imputed_no_maf,
  truth_no_maf,
  by = c("CHROM", "POS", "REF", "ALT"),
  suffixes = c(".imputed", ".truth")
)

chrom_pos <- matched[, .(CHROM, POS)]
filtered_maf <- maf_data[matched, on = .(CHROM, POS)]
maf <- matrix(filtered_maf$MAF, ncol = 1)
colnames(maf) <- c("maf")

convert_genotypes <- function(geno) {
  sapply(geno, function(x) {
    alleles <- unlist(strsplit(as.character(x), split = "[|/]"))
    sum(as.numeric(alleles))
  })
}

for (col in names(matched)[grepl(".imputed|.truth$", names(matched))]) {
  matched[[col]] <- convert_genotypes(matched[[col]])
}

geno_pred <- matched[, grep(".imputed", names(matched), value = TRUE), with = FALSE]
geno_obs <- matched[, grep(".truth", names(matched), value = TRUE), with = FALSE]

compare <- geno_obs == geno_pred
CR_snp <- rowMeans(compare, na.rm = TRUE)
CR_snp <- matrix(CR_snp, ncol = 1)
colnames(CR_snp) <- c("concRate")

true_counts <- rowSums(compare, na.rm = TRUE)
false_counts <- rowSums(!compare, na.rm = TRUE)
total_counts <- true_counts + false_counts
true_proportion <- true_counts / total_counts
counts_matrix <- cbind(true_counts, false_counts, true_proportion)
colnames(counts_matrix) <- c("True_Counts", "False_Counts", "True_Proportion")
final_matrix <- cbind(chrom_pos, counts_matrix)

geno_obs <- as.matrix(geno_obs)
geno_pred <- as.matrix(geno_pred)
COR_snp <- sapply(1:nrow(geno_obs), function(i) {
  cor(geno_obs[i, ], geno_pred[i, ], use = "pairwise.complete.obs")
})
COR_snp <- matrix(COR_snp, ncol = 1)
colnames(COR_snp) <- c("r_calc")

accuracy_maf <- cbind(chrom_pos, maf, CR_snp, COR_snp, final_matrix$True_Counts, final_matrix$False_Counts)
colnames(accuracy_maf) <- c("chr", "pos", "maf", "CR", "cor", "true_counts", "false_counts")

write.table(
  accuracy_maf,
  file = "accuracy_maf.tsv",
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)
