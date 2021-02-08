"""
Master pipeline for the COVID19 Mutfunc project
"""
import os
import sys
import pandas as pd
from pathlib import Path
from ruamel.yaml import YAML

from limiting_http import RemoteProvider as RateLimitedHTTPRemoteProvider
from limiting_http import RemoteObject
RemoteObject.min_wait = 10
HTTP = RateLimitedHTTPRemoteProvider()

configfile: 'snakemake.yaml'
localrules:
    all, download_protein_fasta, swissmodel_download, complex_download,
    download_genome, frequency_tsv,
    ptms_tsv, foldx_tsv, sift_tsv, complex_tsv, summary_tsv,
    split_fasta, sift4g_variants,
    swissmodel_unzip, swissmodel_select,
    foldx_variants, foldx_split, foldx_combine,
    complex_variants, complex_combine,
    sample_subsets

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

# Mapping between genes and SWISS-MODEL project IDs
SWISSMODEL_IDS = {
    'P0DTD1_nsp1': 'YxJyvF', 'P0DTD1_nsp2': 'UrUkRp', 'P0DTD1_nsp3': '5hYU6g',
    'P0DTD1_nsp4': '0cKKrV', 'P0DTD1_nsp5': '4dt6Sh', 'P0DTD1_nsp6': '27R5bK',
    'P0DTD1_nsp7': 'GDvqSz', 'P0DTD1_nsp8': 'M4qFvm', 'P0DTD1_nsp9': 'GqQg8A',
    'P0DTD1_nsp10': '3xFkkB', 'P0DTD1_nsp12': 'JDUya4', 'P0DTD1_nsp13': 'N2NgU3',
    'P0DTD1_nsp14': '7BgWuu', 'P0DTD1_nsp15': 'H9prKX', 'P0DTD1_nsp16': 'X6zRCV',
    'P0DTC2_s': '7dVLxC', 'P0DTC3_orf3a': '1rtnjU', 'P0DTC4_e': '8Tdwfx',
    'P0DTC6_orf6': 'NWaxq5', 'P0DTC5_m': '9LzAZz', 'P0DTC7_orf7a': '5Bbtxw',
    'P0DTC8_orf8': 'FKMnGv', 'P0DTC9_nc': 'UfqxZJ', 'P0DTD2_orf9b': '1SagwD'
}

include: 'pipeline/misc.smk'
include: 'pipeline/swissmodel.smk'
include: 'pipeline/sift.smk'
include: 'pipeline/foldx.smk'
include: 'pipeline/complex.smk'
include: 'pipeline/frequency.smk'

rule all:
    """
    Full pipeline
    """
    input:
        "data/output/sift.tsv",
        "data/output/foldx.tsv",
        "data/output/ptms.tsv",
        "data/output/complex.tsv",
        "data/output/frequency.tsv",
        "data/output/naccess.tsv",
        "data/output/summary.tsv"

rule swissmodel_downloads:
    """
    Download all models
    """
    input:
        [f'data/swissmodel/{i}.zip' for i in SWISSMODEL_IDS.keys()]

rule setup_directories:
    """
    Setup initial project directory structure for all generated files. Assumes bin, src & docs
    exist. Plus many of the others will often already exist for various reasons, but this rule
    ensures everything is setup correctly
    """
    run:
        # data
        shell('mkdir data && echo "mkdir data" || true')
        dirs = ['foldx', 'sift', 'fasta', 'swissmodel', 'output', 'complex']

        for d in dirs:
            shell(f'mkdir data/{d} && echo "mkdir data/{d}" || true')

        # logs
        shell('mkdir logs && echo "mkdir logs" || true')
        dirs = ['foldx_combine', 'foldx_model', 'foldx_repair',
                'foldx_split', 'foldx_variants', 'sift4g', 'sift4g_variants',
                'swissmodel_download', 'swissmodel_unzip', 'swissmodel_select',
                ]

        for d in dirs:
            shell(f'mkdir logs/{d} && echo "mkdir logs/{d}" || true')

        # Frontend
        dirs = ['public/data/pdb_foldx',
                'public/data/pdb_interface',
                'public/data/sift_alignments']
        for d in dirs:
            shell(f'mkdir frontend/{d} && echo "mkdir frontend/{d}" || true')

rule copy_to_frontend:
    """
    Copy output data to web frontend public folder.
    WARNING: This rule doesn't check file requirements, use the normal pipeline to
    generate all files first.
    """
    log:
        'logs/copy_to_frontend.log'

    run:
        target = config['general']['frontend_dir']
        shell(f"cp data/output/summary.tsv {target}/public/data/summary.tsv &> {log}")

        shell(f"rm -f {target}/public/data/sift_alignments/* &> {log}")
        for gene in GENES:
            if not gene in SIFT_GENE_ERRORS:
                shell(f"python bin/format_sift_alignment.py --query '{gene.split('_')[1]}' data/sift/{gene}.aligned.fasta > {target}/public/data/sift_alignments/{gene}.json 2> {log}")

        shell(f"rm -rf {target}/public/data/pdb_foldx/* &> {log}")
        shell(f"rm -rf {target}/public/data/pdb_interface/* &> {log}")
        shell(f"python bin/copy_models.py swissmodel {target}/public/data/pdb_foldx &> {log}")
        shell(f"python bin/copy_models.py complex {target}/public/data/pdb_interface &> {log}")

