#!/usr/bin/env python
"""
Generate list of all possible variants from a PDB file
"""
import argparse
import warnings
from ruamel.yaml import YAML
from pathlib import Path
from Bio.PDB import PDBParser
from Bio.SeqUtils import seq1

AMINO_ACIDS = 'ACDEFGHIKLMNPQRSTVWY'

class ProteinRegion:
    """
    A protein region

    chain: string chain id
    positions: string representation of protein positions. Comma separated list of
    individual positions and X:Y (inclusive) ranges
    """
    def __init__(self, chain, positions, accept_hetero=False):
        self.chain = chain
        self.accept_hetero = accept_hetero
        self.positions = []
        self.positions_str = positions
        for i in positions.split(','):
            if ':' in i:
                i = i.split(':')
                self.positions.extend(range(int(i[0]), int(i[1]) + 1))

            else:
                self.positions.append(int(i))

    def __repr__(self):
        return (f'ProteinRegion({self.chain}, {self.positions_str}, '
                f'accept_hetero={self.accept_hetero})')

    def __str__(self):
        return self.__repr__()

    def __contains__(self, item):
        try:
            chain = item.full_id[2]
            position = item.id[1]
            hetero = not item.id[0] == ' '
        except AttributeError:
            warnings.warn((f'Tried to check membership of "{residue}".'
                           'Only biopython Residues can be in a ProteinRegion'))
            return False

        return (self.chain == chain and
                position in self.positions and
                (not hetero or self.accept_hetero))


def main(args):
    """
    Generate list of all possible variants from a PDB file
    """
    pdb = Path(args.pdb)
    pdb_parser = PDBParser()
    structure = pdb_parser.get_structure(pdb.stem, pdb)

    sections = []
    chains = []
    if args.yaml:
        yaml_parser = YAML(typ='safe')
        yaml = yaml_parser.load(Path(args.yaml))
        sections = [ProteinRegion(i['chain'], i['positions']) for i in yaml['sections']]
        chains = [i['chain'] for i in yaml['sections']]

    variants = []
    for chain in structure[0]:
        # Short-circuit chains we don't want, if specified
        if chains and not chain.id in chains:
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
    parser.add_argument('--yaml', '-y', help="YAML file defining sections to make variants from")

    return parser.parse_args()

if __name__ == "__main__":
    ARGS = parse_args()
    main(ARGS)