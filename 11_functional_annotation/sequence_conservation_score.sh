#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Sequence conservation score calculation
# ============================================================
# This script calculates mean sequence conservation scores for
# target genomic intervals in the pig genome.
#
# Main workflow:
#   1. Download hg38 phastCons100way scores from UCSC
#   2. Convert wigFix files to BED using wig2bed from BEDOPS
#   3. Split BED files into chunks if needed
#   4. Lift over hg38 conservation scores to susScr11
#   5. Merge and sort lifted conservation BED files
#   6. Calculate mean conservation score for target intervals
#
# Required tools:
#   - wig2bed, from BEDOPS
#   - liftOver
#   - bedtools
#   - bgzip/tabix

THREADS=${THREADS:-56}
MIN_MATCH=${MIN_MATCH:-0.8}
CHAIN=${CHAIN:-hg38ToSusScr11.over.chain.gz}
TARGET_BED_DIR=${TARGET_BED_DIR:-../../02_indel}
TARGET_PATTERN=${TARGET_PATTERN:-*sort.bed}
OUTDIR=${OUTDIR:-sequence_conservation}

mkdir -p ${OUTDIR}/{wigfix_bed,chunks,liftover,score}

# ------------------------------------------------------------
# 1. Download phastCons scores
# ------------------------------------------------------------
# Download hg38 phastCons100way wigFix files from UCSC:
#
# http://hgdownload.cse.ucsc.edu/goldenpath/hg38/phastCons100way/hg38.100way.phastCons/
#
# Example:
#   wget -c http://hgdownload.cse.ucsc.edu/goldenpath/hg38/phastCons100way/hg38.100way.phastCons/chr1.phastCons100way.wigFix.gz

# ------------------------------------------------------------
# 2. Convert wigFix to BED
# ------------------------------------------------------------
# If wigFix files are compressed, decompress them before conversion.

ls *.wigFix | while read -r id
 do
    echo "Converting ${id} to BED"
    wig2bed --max-mem 64G < ${id} > ${OUTDIR}/wigfix_bed/${id}.bed
 done

# ------------------------------------------------------------
# 3. Split BED chunks if needed
# ------------------------------------------------------------
# Large BED files can be split before liftOver to improve speed.
# The local script split_chunk.sh can be used here if available.

if [[ -s split_chunk.sh ]]; then
    bash split_chunk.sh
fi

# ------------------------------------------------------------
# 4. Lift over hg38 conservation BED files to susScr11
# ------------------------------------------------------------
# The hg38-to-susScr11 chain file can be downloaded from UCSC:
#
# https://hgdownload.soe.ucsc.edu/goldenPath/hg38/liftOver/

ls ${OUTDIR}/wigfix_bed/*.bed* | xargs -I {} -P ${THREADS} sh -c '
    file=$(basename {})
    liftOver -minMatch='${MIN_MATCH}' \
        {} \
        '${CHAIN}' \
        '${OUTDIR}'/liftover/${file}.susScr11.bed \
        '${OUTDIR}'/liftover/${file}.unmap.txt
'

# ------------------------------------------------------------
# 5. Merge lifted conservation scores
# ------------------------------------------------------------

cat ${OUTDIR}/liftover/*.susScr11.bed \
    | sort -k1,1 -k2,2n \
    | bgzip -@ ${THREADS} -c \
    > ${OUTDIR}/Pig.ALLchr.hg38ToSusScr11.bed.gz

tabix -p bed -f ${OUTDIR}/Pig.ALLchr.hg38ToSusScr11.bed.gz

# ------------------------------------------------------------
# 6. Calculate mean conservation score for target intervals
# ------------------------------------------------------------

ls ${TARGET_BED_DIR}/${TARGET_PATTERN} | while read -r id
 do
    file=$(basename ${id})
    echo "Calculating conservation score for ${file}"

    bedtools map \
        -split \
        -sorted \
        -a ${id} \
        -b ${OUTDIR}/Pig.ALLchr.hg38ToSusScr11.bed.gz \
        -o mean \
        > ${OUTDIR}/score/${file}.conservation_score.txt
 done
