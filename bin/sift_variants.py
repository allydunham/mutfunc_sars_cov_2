#!/usr/bin/env python3
"""
Generate substitutions file for SIFT4G
"""
import argparse
import Bio.SeqIO

AMINO_ACIDS = 'ACDEFGHIKLMNPQRSTVWY'

def main(args):
    """
    Import a fasta sequence and print all substitutions in SIFT4G format. Assumes a single
    sequence in the file
    """

    seq = list(Bio.SeqIO.parse(args.fasta, 'fasta'))[0]

    variants = []
    for i, wt in enumerate(seq.seq):
        variants.extend(f'{wt}{i + 1}{mut}' for mut in AMINO_ACIDS if not wt == mut)

    print(*variants, seq='\n')

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('fasta', metavar='F', help="Input fasta file")

    return parser.parse_args()

if __name__ == "__main__":
    ARGS = parse_args()
    main(ARGS)