#!/usr/bin/env python3
"""
Combine data from all analyses into a summary table. Input tables are those output
by the other sections of the pipeline
"""
from sys import stdout
import argparse
import pandas as pd

COVID_UNIPROT = ['P0DTD1', 'P0DTC1', 'P0DTC2', 'P0DTC3', 'P0DTC4', 'P0DTC5',
                 'P0DTC6', 'P0DTC7', 'P0DTD8', 'P0DTC8', 'P0DTC9', 'A0A663DJA2',
                 'P0DTD2', 'P0DTD3']

def main(args):
    """
    Main
    """
    # Import tables
    sift = pd.read_csv(args.sift, sep='\t', index_col=False)
    sift = sift[['uniprot', 'name', 'position', 'wt', 'mut', 'sift_score']]

    foldx = pd.read_csv(args.foldx, sep='\t', index_col=False, dtype={'model': str})
    foldx = foldx[['uniprot', 'name', 'position', 'wt', 'mut', 'total_energy']]

    ptms = pd.read_csv(args.ptms, sep='\t', index_col=False)
    ptms = ptms[['uniprot', 'name', 'position', 'wt', 'ptm']]

    complexes = pd.read_csv(args.complex, sep='\t', index_col=False)
    complexes = complexes[['uniprot', 'name', 'position', 'wt', 'mut', 'int_uniprot',
                           'int_name', 'interaction_energy', 'diff_interaction_energy',
                           'diff_interface_residues']]

    # Merge
    base_cols = ['uniprot', 'name', 'position', 'wt']
    summary = sift.merge(foldx, how='outer', on=base_cols + ['mut'])
    summary = summary.merge(ptms, how='outer', on=base_cols)
    summary = summary.merge(complexes, how='outer', on=base_cols + ['mut'])
    summary = summary.loc[summary.uniprot.isin(COVID_UNIPROT)]
    summary = summary.sort_values(by=['uniprot', 'name', 'position', 'mut'],
                                  axis='index', ignore_index=True)

    summary.to_csv(stdout, sep='\t', index=False, float_format='%.7g')

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('sift', metavar='S', help="SIFT4G output table")
    parser.add_argument('foldx', metavar='F', help="FoldX output table")
    parser.add_argument('ptms', metavar='P', help="PTM output table")
    parser.add_argument('complex', metavar='C', help="Complexes output table")

    # args = parser.parse_args(["data/output/sift.tsv", "data/output/foldx.tsv", "data/output/ptms.tsv", "data/output/complex.tsv"])
    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())