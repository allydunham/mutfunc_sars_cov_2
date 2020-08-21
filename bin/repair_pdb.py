#!/usr/bin/env python3
"""
Apply additional repairs to FoldX RepairPDB output. Currently:

* Change numerical chain identifiers to letters (seems to be required by
  FoldX to input mutations)
"""
import argparse
import string
import sys
from pathlib import Path
from Bio.PDB import PDBParser, PDBIO

LETTERS = string.ascii_uppercase + string.ascii_lowercase

def chains_to_letter(chains):
    """
    Make a dictionary converting chain non-letter symbols into letters (since only
    these are supported by FoldX)
    """
    chain_map = {i: i for i in chains if i in LETTERS + ' '}
    bad_chains = [i for i in chains if not i in LETTERS + ' ']
    remaining_letters = [i for i in LETTERS if not i in chain_map.keys()]

    if len(remaining_letters) < len(bad_chains):
        raise ValueError(('Exhausted the allowed chain IDs - more numerical '
                          'chains than remaining letters'))

    for i, chain in enumerate(bad_chains):
        chain_map[chain] = remaining_letters[i]

    return chain_map

def main(args):
    """Main"""
    pdb_path = Path(args.pdb)
    pdb_parser = PDBParser()
    structure = pdb_parser.get_structure(pdb_path.stem, pdb_path)
    chains = [c.id for c in structure[0]]
    chain_map = chains_to_letter(chains)

    for chain in structure[0]:
        chain.id = chain_map[chain.id]

    writer = PDBIO()
    writer.set_structure(structure)
    with open('test.pdb', 'w') as pdb_file:
        writer.save(sys.stdout, preserve_atom_numbering=True)


def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('pdb', metavar='P', help="Input PDB file")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())