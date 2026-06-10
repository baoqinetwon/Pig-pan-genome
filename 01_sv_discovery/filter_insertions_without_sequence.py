#!/usr/bin/env python3
# Filter insertion records without inserted sequence in ALT.

import sys


def has_insertion_sequence(ref, alt):
    if alt.startswith("<") and alt.endswith(">"):
        return False
    return len(alt) > len(ref)


def main(vcf_file):
    with open(vcf_file) as f:
        for line in f:
            if line.startswith("#"):
                print(line.rstrip())
                continue
            fields = line.rstrip("\n").split("\t")
            ref, alt, info = fields[3], fields[4], fields[7]
            if "SVTYPE=INS" in info:
                if has_insertion_sequence(ref, alt):
                    print(line.rstrip())
            else:
                print(line.rstrip())


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("Usage: filter_insertions_without_sequence.py input.vcf")
    main(sys.argv[1])
