#!/usr/bin/env python3
# Remove selected INFO fields from a VCF file.
# Usage: python remove_info_fields.py input.vcf DP,AF,AC > output.vcf

import sys


def clean_info(info, remove_keys):
    if info == ".":
        return info
    kept = []
    for item in info.split(";"):
        key = item.split("=", 1)[0]
        if key not in remove_keys:
            kept.append(item)
    return ";".join(kept) if kept else "."


def main(vcf_file, keys):
    remove_keys = set(keys.split(","))
    with open(vcf_file) as f:
        for line in f:
            if line.startswith("##INFO"):
                info_id = line.split("ID=", 1)[1].split(",", 1)[0] if "ID=" in line else None
                if info_id in remove_keys:
                    continue
            if line.startswith("#"):
                print(line.rstrip())
                continue
            fields = line.rstrip("\n").split("\t")
            fields[7] = clean_info(fields[7], remove_keys)
            print("\t".join(fields))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("Usage: python remove_info_fields.py input.vcf KEY1,KEY2")
    main(sys.argv[1], sys.argv[2])
