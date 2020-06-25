#!/usr/bin/env python3
"""
Process PTM data into a standard output table
"""
import sys
import argparse
from pathlib import Path
import pandas as pd
from ruamel.yaml import YAML

UNIPROT_IDS = {
    'nsp1': 'P0DTD1', 'nsp2': 'P0DTD1', 'nsp3': 'P0DTD1',
    'nsp4': 'P0DTD1', 'nsp5': 'P0DTD1', 'nsp6': 'P0DTD1',
    'nsp7': 'P0DTD1', 'nsp8': 'P0DTD1', 'nsp9': 'P0DTD1',
    'nsp10': 'P0DTD1', 'nsp12': 'P0DTD1', 'nsp13': 'P0DTD1',
    'nsp14': 'P0DTD1', 'nsp15': 'P0DTD1', 'nsp16': 'P0DTD1',
    'nsp11': 'P0DTC1', 's': 'P0DTC2', 'orf3a': 'P0DTC3',
    'e': 'P0DTC4', 'm': 'P0DTC5', 'orf6': 'P0DTC6',
    'orf7a': 'P0DTC7', 'orf7b': 'P0DTD8', 'orf8': 'P0DTC8',
    'nc': 'P0DTC9', 'orf10': 'A0A663DJA2', 'orf9b': 'P0DTD2',
    'orf14': 'P0DTD3'
}

def main(args):
    """
    Import raw PTM tables and combine them into a unified data frame
    """
    yaml = YAML(typ='safe')
    config = yaml.load(Path(args.config))['ptms']

    phospho_names = ['protein', 'position', 'experiment', 'ala_score', 'asp_score',
                     'glu_score', 'n_seq', 'kinase1', 'kinase1_p', 'kinase2',
                     'kinase2_p', 'secondary_structure', 'relative_asa']
    phospho = pd.read_csv(config['phosphorylation'], sep='\t', header=0,
                          names=phospho_names)
    phospho.loc[phospho.protein == 'N', 'protein'] = 'NC'
    phospho.protein = phospho.protein.str.lower()
    phospho['uniprot'] = [UNIPROT_IDS[i.lower()] for i in phospho.protein]
    phospho = phospho.rename(columns={'protein': 'name'})
    phospho['wt'] = phospho.position.str.get(0)
    phospho['position'] = phospho.position.str.slice(start=1).astype(int)
    phospho['ptm'] = 'phosphosite'

    cols = ['uniprot', 'name', 'position', 'wt', 'ptm', 'experiment', 'ala_score', 'asp_score',
            'glu_score', 'n_seq', 'kinase1', 'kinase1_p', 'kinase2', 'kinase2_p',
            'secondary_structure', 'relative_asa']
    phospho = phospho[cols]
    phospho.to_csv(sys.stdout, sep='\t', index=False)

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('--config', '-c', default='snakemake.yaml',
                        help="YAML config file giving paths to PTM tables")

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())
