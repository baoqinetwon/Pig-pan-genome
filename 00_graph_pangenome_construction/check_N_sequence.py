#!/usr/bin/env python3
# Check whether VCF alleles contain ambiguous N bases.

import sys


def main(vcf_file):
    with open(vcf_file) as f:
        for line in f:
            if line.startswith("#"):
                continue
            fields = line.rstrip("\n").split("\t")
            chrom, pos, vid, ref, alt = fields[:5]
            if "N" in ref.upper() or "N" in alt.upper():
                print("\t".join([chrom, pos, vid, ref, alt]))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("Usage: python check_N_sequence.py input.vcf")
    main(sys.argv[1])
