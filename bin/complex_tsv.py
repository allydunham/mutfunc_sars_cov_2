#!/usr/bin/env python3
"""
Combine FoldX AnalyseComplex output from many complexes
"""
import sys
import argparse
import pandas as pd
from ruamel.yaml import YAML
from pathlib import Path

def import_complex_dir(path):
    """
    Import tables from an AnalyseComplex output directory
    """
    path = path.rstrip('/')
    yaml_parser = YAML(typ='safe')
    proteins = yaml_parser.load(Path(f'{path}/model.yaml'))
    interactions = pd.read_csv(f'{path}/interactions.tsv', sep='\t')
    interactions = interactions.rename({'interface_residues': 'number_of_interface_residues'},
                                       axis='columns')
    interface = pd.read_csv(f'{path}/interface_residues.tsv', sep='\t')
    comb = pd.merge(interactions, interface, how='outer', on=['chain', 'position', 'wt', 'mut'])
    comb = comb.rename({'chain': 'mut_chain'}, axis='columns')
    chain1 = comb.chain1[0]
    chain2 = comb.chain2[0]
    comb['uniprot1'] = proteins[chain1]['uniprot']
    comb['protein1'] = proteins[chain1]['name']
    comb['uniprot2'] = proteins[chain2]['uniprot']
    comb['protein2'] = proteins[chain2]['name']
    cols = ['uniprot1', 'protein1', 'chain1', 'uniprot2', 'protein2', 'chain2']
    comb = comb[cols + [c for c in comb.columns if not c in cols]]
    return comb

def main(args):
    """Main"""
    complex_dfs = [import_complex_dir(d) for d in args.dirs]
    complexes = pd.concat(complex_dfs)
    sort_cols = ['uniprot1', 'protein1', 'uniprot2', 'protein2', 'mut_chain', 'position', 'mut']
    complexes = complexes.sort_values(axis='rows', by=sort_cols).reset_index(drop=True)
    complexes.to_csv(sys.stdout, sep='\t', index=False)

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('dirs', metavar='D', nargs='+', help="Directories to pull output from")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())