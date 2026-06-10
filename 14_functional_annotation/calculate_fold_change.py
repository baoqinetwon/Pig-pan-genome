#!/usr/bin/env python3
# Calculate fold change between two numeric signal columns.
# Usage: python calculate_fold_change.py input.tsv value_col1 value_col2 output.tsv

import sys
import pandas as pd


def main():
    if len(sys.argv) != 5:
        sys.exit("Usage: python calculate_fold_change.py <input.tsv> <numerator_col> <denominator_col> <output.tsv>")

    infile, num_col, den_col, outfile = sys.argv[1:]
    df = pd.read_csv(infile, sep="\t")

    if num_col not in df.columns or den_col not in df.columns:
        raise ValueError("Input columns were not found in the table")

    df["fold_change"] = (df[num_col].astype(float) + 1e-9) / (df[den_col].astype(float) + 1e-9)
    df["log2_fold_change"] = df["fold_change"].apply(lambda x: pd.NA if x <= 0 else __import__("math").log2(x))
    df.to_csv(outfile, sep="\t", index=False)


if __name__ == "__main__":
    main()
