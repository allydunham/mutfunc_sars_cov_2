#!/usr/bin/env python3
"""
Determine sites to filter from the full problematic sites VCF
"""
import sys
import argparse

CHROM_MAP = {"MN908947.3": "NC_045512v2"}

def main(args):
    """Main"""
    selected_terms = set(args.filter)
    print('#chromosome', 'position', sep='\t')
    with open(args.vcf, 'r') as vcf_file:
        for line in vcf_file:
            if line[0] == '#':
                continue

            line = line.strip().split('\t')

            if selected_terms:
                info = [i for i in line[7].split(';') if i.startswith('EXC=')]
                info = set(info[0].split('=')[1].split(','))
                # check if any terms in both info and filter list
                if not info & selected_terms:
                    continue

            print(CHROM_MAP[line[0]], line[1], sep='\t')

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('vcf', metavar='V', help="VCF file")

    parser.add_argument('--filter', '-f', nargs='+',
                        help="Terms to filter, filtering all problematic sites by default")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())
