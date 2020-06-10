"""
Miscalaneous rules
"""
from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider
FTP = FTPRemoteProvider()

rule download_fasta:
    """
    Download UniProt SARS-CoV2 genome fasta
    """
    input:
        FTP.remote("ftp.uniprot.org/pub/databases/uniprot/pre_release/covid-19.fasta",
                   keep_local=True)

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
        'python bin/ptms_tsv.py --config snakemake.yaml'