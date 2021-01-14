#!/usr/bin/env python3
"""
Manage Naccess runs to calculate surface accessibility for SWISS-Model PDB downloads
"""
import argparse
import subprocess
import os
import sys
from pathlib import Path

import pandas as pd
from Bio.PDB import PDBParser
from Bio.PDB.NACCESS import process_rsa_data
from Bio.PDB.PDBIO import PDBIO, Select
from Bio.SeqUtils import seq1

def parse_model_table(path):
    """
    Parse SWISS-Model model table output by the SWISS-Model select rule, outputing
    a pandas df
    """
    uniprot, name = Path(path).stem.split('_')
    df = pd.read_csv(path, sep='\t', dtype=str)
    df['uniprot'] = uniprot
    df['name'] = name
    return df

class ChainSelect(Select):
    """
    bio.PDB.PDBIO.Select subclass filtering to a given chain
    """
    def __init__(self, chain):
        self.chain = chain
        super().__init__()

    def accept_chain(self, chain):
        return 1 if chain.id == self.chain else 0

def filter_pdb(input_path, output_path, chain):
    """
    Filter a PDB file to the chain of interest
    """
    pdb_name = Path(input_path).stem
    pdb_parser = PDBParser()
    structure = pdb_parser.get_structure(pdb_name, input_path)
    pdbio = PDBIO()
    pdbio.set_structure(structure)
    pdbio.save(output_path, select=ChainSelect(chain))

def run_naccess(pdb_path):
    """
    Run Naccess on a PDB file
    """
    command = ['naccess', pdb_path]
    subprocess.run(command, capture_output=True)

def read_naccess_rsa(model):
    """
    Import a Naccess output RSA table, based on a model row imported by parse_model_table
    """
    with open(f'{model.uniprot}_{model.name}_{model.model}.rsa', 'r') as rsa_file:
        rsa_data = process_rsa_data(rsa_file)
    df = pd.DataFrame.from_dict(rsa_data, orient='index').reset_index()
    df = df.rename(columns={'level_0': 'chain', 'level_1': 'position', 'res_name': 'wt'})
    df['position'] = [i[1] for i in df['position']]
    df['uniprot'] = model.uniprot
    df['name'] = model.name
    df['template'] = model.template
    df['wt'] = [seq1(i) for i in df['wt']]
    positions = [int(i) for i in model.positions.split(',')]
    df = df[df['position'].isin(positions)]
    df = df['uniprot', 'name', 'position', 'wt', 'template', 'chain', 'all_atoms_abs',
            'all_atoms_rel', 'side_chain_abs', 'side_chain_rel', 'main_chain_abs',
            'main_chain_rel', 'non_polar_abs', 'non_polar_rel', 'all_polar_abs',
            'all_polar_rel']
    return df

def main(args):
    """Import model tables, filter PDB files, pass them to Naccess and generate an overall tsv"""
    # Check working dir
    if not os.path.isdir(args.dir):
        os.mkdir(args.dir)

    # Import models to process
    print('Reading model tables...', end=' ')
    models = pd.concat([parse_model_table(i) for i in args.models], axis=0).reset_index(drop=True)
    print('done')

    # Filter PDB for Naccess
    for model in models.itertuples():
        path = f'data/swissmodel/{model.uniprot}_{model.name}/{model.model}/model.pdb'
        print('Filtering ', path, '...', sep='', end=' ')
        filter_pdb(path, f'{args.dir}/{model.uniprot}_{model.name}_{model.model}.pdb', model.chain)
        print('done')

    # Run Naccess and load results
    os.chdir(args.dir)
    accessibility = []
    for model in models.itertuples():
        path = f'{model.uniprot}_{model.name}_{model.model}.pdb'
        print('Running Naccess on', path)
        run_naccess(path)
        accessibility.append(read_naccess_rsa(model))

    tsv = pd.concat(accessibility, axis=0).reset_index(drop=True)
    tsv.to_csv(sys.stdout, sep='\t', index=False, float_format='%.7g')

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('models', metavar='M', nargs='+',
                        help="Model tables generated from SWISS-Model download")
    parser.add_argument('--dir', '-d', help="Directory to store Naccess outputs")

    # args = parser.parse_args(["-d", "data/naccess", "data/swissmodel/P0DTC2_s.models", "data/swissmodel/P0DTC3_orf3a.models", "data/swissmodel/P0DTC4_e.models", "data/swissmodel/P0DTC5_m.models", "data/swissmodel/P0DTC6_orf6.models", "data/swissmodel/P0DTC7_orf7a.models", "data/swissmodel/P0DTC8_orf8.models", "data/swissmodel/P0DTC9_nc.models", "data/swissmodel/P0DTD1_nsp1.models", "data/swissmodel/P0DTD1_nsp10.models", "data/swissmodel/P0DTD1_nsp12.models", "data/swissmodel/P0DTD1_nsp13.models", "data/swissmodel/P0DTD1_nsp14.models", "data/swissmodel/P0DTD1_nsp15.models", "data/swissmodel/P0DTD1_nsp16.models", "data/swissmodel/P0DTD1_nsp2.models", "data/swissmodel/P0DTD1_nsp3.models", "data/swissmodel/P0DTD1_nsp4.models", "data/swissmodel/P0DTD1_nsp5.models", "data/swissmodel/P0DTD1_nsp6.models", "data/swissmodel/P0DTD1_nsp7.models", "data/swissmodel/P0DTD1_nsp8.models", "data/swissmodel/P0DTD1_nsp9.models", "data/swissmodel/P0DTD2_orf9b.models"])
    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())