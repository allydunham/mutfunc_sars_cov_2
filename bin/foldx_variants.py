#!/usr/bin/env python
"""
Generate list of all possible variants from a PDB file
"""
import argparse
import warnings
import json
from pathlib import Path
from Bio.PDB import PDBParser
from Bio.SeqUtils import seq1
from region import ProteinRegion

AMINO_ACIDS = 'ACDEFGHIKLMNPQRSTVWY'

def main(args):
    """
    Generate list of all possible variants from a PDB file
    """
    pdb = Path(args.pdb)
    pdb_parser = PDBParser()
    structure = pdb_parser.get_structure(pdb.stem, pdb)

    if args.swissmodel:
        with open(args.swissmodel, 'r') as info_json:
            swissmodel = json.load(info_json)
            sections = []
            for region in swissmodel['residue_range']
                chain = region['chain']
                pos =f"{region['residue_from']}:{region['residue_to']}"
                sections.append(ProteinRegion(chain=chain, positions=pos))

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
    parser.add_argument('--swissmodel', '-s', help="SWISS-MODEL info JSON describing a model")

    return parser.parse_args()

if __name__ == "__main__":
    ARGS = parse_args()
    main(ARGS)