"""
Miscalaneous rules
"""
from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider
FTP = FTPRemoteProvider()

def get_covid_genome(wildcards):
    """
    Identify genome fasta source, based on config
    """
    url = "ftp.uniprot.org/pub/databases/uniprot/pre_release/covid-19.fasta"
    path = "data/fasta/uniprot_sars_cov2_genome.fa"
    if not config['general']['check_online_updates'] and os.path.isfile(path):
        return path
    return HTTP.remote(url, keep_local=True)

rule download_fasta:
    """
    Download UniProt SARS-CoV2 genome fasta
    """
    input:
        get_covid_genome

    output:
        "data/fasta/uniprot_sars_cov2_genome.fa"

    log:
        "logs/download_fasta.log"

    shell:
        "mv {input} {output} &> {log}"

rule split_fasta:
    """
    Split the uniprot fasta down into gene fasta files
    """
    input:
        'data/fasta/uniprot_sars_cov2_genome.fa'

    output:
        [f'data/fasta/{g}.fa' for g in GENES]

    log:
        'logs/split_fasta.log'

    shell:
        'python bin/split_fasta.py -o data/fasta {input} &> {log}'

rule ptms_tsv:
    """
    Generate output table of PTM sites
    """
    input:
        config['ptms']['phosphorylation']

    output:
        'data/output/ptms.tsv'

    log:
        'logs/ptms_tsv.log'

    shell:
        'python bin/ptms_tsv.py --config snakemake.yaml > {output} 2> {log}'

rule summary_tsv:
    """
    Generate summary output table
    """
    input:
        sift="data/output/sift.tsv",
        foldx="data/output/foldx.tsv",
        ptm="data/output/ptms.tsv",
        complex="data/output/complex.tsv"

    output:
        "data/output/summary.tsv"

    log:
        "logs/summary_tsv.log"

    shell:
        "python bin/summary_tsv.py {input.sift} {input.foldx} {input.ptm} {input.complex} > {output} 2> {log}"