#!/usr/bin/env python3
"""
Generate a list of selected models across all genes, in {Uniprot ID}_{Name}_{Model Number} format
"""
import argparse
from pathlib import Path

def main(args):
    """
    Main
    """
    for path in args.models:
        gene = Path(path).stem
        with open(path, 'r') as model_file:
            next(model_file)
            for line in model_file:
                model_num = line.strip().split('\t')[0]
                print(f"{gene}_{model_num}")

def parse_args():
    """
    Parse arguments:
    """
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('models', metavar='M', nargs='+', help="SWISS-MODEL model summary files")

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())