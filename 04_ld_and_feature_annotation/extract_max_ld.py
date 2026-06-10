#!/usr/bin/env python3
# Extract maximum LD value for each variant from PLINK LD output.

import gzip
import sys
from collections import defaultdict


def open_text(path):
    if path.endswith(".gz"):
        return gzip.open(path, "rt")
    return open(path, "r")


def main(ld_file):
    max_ld = defaultdict(float)
    with open_text(ld_file) as f:
        header = f.readline().strip().split()
        idx_snp_a = header.index("SNP_A")
        idx_snp_b = header.index("SNP_B")
        idx_r2 = header.index("R2")
        for line in f:
            if not line.strip():
                continue
            fields = line.strip().split()
            snp_a = fields[idx_snp_a]
            snp_b = fields[idx_snp_b]
            r2 = float(fields[idx_r2])
            if r2 > max_ld[snp_a]:
                max_ld[snp_a] = r2
            if r2 > max_ld[snp_b]:
                max_ld[snp_b] = r2

    print("variant\tmax_r2")
    for variant, r2 in sorted(max_ld.items()):
        print(f"{variant}\t{r2}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python extract_max_ld.py <plink.ld[.gz]>", file=sys.stderr)
        sys.exit(1)
    main(sys.argv[1])
