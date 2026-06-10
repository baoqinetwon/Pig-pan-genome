#!/usr/bin/env python3
# Filter extremely long insertion/deletion alleles from a VCF.
# Usage: python filter_indel_length.py input.vcf 100000 > output.vcf

import sys


def main(vcf_file, max_len):
    with open(vcf_file) as f:
        for line in f:
            if line.startswith("#"):
                print(line.rstrip())
                continue
            fields = line.rstrip("\n").split("\t")
            ref = fields[3]
            alts = fields[4].split(",")
            keep = True
            for alt in alts:
                if alt.startswith("<"):
                    continue
                if abs(len(ref) - len(alt)) > max_len:
                    keep = False
                    break
            if keep:
                print(line.rstrip())


if __name__ == "__main__":
    if len(sys.argv) not in (2, 3):
        sys.exit("Usage: python filter_indel_length.py input.vcf [max_len]")
    max_len = int(sys.argv[2]) if len(sys.argv) == 3 else 100000
    main(sys.argv[1], max_len)
