#!/usr/bin/env python3
"""
Split the uniprot SARS-CoV-2 fasta file into consituent proteins
"""
import argparse
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord

UNIPROT_IDS = {
    'P0DTD1': 'pp1ab', 'P0DTC1': 'pp1a', 'P0DTC2': 's',
    'P0DTC3': 'orf3a', 'P0DTC4': 'e', 'P0DTC5': 'm',
    'P0DTC6': 'orf6', 'P0DTC7': 'orf7a', 'P0DTD8': 'orf7b',
    'P0DTC8': 'orf8', 'P0DTC9': 'nc', 'A0A663DJA2': 'orf10',
    'P0DTD2': 'orf9b', 'P0DTD3': 'orf14'
}

PP1AB_SUBUNITS = {
    'nsp1': (1, 180), 'nsp2': (181, 818), 'nsp3': (819, 2763),
    'nsp4': (2764, 3263), 'nsp5': (3264, 3569), 'nsp6': (3570, 3859),
    'nsp7': (3860, 3942), 'nsp8': (3943, 4140), 'nsp9': (4141, 4253),
    'nsp10': (4254, 4392), 'nsp12': (4393, 5324), 'nsp13': (5325, 5925),
    'nsp14': (5926, 6452), 'nsp15': (6453, 6798), 'nsp16': (6799, 7096)
}

PP1A_SUBUNITS = {
    'nsp1': (1, 180), 'nsp2': (181, 818), 'nsp3': (819, 2763),
    'nsp4': (2764, 3263), 'nsp5': (3264, 3569), 'nsp6': (3570, 3859),
    'nsp7': (3860, 3942), 'nsp8': (3943, 4140), 'nsp9': (4141, 4253),
    'nsp10': (4254, 4392), 'nsp11': (4393, 4405)
}

def main(args):
    """
    Split SARS-CoV-2 input fasta into separate gene fastas, including breaking down the polyproteins
    """
    for record in SeqIO.parse(args.fasta, 'fasta'):
        uniprot_id = record.id.split('|')[1]
        record.description = ''

        # Split PP1AB
        if uniprot_id == 'P0DTD1':
            for name, region in PP1AB_SUBUNITS.items():
                seq = SeqRecord(seq=record.seq[(region[0] - 1):region[1]],
                                id=f'{uniprot_id}_{name}',
                                description='')
                SeqIO.write(seq, f'{args.outdir}/{uniprot_id}_{name}.fa', 'fasta')

        # Split PP1A - only nsp11 is different?
        elif uniprot_id == 'P0DTC1':
            name = 'nsp11'
            region = PP1A_SUBUNITS[name]
            seq = SeqRecord(seq=record.seq[(region[0] - 1):region[1]],
                            id=f'{uniprot_id}_{name}',
                            description='')
            SeqIO.write(seq, f'{args.outdir}/{uniprot_id}_{name}.fa', 'fasta')

        else:
            name = UNIPROT_IDS[uniprot_id]
            record.id = f'{uniprot_id}_{name}'
            SeqIO.write(record, f'{args.outdir}/{uniprot_id}_{name}.fa', 'fasta')

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('fasta', metavar='F', help="Input fasta file")

    parser.add_argument('--outdir', '-o',
                        help="Output directory")

    return parser.parse_args()

if __name__ == "__main__":
    ARGS = parse_args()
    main(ARGS)