#!/usr/bin/env python3
"""
Apply additional repairs to FoldX RepairPDB output. Currently:

* Change numerical chain identifiers to letters (seems to be required by
  FoldX to input mutations)
"""
import argparse
import sys
from pathlib import Path
from Bio.PDB import PDBParser, PDBIO
from pdb_repair import chains_to_letters

def main(args):
    """Main"""
    pdb_path = Path(args.pdb)
    pdb_parser = PDBParser()
    structure = pdb_parser.get_structure(pdb_path.stem, pdb_path)
    chains = [c.id for c in structure[0]]
    chain_map = chains_to_letters(chains)

    for chain in structure[0]:
        chain.id = chain_map[chain.id]

    writer = PDBIO()
    writer.set_structure(structure)
    writer.save(sys.stdout, preserve_atom_numbering=True)


def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('pdb', metavar='P', help="Input PDB file")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())
