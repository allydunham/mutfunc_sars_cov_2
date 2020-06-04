#!/usr/bin/env python3
"""
Generate overall table of FoldX results across all genes
"""

def main(args):
    """
    Main
    """
    print('chain', 'position', 'wt', 'mut', 'sd', 'total_energy',
          'backbone_hbond', 'sidechain_hbond', 'van_der_waals', 'electrostatics',
          'solvation_polar', 'solvation_hydrophobic', 'van_der_waals_clashes',
          'entropy_sidechain', 'entropy_mainchain', 'sloop_entropy', 'mloop_entropy',
          'cis_bond' 'torsional_clash', 'backbone_clash', 'helix_dipole',
          'water_bridge', 'disulfide', 'electrostatic_kon',
          'partial_covalent_bonds', 'energy_ionisation',
          'entropy_complex', sep='\t')

    for foldx_path in args.foldx:
        uniprot, protein = Path(foldx_path).stem.split('_')
        with open(foldx_path, 'r') as foldx_file:
            for line in foldx_file:
                print(uniprot, protein, *fields, sep='\t')

def parse_args():
    """
    Parse arguments
    """
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('foldx', metavar='F', nargs='+', help="FoldX output files")

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())