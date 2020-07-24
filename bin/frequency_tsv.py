#!/usr/bin/env python3
"""
Exctract variant frequencies from VCF and map based on GFF file
"""
import argparse
import bisect
import gzip

UNIPROT_IDS = {
    'orf1ab': 'P0DTD1', 'orf1a': 'P0DTC1', 's': 'P0DTC2',
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

# Subunits of the orf1ab polyprotein and their start positions
# Start positions are also used as the required offset (+1) of the next protein along
ORF1AB_SUBUNITS = ['nsp1', 'nsp2', 'nsp3', 'nsp4', 'nsp5', 'nsp6', 'nsp7', 'nsp8',
                   'nsp9', 'nsp10', 'nsp12', 'nsp13', 'nsp14', 'nsp15', 'nsp16']
ORF1AB_POSITIONS = [1, 181, 819, 2764, 3264, 3570, 3860, 3943, 4141, 4254, 4393,
                    5325, 5926, 6453, 6799]
def get_orf1ab_gene(position):
    """
    Get nsp protein from position in ORF1AB, returning the name and the start
    """
    pos = bisect.bisect(ORF1AB_POSITIONS, position)
    return ORF1AB_SUBUNITS[pos - 1], ORF1AB_POSITIONS[pos - 1] - 1

def import_gene_map(gff_file):
    """
    Import gene and transcript map between names and ensembl identifiers
    """
    transcript_map = {}
    gene_map = {}
    for line in gff_file:
        if line[0] == '#':
            continue
        line = line.strip().split('\t')
        attributes = dict([i.split('=') for i in line[8].split(';')])
        if line[2] == 'gene':
            gene_map[attributes['gene_id']] = attributes['Name'].lower()
        elif line[2] == 'mRNA':
            transcript_map[attributes['transcript_id']] = attributes['Name'].lower()
    return gene_map, transcript_map

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

def calculate_protein_freqs(vep_file, allele_freqs, transcript_map):
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

        gene = transcript_map[line[4]]
        gene = 'nc' if gene == 'n' else gene # Mutfunc uses nc internally
        uniprot = UNIPROT_IDS[gene]
        dna_position = line[0].split(',')[0][1:-1]
        freq = allele_freqs[f'{dna_position}{line[2]}']
        position = int(line[9])
        wt, mut = line[10].split('/')

        # Have to correct for polyprotein
        if gene == 'orf1ab':
            gene, offset = get_orf1ab_gene(position)
            position = position - offset

        # Only care about NSP11 from orf1a as the rest are the same
        elif gene == 'orf1a':
            if position >= NSP11_POSITION[0] and position <= NSP11_POSITION[1]:
                gene = 'nsp11'
                position = position - NSP11_POSITION[0]
            else:
                continue

        key = f'{gene}_{position}_{mut}'

        if key in prot_freqs:
            prot_freqs[key]['freq'] += freq
        else:
            prot_freqs[key] = {'uniprot': uniprot, 'name': gene,
                               'position': position, 'wt': wt,
                               'mut': mut, 'freq': freq}

    return prot_freqs

def make_prot_freq_sort_key(x):
    """
    Generate a sort value for sorting the output of protein
    """
    gene, position, mut = x.split('_')
    return 1000000 * GENE_SORT_ORDER[gene] + 100 * int(position) + (ord(mut) - 65)

def print_freq_tsv(prot_freqs):
    """
    Print tsv giving frequency of each protein substitution, including sorting
    frequencies correctly
    """
    sorted_keys = sorted(list(prot_freqs.keys()), key=make_prot_freq_sort_key)
    print('uniprot', 'name', 'position', 'wt', 'mut', 'freq', sep='\t')
    for k in sorted_keys:
        i = prot_freqs[k]
        print(i['uniprot'], i['name'], i['position'],
              i['wt'], i['mut'], i['freq'], sep='\t')

def main(args):
    """Main"""
    # Import ensembl to common name dict
    with gzip.open(args.annotation, 'rt') as gff_file:
        gene_map, transcript_map = import_gene_map(gff_file)

    # Import Allele freqs
    with open(args.freqs, 'r') as freqs_file:
        allele_freqs = import_allele_freqs(freqs_file)

    # Calculate (known) protein substitution freqs
    with open(args.vep, 'r') as vep_file:
        prot_freqs = calculate_protein_freqs(vep_file, allele_freqs, transcript_map)

    # Print Output Table
    print_freq_tsv(prot_freqs)

def parse_args():
    """Parse arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('vep', metavar='V', help='VEP Predictions')
    parser.add_argument('freqs', metavar='F', help='Allele frequencies')
    parser.add_argument('annotation', metavar='A', help='GFF Annotation file')

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())