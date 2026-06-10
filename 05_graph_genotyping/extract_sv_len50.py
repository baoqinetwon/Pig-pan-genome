#!/usr/bin/env python3
# Extract insertion/deletion alleles with length >=50 bp from a VCF.

import sys


def main(vcf_file):
    with open(vcf_file, "r") as f:
        for line in f:
            if line.startswith("#"):
                print(line.strip())
                continue

            fields = line.rstrip("\n").split("\t")
            ref = fields[3]
            alt = fields[4]

            if len(ref) == 1 and len(alt) > 49:
                print(line.strip())
            elif len(alt) == 1 and len(ref) > 49:
                print(line.strip())


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python extract_sv_len50.py <vcf_file>", file=sys.stderr)
        sys.exit(1)
    main(sys.argv[1])
