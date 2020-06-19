#!/usr/bin/env python3
"""
Combine FoldX AnalyseComplex output from many complexes
"""
import sys
import argparse
import pandas as pd
from ruamel.yaml import YAML
from pathlib import Path

def import_complex_dir(path, chains):
    """
    Import tables from an AnalyseComplex output directory
    """
    path = path.rstrip('/')
    interactions = pd.read_csv(f'{path}/interactions.tsv', sep='\t')
    interactions = interactions.rename({'interface_residues': 'number_of_interface_residues'},
                                       axis='columns')
    interface = pd.read_csv(f'{path}/interface_residues.tsv', sep='\t')
    comb = pd.merge(interactions, interface, how='outer', on=['chain', 'position', 'wt', 'mut'])
    comb = comb.rename({'chain': 'mut_chain'}, axis='columns')
    comb['uniprot1'] = [chains[chain]['uniprot'] for chain in comb.chain1]
    comb['protein1'] = [chains[chain]['protein'] for chain in comb.chain1]
    comb['uniprot2'] = [chains[chain]['uniprot'] for chain in comb.chain2]
    comb['protein2'] = [chains[chain]['protein'] for chain in comb.chain2]
    cols = ['uniprot1', 'protein1', 'chain1', 'uniprot2', 'protein2', 'chain2']
    comb = comb[cols + [c for c in comb.columns if not c in cols]]
    return comb

def main(args):
    """Main"""
    complex_dfs = []
    yaml_loader = YAML(typ='safe')
    for yaml in args.yaml:
        path = Path(yaml)
        yaml = yaml_loader.load(path)
        for interface in yaml['interfaces']:
            complex_dfs.append(import_complex_dir(f'{path.parent}/{interface}'), yaml['chains'])

    complexes = pd.concat(complex_dfs)
    sort_cols = ['uniprot1', 'protein1', 'uniprot2', 'protein2', 'mut_chain', 'position', 'mut']
    complexes = complexes.sort_values(axis='rows', by=sort_cols).reset_index(drop=True)
    complexes.to_csv(sys.stdout, sep='\t', index=False)

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('yaml', metavar='Y', nargs='+',
                        help="YAML config files indicating location of each interface output")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())