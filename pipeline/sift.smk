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
        db = config['sift']['uniref90_fa_path']

    output:
        "data/sift/{gene}.SIFTprediction"

    log:
        'logs/sift4g/{gene}.log'

    resources:
        mem_mb = 8000

    shell:
        "sift4g --subst data/sift/ -q {input.fa} -d {input.db} --out data/sift &> {log}"
