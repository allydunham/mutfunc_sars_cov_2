#!/usr/bin/env python3
"""
Generate overall table of FoldX results across all genes
"""
import argparse
import logging
from pathlib import Path

def get_template(path, model):
    """
    Identify template for a given model based on the model table
    """
    with open(path, 'r') as models_file:
        for line in models_file:
            line = line.strip().split('\t')
            if line[0] == model:
                return line[1]
    return None

def main(args):
    """
    Main
    """
    print('uniprot', 'name', 'model', 'template', 'chain',
          'position', 'wt', 'mut', 'sd', 'total_energy',
          'backbone_hbond', 'sidechain_hbond', 'van_der_waals', 'electrostatics',
          'solvation_polar', 'solvation_hydrophobic', 'van_der_waals_clashes',
          'entropy_sidechain', 'entropy_mainchain', 'sloop_entropy', 'mloop_entropy',
          'cis_bond' 'torsional_clash', 'backbone_clash', 'helix_dipole',
          'water_bridge', 'disulfide', 'electrostatic_kon',
          'partial_covalent_bonds', 'energy_ionisation',
          'entropy_complex', sep='\t')

    for foldx_path in args.foldx:
        uniprot, protein, model = Path(foldx_path).parent.stem.split('_')
        try:
            template = get_template(f'{args.models}/{uniprot}_{protein}.models', model)
        except FileNotFoundError:
            logging.warning('Not .models file found for %s_%s', uniprot, protein)
            template = None

        with open(foldx_path, 'r') as foldx_file:
            next(foldx_file)
            for line in foldx_file:
                print(uniprot, protein, model, template if template is not None else 'NA',
                      line.strip(), sep='\t')

def parse_args():
    """
    Parse arguments
    """
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('foldx', metavar='F', nargs='+', help="FoldX output files")
    parser.add_argument('--models', '-m', default='data/swissmodel',
                        help="Directory containing .models tables")

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())
