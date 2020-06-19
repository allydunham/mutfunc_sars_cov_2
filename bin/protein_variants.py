#!/usr/bin/env python3
"""
Append all amino acid mutations to the end of input arguments
"""
import argparse

AMINO_ACIDS = 'ACDEFGHIKLMNPQRSTVWY'

def main(args):
    """Main"""
    wt_aas = set(args.positions) if args.unique else args.positions

    if args.sort is not None:
        wt_aas = sorted(list(wt_aas), key=lambda x: int(x[args.sort:]))

    for position in wt_aas:
        for mut in AMINO_ACIDS:
            if args.exclude is not None and position[args.exclude] == mut:
                continue
            print(position, mut, end=args.suffix, sep='')

def parse_args():
    """Parse arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('positions', metavar='P', nargs='+', help="Protein positions to mutate")

    parser.add_argument('--exclude', '-e', default=None, type=int,
                        help="Do not mutate to the amino acid at this position in the string")

    parser.add_argument('--suffix', '-s', default='\n', type=str,
                        help="Append each mutation with this string")

    parser.add_argument('--unique', '-u', action='store_true',
                        help="Only generate unique variants")

    parser.add_argument('--sort', '-o', default=None, type=int,
                        help="Index of start of position in string, to sort on")

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())