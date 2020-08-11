"""
Convert a SIFT4G alignment into a JSON file for the frontend
"""
import sys
import argparse
import json
from Bio import SeqIO

def format_name(seq):
    """
    Generate a name from a Uniref fasta sequence SeqRecord
    """
    return seq.id.split('_')[1]

def main(args):
    """
    Import Fasta file and parse into a JSON suitable for JS MSA viewers
    """
    seqs = list(SeqIO.parse(args.fasta, "fasta"))
    seqs = [{'name': args.query if s.id == 'QUERY' else format_name(s),
             'sequence': str(s.seq).replace('X', '-')} for s in seqs]
    json.dump(seqs, sys.stdout)

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('fasta', metavar='F', help="Fasta alignment file")

    parser.add_argument('--query', '-q', help="Name of query protein")

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())
