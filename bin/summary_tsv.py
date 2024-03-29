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
    ## Import tables
    # Sift
    sift = pd.read_csv(args.sift, sep='\t', index_col=False)
    sift = sift[['uniprot', 'name', 'position', 'wt', 'mut', 'sift_score', 'sift_median']]

    # FoldX
    foldx = pd.read_csv(args.foldx, sep='\t', index_col=False, dtype={'model': str})
    foldx['template'] = foldx['template'].str.cat(foldx['chain'], sep='.')
    foldx = foldx[['uniprot', 'name', 'position', 'mut', 'template', 'total_energy']]
    foldx = foldx.rename(columns={'total_energy': 'foldx_ddg'})

    # PTMs
    ptms = pd.read_csv(args.ptms, sep='\t', index_col=False)
    ptms = ptms[['uniprot', 'name', 'position', 'ptm']]

    # Complex
    complexes = pd.read_csv(args.complex, sep='\t', index_col=False)
    complexes['int_template'] = complexes['model'].str.extract('^([0-9a-zA-Z]{4})\.[0-9]*$',
                                                               expand=False)
    complexes['int_template'] = complexes['int_template'].str.cat([complexes['chain'],
                                                                   complexes['int_chain']],
                                                                  sep='.')
    complexes = complexes[['uniprot', 'name', 'position', 'mut', 'int_uniprot',
                           'int_name', 'int_template', 'interaction_energy',
                           'diff_interaction_energy', 'diff_interface_residues']]

    # Frequency
    frequency = pd.read_csv(args.frequency, sep='\t', index_col=False)
    frequency = frequency[['uniprot', 'name', 'position', 'wt', 'mut', 'overall']]
    frequency = frequency.rename(columns={'overall': 'freq'})

    # Surface Accessibility
    accessibility = pd.read_csv(args.accessibility, sep='\t', index_col=False)
    accessibility = accessibility[['uniprot', 'name', 'position', 'wt', 'all_atoms_rel']]
    sa_rename = {'all_atoms_rel': 'relative_surface_accessibility'}
    accessibility = accessibility.rename(columns=sa_rename)

    # Antibody Escape Experiment
    antibody = pd.read_csv(args.antibody, sep=',', index_col=False)
    antibody = antibody.rename(columns={'site': 'position', 'wildtype': 'wt', 'mutation': 'mut'})
    antibody = antibody.groupby(['position', 'wt', 'mut'], as_index=False)
    antibody = antibody.agg({'mut_escape': ['mean', 'max']})
    antibody.columns = ['_'.join(i).rstrip('_') for i in antibody.columns.to_flat_index()]
    antibody['name'] = 's'
    antibody['uniprot'] = 'P0DTC2'

    # Annotation
    groups = ['uniprot', 'name', 'position', 'wt', 'mut']
    annotation = pd.read_csv(args.annotation, sep='\t', index_col=False,
                             comment='#', skip_blank_lines=True)
    annotation = annotation.groupby(groups)['annotation'].apply(';'.join).reset_index()

    ## Merge table
    base_cols = ['uniprot', 'name', 'position']
    summary = sift.merge(foldx, how='outer', on=base_cols + ['mut'])
    summary = summary.merge(ptms, how='outer', on=base_cols)
    summary = summary.merge(complexes, how='outer', on=base_cols + ['mut'])
    summary = summary.merge(frequency, how='outer', on=base_cols + ['wt', 'mut'])
    summary = summary.merge(accessibility, how='outer', on=base_cols + ['wt'])
    summary = summary.merge(antibody, how='outer', on=base_cols + ['wt', 'mut'])
    summary = summary.merge(annotation, how='outer', on=base_cols + ['wt', 'mut'])
    summary = summary.loc[summary.uniprot.isin(COVID_UNIPROT)]
    summary = summary.sort_values(by=['uniprot', 'name', 'position', 'mut'],
                                  axis='index', ignore_index=True)
    summary = summary.dropna(axis='index', subset=['wt'])
    summary = summary[['uniprot', 'name', 'position', 'wt', 'mut', 'freq', 'ptm',
                       'sift_score', 'sift_median',
                       'template', 'relative_surface_accessibility', 'foldx_ddg',
                       'int_uniprot', 'int_name', 'int_template', 'interaction_energy', 'diff_interaction_energy', 'diff_interface_residues',
                       'mut_escape_mean', 'mut_escape_max',
                       'annotation']]

    summary.to_csv(stdout, sep='\t', index=False, float_format='%.7g')

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('sift', metavar='S', help="SIFT4G output table")
    parser.add_argument('foldx', metavar='F', help="FoldX output table")
    parser.add_argument('ptms', metavar='P', help="PTM output table")
    parser.add_argument('complex', metavar='C', help="Complexes output table")
    parser.add_argument('frequency', metavar='R', help="Frequency output table")
    parser.add_argument('accessibility', metavar='A', help="Surface Accessibility output table")
    parser.add_argument('antibody', metavar='N', help="Antibody DMS supplementary table")
    parser.add_argument('annotation', metavar='O', help="Annotation table")

    # args = parser.parse_args(["data/output/sift.tsv", "data/output/foldx.tsv", "data/output/ptms.tsv", "data/output/complex.tsv", "data/output/frequency.tsv", "data/output/surface_accessibility.tsv", "data/greaney_spike_antibody.csv", "docs/annotation.tsv"])
    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())