#!/usr/bin/env python3
"""
Exctract variant frequencies from VCF and map based on GFF file
"""
import argparse
import bisect
from pathlib import Path

UNIPROT_IDS = {
    'orf1ab': 'P0DTD1', 'orf1a': 'P0DTC1',
    'nsp1': 'P0DTD1', 'nsp2': 'P0DTD1', 'nsp3': 'P0DTD1',
    'nsp4': 'P0DTD1', 'nsp5': 'P0DTD1', 'nsp6': 'P0DTD1',
    'nsp7': 'P0DTD1', 'nsp8': 'P0DTD1', 'nsp9': 'P0DTD1',
    'nsp10': 'P0DTD1', 'nsp11': 'P0DTC1', 'nsp12': 'P0DTD1',
    'nsp13': 'P0DTD1', 'nsp14': 'P0DTD1', 'nsp15': 'P0DTD1',
    'nsp16': 'P0DTD1', 's': 'P0DTC2',
    'orf3a': 'P0DTC3', 'e': 'P0DTC4', 'm': 'P0DTC5',
    'orf6': 'P0DTC6', 'orf7a': 'P0DTC7', 'orf7b': 'P0DTD8',
    'orf8': 'P0DTC8', 'nc': 'P0DTC9', 'orf10': 'A0A663DJA2',
    'orf9b': 'P0DTD2', 'orf14': 'P0DTD3'
}

# Sort genes in genome position order
GENE_SORT_ORDER = ['nsp1', 'nsp2', 'nsp3','nsp4', 'nsp5',
                   'nsp6','nsp7', 'nsp8', 'nsp9', 'nsp10',
                   'nsp11', 'nsp12', 'nsp13', 'nsp14',
                   'nsp15', 'nsp16', 's', 'orf3a', 'e',
                   'm', 'orf6','orf7a', 'orf7b', 'orf8',
                   'nc', 'orf10', 'orf9b','orf14']
GENE_SORT_ORDER = {v: i for i, v in enumerate(GENE_SORT_ORDER)}

NSP11_POSITION = (4393, 4405)

def import_allele_freqs(freqs_file):
    """
    Import allele frequencies from a file
    """
    freqs = {}
    next(freqs_file) # Don't care about headers
    for line in freqs_file:
        line = line.strip().split('\t')
        for freq in line[4:]:
            freq = freq.split(':')
            freqs[f'{line[1]}{freq[0]}'] = float(freq[1])
    return(freqs)

def calculate_protein_freqs(vep_file, allele_freqs):
    """
    Calculate protein substitution changes from VEP annotation
    """
    # Store freqs as prot_pos_mut:
    # {uniprot: , name: , position: , wt: , mut: , freq: }
    prot_freqs = {}
    for line in vep_file:
        if line[0] == '#':
            continue

        line = line.strip().split('\t')

        # Only care about missense variants with known substitutions
        if not line[6] == 'missense_variant':
            continue

        gene = line[4]
        dna_position = line[0].split(',')[0][1:-1]
        dna_key = f'{dna_position}{line[2]}'
        position = int(line[9])
        wt, mut = line[10].split('/')

        # Have to correct for frameshift in Nsp12
        if gene == 'nsp12_1':
            gene = 'nsp12'
        elif gene == 'nsp12_2':
            gene = 'nsp12'
            position += 9

        uniprot = UNIPROT_IDS[gene]
        key = f'{gene}_{position}_{mut}'

        if not key in prot_freqs:
            prot_freqs[key] = {'uniprot': uniprot, 'name': gene,
                               'position': position, 'wt': wt,
                               'mut': mut, **{n: 0 for n in allele_freqs.keys()}}

        for freq_name in allele_freqs.keys():
            prot_freqs[key][freq_name] += allele_freqs[freq_name][dna_key]

    return prot_freqs

def make_prot_freq_sort_key(x):
    """
    Generate a sort value for sorting the output of protein
    """
    gene, position, mut = x.split('_')
    return 1000000 * GENE_SORT_ORDER[gene] + 100 * int(position) + (ord(mut) - 65)

def print_freq_tsv(prot_freqs, freq_cols):
    """
    Print tsv giving frequency of each protein substitution, including sorting
    frequencies correctly
    """
    sorted_keys = sorted(list(prot_freqs.keys()), key=make_prot_freq_sort_key)
    print('uniprot', 'name', 'position', 'wt', 'mut', *freq_cols, sep='\t')
    for k in sorted_keys:
        i = prot_freqs[k]
        print(i['uniprot'], i['name'], i['position'],
              i['wt'], i['mut'], *[i[k] for k in freq_cols], sep='\t')

def main(args):
    """Main"""
    # Import Allele freqs
    allele_freqs = {}
    for freq_path in args.freqs:
        name = Path(freq_path).stem
        with open(freq_path, 'r') as freq_file:
            allele_freqs[name] = import_allele_freqs(freq_file)

    # Calculate (known) protein substitution freqs
    with open(args.vep, 'r') as vep_file:
        prot_freqs = calculate_protein_freqs(vep_file, allele_freqs)

    # Print Output Table
    print_freq_tsv(prot_freqs, freq_cols=[Path(x).stem for x in args.freqs])

def parse_args():
    """Parse arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('vep', metavar='V', help='VEP Predictions')
    parser.add_argument('freqs', metavar='F', nargs='+', help='Allele frequency files')

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())