#!/usr/bin/env python3
# Calculate average INFO/DP across VCF records.
# Adapt the input VCF path before running.

import pysam
import numpy as np


def calculate_average_depth(vcf_file):
    vcf = pysam.VariantFile(vcf_file)
    depths = []

    for record in vcf.fetch():
        dp = record.info.get("DP")
        if dp is not None:
            depths.append(dp)

    if depths:
        average_depth = np.mean(depths)
        print("Average INFO/DP:", average_depth)
    else:
        print("No INFO/DP values found")


if __name__ == "__main__":
    vcf_file = "panel_2991.vcf"
    calculate_average_depth(vcf_file)
