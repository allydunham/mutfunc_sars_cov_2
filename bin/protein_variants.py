#!/usr/bin/env python3
"""
Append all possible amino acid mutations to input
"""
import argparse
import re

AMINO_ACIDS = 'ACDEFGHIKLMNPQRSTVWY'

# FoldX includes additional codes for AA states (e.g. charged), which we want to
# change back to the generic
FOLDX_CODES = {'y': 'T', 'p': 'Y', 's': 'S', 'h': 'P', 'z': 'Y',
               'k': 'K', 'm': 'K', 'l': 'K', 'o': 'H', 'e': 'H',
               'f': 'H'}

def main(args):
    """Main"""
    wt_aas = set(args.positions) if args.unique else args.positions

    if args.regex is not None:
        pattern = re.compile(args.regex)
        wt_aas = [x for x in wt_aas if pattern.match(x)]

    if args.sort is not None:
        wt_aas = sorted(list(wt_aas), key=lambda x: int(x[args.sort:]))

    for position in wt_aas:
        if args.wt is not None:
            wt = position[args.wt]
            if args.foldx and wt in FOLDX_CODES:
                wt = FOLDX_CODES[wt]

        for mut in AMINO_ACIDS:
            if args.exclude and wt == mut:
                continue
            print(position, mut, end=args.suffix, sep='')

def parse_args():
    """Parse arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('positions', metavar='P', nargs='+', help="Protein positions to mutate")

    parser.add_argument('--wt', '-w', default=None, type=int,
                        help="Position of the WT amino acid in the string")

    parser.add_argument('--exclude', '-e', action='store_true',
                        help="Do not mutate to the WT amino acid")

    parser.add_argument('--foldx', '-f', action='store_true',
                        help=("Treat FoldX's special AA codes (e.g. o for charged H) as ",
                              "the regular AA for excluding the WT"))

    parser.add_argument('--suffix', '-s', default='\n', type=str,
                        help="Append each mutation with this string")

    parser.add_argument('--unique', '-u', action='store_true',
                        help="Only generate unique variants")

    parser.add_argument('--sort', '-o', default=None, type=int,
                        help="Index of start of position in string, to sort on")

    parser.add_argument('--regex', '-r', default=None, type=str,
                        help="Only keep inputs matching the given pattern")

    args = parser.parse_args()
    if args.wt is None and args.exclude:
        raise ValueError('--wt/-w is required to use --exclude/-e')

    if args.wt is None and args.foldx:
        raise ValueError('--wt/-w is required to use --foldx/-f')

    return args

if __name__ == '__main__':
    main(parse_args())
