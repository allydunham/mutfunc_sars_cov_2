#!/usr/bin/env python3
"""
Combine output from multiple SIFT4G runs
"""
import argparse
from pathlib import Path

def main(args):
    """
    Combine output from passed SIFT4G output files
    """
    print('uniprot_id', 'protein_name', 'position', 'ref', 'alt',
          'sift_prediction', 'sift_score', 'sift_median', 'num_aa',
          'num_seq', sep='\t')
    for sift_path in args.sift:
        uniprot, protein = Path(sift_path).stem.split('_')
        with open(sift_path, 'r') as sift_file:
            for line in sift_file:
                fields = line.strip().split('\t')
                ref = fields[0][0]
                alt = fields[0][-1]
                pos = fields[0][1:-1]
                print(uniprot, protein, pos, ref, alt, *fields[1:], sep='\t')

def parse_args():
    """
    Parse arguments
    """
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('sift', metavar='S', nargs='+', help="SIFT4G output files")

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())
