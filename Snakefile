"""
Master pipeline for the COVID19 Mutfunc project
"""

# TODO finish

configfile: 'snakemake.yaml'
localrules:
    all, split_fasta

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

include: 'pipeline/misc.smk'
include: 'pipeline/sift.smk'
include: 'pipeline/foldx.smk'

rule all:
    """
    Full pipeline
    """
    input:
        [f'data/sift/{g}.SIFTprediction' for g in GENES]