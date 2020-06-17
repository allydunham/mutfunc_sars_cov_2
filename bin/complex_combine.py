#!/usr/bin/env python3
"""
Combine output files from batch FoldX AnalyseComplex command.
Files must be named as FoldX names them - e.g. Interaction_NAME(_Repair)_N_AC.fxout where N is the
PDB number in PDB list. The processing to use will determined from filenames.
"""
import argparse
from dataclasses import dataclass
from pathlib import Path

@dataclass
class Mutation:
    chain: str
    position: int
    wt: str
    mut: str

    @staticmethod
    def from_foldx_str(foldx_str):
        """Generate a Mutation from a FoldX formated mutation string"""
        foldx_str = foldx_str.strip(';')
        return Mutation(foldx_str[1], int(foldx_str[2:-1]), foldx_str[0], foldx_str[-1])

def combine_interaction(mutations, foldx_paths):
    """Combine Interaction files"""
    print('chain', 'position', 'wt', 'mut',
          'chain1', 'chain2', 'intraclashesgroup1', 'intraclashesgroup2',
          'interaction_energy', 'backbone_hbond', 'sidechain_hbond', 'van_der_waals',
          'electrostatics', 'solvation_polar', 'solvation_hydrophobic', 'van_der_waals',
          'clashes', 'entropy_sidechain', 'entropy_mainchain', 'sloop_entropy',
          'mloop_entropy', 'cis_bond', 'torsional_clash', 'backbone_clash', 'helix_dipole',
          'water_bridge', 'disulfide', 'electrostatic_kon', 'partial_covalent_bonds',
          'energy_ionisation', 'entropy_complex', 'number_of_residues',
          'interface_residues', 'interface_residues_clashing',
          'interface_residues_vdw_clashing', 'interface_residues_bb_clashing', sep='\t')

    for path in foldx_paths:
        num = int(path.split('_')[-2])
        mutation = mutations[num - 1]
        with open(path, 'r') as foldx_file:
            line = foldx_file.readlines()[-1].strip().split('\t')
        print(mutation.chain, mutation.position, mutation.wt, mutation.mut,
              *line[1:], sep='\t')

def combine_individual_energies(mutations, foldx_paths):
    """Combine Individual Energy files"""
    print('chain', 'position', 'wt', 'mut', 'group', 'total_energy',
          'backbone_hbond', 'sidechain_hbond', 'van_der_waals', 'electrostatics',
          'solvation_polar', 'solvation_hydrophobic', 'van_der_waals_clashes',
          'entropy_sidechain', 'entropy_mainchain', 'sloop_entropy', 'sloop_entropy',
          'cis_bond', 'torsional_clash', 'backbone_clash', 'helix_dipole',
          'water_bridge', 'disulfide', 'electrostatic_kon', 'partial_covalent_bonds', 'energy_ionisation', 'entropy_complex', sep='\t')
    for path in foldx_paths:
        num = int(path.split('_')[-2])
        mutation = mutations[num - 1]
        with open(path, 'r') as foldx_file:
            lines = foldx_file.readlines()[9:]

        for line in lines:
            print(mutation.chain, mutation.position, mutation.wt, mutation.mut,
                  *line.strip().split('\t')[1:], sep='\t')

def combine_interface_residues(mutations, foldx_paths):
    """Combine Interface Residue files"""
    print('chain', 'position', 'wt', 'mut', 'interface_residues', sep='\t')
    for path in foldx_paths:
        num = int(path.split('_')[-2])
        mutation = mutations[num - 1]
        with open(path, 'r') as foldx_file:
            interface_residues = foldx_file.readlines()[-1].strip().split('\t')
        print(mutation.chain, mutation.position, mutation.wt, mutation.mut,
              ','.join(interface_residues), sep='\t')

def combine_summary(mutations, foldx_paths):
    """Combine Summary files"""
    print('chain', 'position', 'wt', 'mut', 'group1', 'group2',
          'intraclashesgroup1', 'intraclashesgroup2', 'interaction_energy',
          'stabilitygroup1', 'stabilitygroup2', sep='\t')
    for path in foldx_paths:
        num = int(path.split('_')[-2])
        mutation = mutations[num - 1]
        with open(path, 'r') as foldx_file:
            summary = foldx_file.readlines()[-1].strip().split('\t')
        print(mutation.chain, mutation.position, mutation.wt, mutation.mut,
              *summary[2:], sep='\t')

def detect_filetype(*files):
    """
    Detect FoldX filetype from the filenames
    """
    filetype = None
    for file in files:
        file = Path(file).stem
        new_filetype = file.split('_')[0]
        if filetype is None:
            filetype = new_filetype
        if not filetype == new_filetype:
            raise ValueError(f'Files are not the same type: found {filetype} and {new_filetype}')
    return filetype.lower()

def read_mutations(path):
    """
    Read mutations from a FoldX individual list file
    """
    with open(path, 'r') as individual_list:
        mutations = [Mutation.from_foldx_str(i.strip()) for i in individual_list]
    return mutations

def main(args):
    """Main"""
    filetype = detect_filetype(*args.foldx)
    mutations = read_mutations(args.mutations)
    if filetype == 'interface':
        combine_interface_residues(mutations, args.foldx)
    elif filetype == 'interaction':
        combine_interaction(mutations, args.foldx)
    elif filetype == 'indiv':
        combine_individual_energies(mutations, args.foldx)
    elif filetype == 'summary':
        combine_summary(mutations, args.foldx)
    else:
        raise ValueError('Unknown type detected')

def parse_args():
    """Parse Arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('mutations', metavar='M', help="Individual list file")
    parser.add_argument('foldx', metavar='F', nargs='+', help="FoldX output files")

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())
