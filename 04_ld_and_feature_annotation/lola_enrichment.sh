#!/usr/bin/env bash
# LOLA enrichment analysis wrapper.
# Prepare query BED files and region databases before running.
set -euo pipefail

QUERY_BED=${QUERY_BED:-query_regions.bed}
UNIVERSE_BED=${UNIVERSE_BED:-universe_regions.bed}
REGION_DB=${REGION_DB:-/path/to/lola_region_database}
OUTDIR=${OUTDIR:-lola_enrichment}

mkdir -p ${OUTDIR}

Rscript - <<'RSCRIPT'
library(LOLA)

query_bed <- Sys.getenv("QUERY_BED", "query_regions.bed")
universe_bed <- Sys.getenv("UNIVERSE_BED", "universe_regions.bed")
region_db <- Sys.getenv("REGION_DB", "/path/to/lola_region_database")
outdir <- Sys.getenv("OUTDIR", "lola_enrichment")

query <- readBed(query_bed)
universe <- readBed(universe_bed)
regionDB <- loadRegionDB(region_db)

res <- runLOLA(query, universe, regionDB)
write.table(res, file=file.path(outdir, "lola_enrichment.tsv"), sep="\t", quote=FALSE, row.names=FALSE)
RSCRIPT
