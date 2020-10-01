"""
Plot colours onto PDB structures using PyMol
"""
from itertools import cycle
import pandas as pd
from colour_spectrum import ColourSpectrum

def import_data():
    """
    Utility function to imoprt summary tsv ready for usage in PyMol
    """
    col_types = {
        'sift_score': float, 'sift_median': float, 'total_energy': float,
        'interaction_energy': float, 'diff_interaction_energy': float,
        'diff_interface_residues': float, 'freq': float
    }
    return pd.read_csv('data/output/summary.tsv', sep='\t', index_col=False,
                       dtype=col_types, low_memory=False)

def project_freq(cmd, df, name, chain):
    """
    Project total frequency of mutations on a protein
    """
    df = df[(df.name == name) & ~df.freq.isna() & ~df.diff_interaction_energy.isna()]
    df = df.groupby(['name', 'position', 'wt']).agg({'freq': 'sum'}).reset_index()
    project_landscape(cmd, chain, df.position, df.freq,
                     ColourSpectrum(0, max(df.freq), colourmap='Reds'))

def project_ddg(cmd, df, name, chain, all_positions=False):
    """
    Project total frequency of mutations on a protein
    """
    df = df[(df.name == name) & ~df.diff_interaction_energy.isna()]
    if not all_positions:
        df = df[~df.freq.isna()]

    df = df.groupby(['name', 'position', 'wt']) \
           .agg({'diff_interaction_energy': 'mean'}) \
           .reset_index()

    top = max(abs(df.diff_interaction_energy))
    project_landscape(cmd, chain, df.position, df.diff_interaction_energy,
                      ColourSpectrum(-top, top, midpoint=0, colourmap='seismic'))

def project_landscape(cmd, chain, position, value, colourer=None, na_colour=None):
    """
    Colour specific residues according to a colourmap. colourer must return a Hexcode
    when called with a value as well as have an 'na_colour' attribute if no na_colour
    is specifically supplied. Chain can either be a single identifier (str) or an
    iterable of identifiers
    """
    if colourer is None:
        colourer = ColourSpectrum(min(value), max(value), colourmap='viridis')

    if isinstance(chain, str):
        chain = cycle([chain])

    colour_residues(cmd, *zip(chain, position, [colourer(val) for val in value]),
                    base_colour=na_colour)

def colour_residues(cmd, *args, base_colour=None):
    """
    Colour multiple residues programatically. Each argument should be a
    (chain, position index, hex code) tuple
    """
    if base_colour is not None:
        cmd.color(base_colour, 'polymer')

    for chn, pos, col in args:
        pos = int(pos)
        pos = f'\{pos}' if pos < 0 else pos # Negative indices must be escaped
        cmd.color(col, f'polymer and chain {chn} and resi {pos}')
