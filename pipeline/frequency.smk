"""
Rules for determining variant frequencies
"""
from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider
FTP = FTPRemoteProvider()

def get_covid_genome(wildcards):
    """
    Identify genome fasta source, based on config
    """
    url = "ftp.ensemblgenomes.org/pub/viruses/fasta/sars_cov_2/dna/Sars_cov_2.ASM985889v3.dna.toplevel.fa.gz"
    path = "data/frequency/genome.fa.gz"
    if not config['general']['check_online_updates'] and os.path.isfile(path):
        return path
    return FTP.remote(url, keep_local=True)

rule download_genome:
    """
    Download UniProt SARS-CoV2 genome fasta
    """
    input:
        get_covid_genome

    output:
        "data/frequency/genome.fa"

    log:
        "logs/download_genome.log"

    shell:
        """
        mv {input} data/frequency/genome.fa.gz &> {log}
        gunzip data/frequency/genome.fa.gz &> {log}
        """

def get_covid_annotation(wildcards):
    """
    Identify genome annotation source, based on config
    """
    url = "ftp.ensemblgenomes.org/pub/viruses/gff3/sars_cov_2/Sars_cov_2.ASM985889v3.100.gff3.gz"
    path = "data/frequency/gene_annotation.gff3.gz"
    if not config['general']['check_online_updates'] and os.path.isfile(path):
        return path
    return FTP.remote(url, keep_local=True)

rule download_annotation:
    """
    Download UniProt SARS-CoV2 genome gff3
    """
    input:
        get_covid_annotation

    output:
        "data/frequency/gene_annotation.gff3.gz"

    log:
        "logs/download_annotation.log"

    shell:
        """
        mv {input} data/frequency/gene_annotation.gff3.gz &> {log}
        gunzip data/frequency/gene_annotation.gff3.gz &> {log}
        bgzip data/frequency/gene_annotation.gff3 &> {log}
        """

rule: index_annotation:
    """
    Tabix index gff3 file
    """
    input:
        "data/frequency/gene_annotation.gff3.gz"
    
    output:
        "data/frequency/gene_annotation.gff3.gz.tbi

    log:
        "logs/index_annotation.log"

    shell:
        "tabix -p gff {input}"

rule annotate_variants:
    """
    Annotate variants to proteins using Ensembl VEP
    """
    input:
        vcf='data/frequency/rob-12-6-20.unfiltered.pruned.vcf',
        gff='data/frequency/gene_annotation.gff3.gz',
        fasta='data/frequency/genome.fa'

    output:
        "data/frequency/variant_annotation.tsv"

    log:
        "logs/annotate_variants.log"

    shell:
        "vep --fasta {input.fasta} --gff {input.gff} -i {input.vcf} -o {output} &> {log}"
