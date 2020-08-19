"""
Rules for generating SIFT4G predictions
"""

# Genes SIFT fails on
SIFT_GENE_ERRORS = ['P0DTC1_nsp11', 'A0A663DJA2_orf10' ]

rule sift4g_variants:
    """
    Generate variants list for SIFT4G
    """
    input:
        fa = "data/fasta/{gene}.fa"

    output:
        "data/sift/{gene}.subst"

    log:
        "logs/sift4g_variants/{gene}.log"

    shell:
        "python bin/sift_variants.py {input.fa} > {output} 2> {log}"

# TODO can easily multi-thread sift here if needed
rule sift4g:
    """
    Run SIFT4G on a FASTA file, assessing all possible variants.
    Note: I am using a modified version of SIFT4G that
    outputs to 4dp rather than 2.
    """
    input:
        fa = "data/fasta/{gene}.fa",
        subst = "data/sift/{gene}.subst",
        db = config['sift']['db_path']

    output:
        "data/sift/{gene}.SIFTprediction",
        "data/sift/{gene}.aligned.fasta"

    log:
        'logs/sift4g/{gene}.log'

    resources:
        mem_mb = 8000

    shell:
        "sift4g --sub-results --subst data/sift/ -q {input.fa} -d {input.db} --out data/sift &> {log}"

rule sift_tsv:
    """
    Combine data from SIFT4G into a single table
    """
    input:
        [f"data/sift/{gene}.SIFTprediction" for gene in GENES if not gene in SIFT_GENE_ERRORS]

    output:
        "data/output/sift.tsv"

    log:
        "logs/sift_tsv.log"

    shell:
        "python bin/sift_tsv.py {input} > {output} 2> {log}"
