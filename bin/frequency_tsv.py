#!/usr/bin/env python3
"""
Exctract variant frequencies from VCF and map based on GFF file
"""
import argparse
import gzip

def import_gene_map(gff_file):
    """
    Import gene and transcript map between names and ensembl identifiers
    """
    transcript_map = {}
    gene_map = {}
    for line in gff_file:
        if line[0] == '#':
            continue
        line = line.strip().split('\t')
        attributes = dict([i.split('=') for i in line[8].split(';')])
        if line[2] == 'gene':
            gene_map[attributes['gene_id']] = attributes['Name'].lower()
        elif line[2] == 'mRNA':
            transcript_map[attributes['transcript_id']] = attributes['Name'].lower()
    return gene_map, transcript_map

def main(args):
    """Main"""
    with gzip.open(args.annotation, 'rt') as gff_file:
        gene_map, transcript_map = import_gene_map(gff_file)

def parse_args():
    """Parse arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('vep', metavar='V', help='VEP Predictions')
    parser.add_argument('freqs', metavar='F', help='Allele frequencies')
    parser.add_argument('annotation', metavar='A', help='GFF Annotation file')

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())