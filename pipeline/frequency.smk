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
        sed -i '/^###/d' data/frequency/gene_annotation.gff3 2> {log}
        bgzip data/frequency/gene_annotation.gff3 &> {log}
        """

def get_covid_mask(wildcards):
    """
    Identify genome mask, based on config
    """
    url = "https://raw.githubusercontent.com/W-L/ProblematicSites_SARS-CoV2/master/problematic_sites_sarsCov2.vcf"
    path = "data/frequency/problematic_sites_sarsCov2.vcf"
    if not config['general']['check_online_updates'] and os.path.isfile(path):
        return path
    return HTTP.remote(url, keep_local=True)

rule download_mask:
    """
    Download SARS-CoV-2 sequence position mask (positions where sequencing is uncertain)
    """
    input:
        get_covid_mask

    output:
        "data/frequency/problematic_sites_sarsCov2.vcf"

    log:
        "logs/download_mask.log"

    shell:
        """
        mv {input} {output} &> {log}
        """

rule index_annotation:
    """
    Tabix index gff3 file
    """
    input:
        "data/frequency/gene_annotation.gff3.gz"

    output:
        "data/frequency/gene_annotation.gff3.gz.tbi"

    log:
        "logs/index_annotation.log"

    shell:
        "tabix -p gff {input}"

rule problematic_sites:
    """
    Identify problematic genome positions
    """
    input:
        "data/frequency/problematic_sites_sarsCov2.vcf"

    output:
        "data/frequency/filtered_sites.tsv"

    log:
        "logs/problematic_sites.log"

    shell:
        """
        python bin/filter_problematic_sites.py --filter seq_end ambiguous highly_ambiguous interspecific_contamination nanopore_adapter narrow_src single_src -- {input} > {output} 2> {log}
        """

rule variant_frequencies:
    """
    Calculate allele frequencies from VCF file
    """
    input:
        vcf="data/frequency/rob-12-6-20.unfiltered.pruned.vcf",
        sites="data/frequency/filtered_sites.tsv"

    output:
        "data/frequency/allele_freqs.tsv"

    log:
        "logs/variant_frequencies.log"

    shell:
        "vcftools --vcf {input.vcf} --exclude-positions {input.sites} --freq --stdout > {output} 2> {log}"

rule annotate_variants:
    """
    Annotate variants to proteins using Ensembl VEP
    """
    input:
        vcf='data/frequency/rob-12-6-20.unfiltered.pruned.vcf',
        gff='data/frequency/gene_annotation.gff3.gz',
        gfftbi='data/frequency/gene_annotation.gff3.gz.tbi',
        fasta='data/frequency/genome.fa',
        synonyms='data/frequency/synonyms.tsv'

    output:
        tsv="data/frequency/variant_annotation.tsv",
        stats="data/frequency/variant_annotation.tsv_summary.txt"

    log:
        "logs/annotate_variants.log"

    singularity:
        "docker://ensemblorg/ensembl-vep"

    shell:
        "vep --coding_only --species covid19  --tab --stats_text --synonyms {input.synonyms} --format vcf --fasta {input.fasta} --gff {input.gff} -i {input.vcf} -o {output.tsv} &> {log}"

rule frequency_tsv:
    """
    Generate tsv file of observed variant frequencies
    """
    input:
        vep="data/frequency/variant_annotation.tsv",
        freqs="data/frequency/allele_freqs.tsv",
        gff="data/frequency/gene_annotation.gff3.gz"

    output:
        "data/output/frequency.tsv"

    log:
        "logs/frequency_tsv.log"

    shell:
        "python bin/frequency_tsv.py {input.vep} {input.freqs} {input.gff} > {output} 2> {log}"