"""
Miscalaneous rules
"""

rule split_fasta:
    """
    Split the uniprot fasta down into gene fasta files
    """
    input:
        'data/uniprot/coronavirus.fasta'

    output:
        [f'data/fasta/{g}.fa' for g in GENES]

    shell:
        'python bin/split_fasta.py -o data/fasta data/uniprot/coronavirus.fasta'