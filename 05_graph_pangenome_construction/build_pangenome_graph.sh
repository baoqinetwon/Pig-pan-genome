#!/usr/bin/env bash
# Build graph pangenome and VG/Giraffe indexes.
# Adapt paths, reference files, chromosome names, and thread numbers before running.
set -euo pipefail

VG=${VG:-vg}
REF=${REF:-/path/to/reference.fa}
VCF=${VCF:-/path/to/all_variants.vcf.gz}
OUT_PREFIX=${OUT_PREFIX:-PGG}
THREADS=${THREADS:-16}
CHROMS=${CHROMS:-"1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 X"}

mkdir -p graph_by_chr

# Construct chromosome-level graphs.
for chr in ${CHROMS}; do
    ${VG} construct \
        -t ${THREADS} \
        -r ${REF} \
        -v ${VCF} \
        -a -f -S -R ${chr} -C \
    | ${VG} ids --sort - \
    > graph_by_chr/chr_${chr}.vg
done

# Join node IDs across chromosome graphs.
${VG} ids --join --mapping ${OUT_PREFIX}.mapping graph_by_chr/*.vg

# Build XG index.
${VG} index -L -t ${THREADS} -x ${OUT_PREFIX}.xg graph_by_chr/*.vg

# Build GBWT, snarls, and distance index.
${VG} gbwt -n ${THREADS} -g ${OUT_PREFIX}.gg -o ${OUT_PREFIX}.gbwt -x ${OUT_PREFIX}.xg -P
${VG} snarls -t ${THREADS} --include-trivial ${OUT_PREFIX}.xg > ${OUT_PREFIX}.trivial.snarls
${VG} index -t ${THREADS} -j ${OUT_PREFIX}.dist -x ${OUT_PREFIX}.xg -s ${OUT_PREFIX}.trivial.snarls

# Build VG/Giraffe autoindex.
${VG} autoindex \
    --workflow giraffe \
    -t ${THREADS} \
    -r ${REF} \
    -v ${VCF} \
    -p ${OUT_PREFIX}.giraffe

${VG} snarls ${OUT_PREFIX}.giraffe.gbz -t ${THREADS} > ${OUT_PREFIX}.snarls
