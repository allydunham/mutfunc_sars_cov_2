#!/usr/bin/env python3
"""
Filter NCBI datasets coronviridae protein fasta file to create a SIFT4G
database without duplicates
"""
import sys
import argparse
from Bio import SeqIO

def filter_fastas(path):
    # Use specified Isolates for cases with many closely related strains
    organism_isolates = {
        'Severe acute respiratory syndrome coronavirus 2': 'Wuhan-Hu-1',
        : '',
        'Middle East respiratory syndrome-related coronavirus': '',
        'Severe acute respiratory syndrome-related coronavirus': ''
    }

    for seq in SeqIO.parse(path, "fasta"):
        desc = seq.description
        organism = desc.split('organism=')[1].split(']')[0] if 'organism=' in desc else None
        isolate = desc.split('isolate=')[1].split(']')[0] if 'isolate=' in desc else None

        # Apply filters
        if (organism == 'Severe acute respiratory syndrome coronavirus 2' and
            isolate != 'Wuhan-Hu-1'):
            continue

        if (organism.startswith('SARS coronavirus') and not organism.endswith('Urbani')):
            continue

        if (organism == 'Middle East respiratory syndrome-related coronavirus' and
            isolate != 'HCoV-EMC/2012'):
            continue

        if (organism == 'Severe acute respiratory syndrome-related coronavirus' and
            isolate is None):
            continue

        yield seq



def main():
    """Main"""
    organism_isolates = {'organism=Severe acute respiratory syndrome coronavirus 2',
                         'organism=SARS coronavirus',
                         'organism=Middle East respiratory syndrome-related coronavirus'}

    gen = (r for r in  if not any(i in r.description for i in exclude_organisms))
    SeqIO.write(filter_fastas(args.fasta), sys.stdout, "fasta")

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('fasta', metavar='F', help="Fasta file")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())