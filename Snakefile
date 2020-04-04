"""
Master pipeline for the COVID19 Mutfunc project
"""
import os
from pathlib import Path

configfile: 'snakemake.yaml'
localrules:
    all, split_fasta

# List of genes expected from the Uniprot FASTA (TODO: automate/make this better)
GENES = [
    'P0DTD1_nsp1', 'P0DTD1_nsp2', 'P0DTD1_nsp3',
    'P0DTD1_nsp4', 'P0DTD1_nsp5', 'P0DTD1_nsp6',
    'P0DTD1_nsp7', 'P0DTD1_nsp8', 'P0DTD1_nsp9',
    'P0DTD1_nsp10', 'P0DTD1_nsp12', 'P0DTD1_nsp13',
    'P0DTD1_nsp14', 'P0DTD1_nsp15', 'P0DTD1_nsp16',
    'P0DTC1_nsp11', 'P0DTC2_s', 'P0DTC3_orf3a',
    'P0DTC4_e', 'P0DTC5_m', 'P0DTC6_orf6',
    'P0DTC7_orf7a', 'P0DTD8_orf7b', 'P0DTC8_orf8',
    'P0DTC9_nc', 'A0A663DJA2_orf10', 'P0DTD2_orf9b',
    'P0DTD3_orf14'
]

# List of all structures present
STRUCTURES = {Path(i).stem for i in os.listdir('data/pdb')}

# Sift genes
SIFT_GENES = ['P0DTD1_nsp1', 'P0DTD1_nsp2', 'P0DTD1_nsp3',
        'P0DTD1_nsp4', 'P0DTD1_nsp5', 'P0DTD1_nsp6',
        'P0DTD1_nsp7', 'P0DTD1_nsp8', 'P0DTD1_nsp9',
        'P0DTD1_nsp10', 'P0DTD1_nsp12', 'P0DTD1_nsp13',
        'P0DTD1_nsp14', 'P0DTD1_nsp15', 'P0DTD1_nsp16',
        'P0DTC2_s', 'P0DTC3_orf3a', 'P0DTC4_e',
        'P0DTC5_m', 'P0DTC6_orf6', 'P0DTC7_orf7a',
        'P0DTD8_orf7b', 'P0DTC8_orf8', 'P0DTC9_nc',
        'P0DTD2_orf9b', 'P0DTD3_orf14'
]

include: 'pipeline/misc.smk'
include: 'pipeline/sift.smk'
include: 'pipeline/foldx.smk'

rule all:
    """
    Full pipeline
    """
    input:
        [f'data/sift/{g}.SIFTprediction' for g in SIFT_GENES],
        [f'data/foldx/{s}/average_{s}.fxout' for s in STRUCTURES]

rule setup_directories:
    """
    Setup initial project directory structure for all generated files. Assumes bin, src & docs
    exist. Plus many of the others will often already exist for various reasons, but this rule
    ensures everything is setup correctly
    """
    run:
        # data
        shell('mkdir data && echo "mkdir data" || true')
        dirs = ['foldx', 'pdb', 'sift', 'fasta']
        dirs.extend(f'foldx/{s}' for s in STRUCTURES)

        for d in dirs:
            shell(f'mkdir data/{d} && echo "mkdir data/{d}" || true')

        # logs
        shell('mkdir logs && echo "mkdir logs" || true')
        dirs = ['foldx_combine', 'foldx_model', 'foldx_repair',
                'foldx_split', 'foldx_variants', 'sift4g', 'sift4g_variants']

        for d in dirs:
            shell(f'mkdir logs/{d} && echo "mkdir logs/{d}" || true')
