#!/usr/bin/env python3
"""
Generate list of all possible variants from a PDB file, posible filtering to
a region of interest
"""
import argparse
from pathlib import Path
from Bio.PDB import PDBParser
from Bio.SeqUtils import seq1
import pandas as pd
from region import ProteinRegion

AMINO_ACIDS = 'ACDEFGHIKLMNPQRSTVWY'

def main(args):
    """
    Generate list of variants from a PDB file
    """
    pdb_path = Path(args.pdb)
    model = pdb_path.parent.stem
    pdb_parser = PDBParser()
    structure = pdb_parser.get_structure(pdb_path.stem, pdb_path)

    if args.models:
        modeldf = pd.read_csv(args.models, sep='\t', dtype={'model': str})
        modeldf = modeldf[modeldf.model == model].reset_index()
        positions = modeldf.positions[0]
        chain = modeldf.chain[0]
        sections = [ProteinRegion(chain=chain, positions=positions)]

    else:
        sections = [ProteinRegion(chain) for chain in structure[0]]

    # List of valid chains is used to completely skip chains with no valid residues
    chains = {s.chain for s in sections}

    variants = []
    for chain in structure[0]:
        # Short-circuit chains we don't want, if specified
        if not chain.id in chains:
            continue

        for residue in chain:
            if not sections or any(residue in s for s in sections):
                pos = int(residue.id[1])
                aa = seq1(residue.get_resname())
                variants.extend([f"{aa}{chain.id}{pos}{x}" for x in AMINO_ACIDS if not x == aa])

    print(*variants, sep=';\n', end=';\n')

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('pdb', metavar='P', help="Input PDB file")
    parser.add_argument('--models', '-m',
                        help=("TSV file giving details of the models and regions selected "
                              "(see swissmodel_select.py)"))
    parser.add_argument('--model', '-n', type=str, help='Model number to process')

    return parser.parse_args()

if __name__ == "__main__":
    ARGS = parse_args()
    main(ARGS)