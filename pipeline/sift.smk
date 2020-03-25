rule sift4g:
    """
    Run SIFT4G on a FASTA file, assessing all possible variants.
    Note: I am using a modified version of SIFT4G that
    outputs to 4dp rather than 2.
    """
    input:
        fa = "data/fasta/{gene}.fa",
        db = config['sift']['uniref90_fa_path']

    output:
        "data/sift/{gene}.SIFTprediction"

    log:
        'logs/sift4g/{gene}.log'

    resources:
        mem_mb = 8000

    shell:
        "sift4g -q {input.fa} -d {input.db} --out data/sift 2> {log}"
