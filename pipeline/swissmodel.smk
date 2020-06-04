"""
Rules for managing structure downloads from SWISS-MODEL
"""
from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
HTTP = HTTPRemoteProvider()

def get_swissmodel_file(wildcards):
    """
    Workout URL for each gene and return the correct remote file
    """
    url = f"swissmodel.expasy.org/interactive/{SWISSMODEL_IDS[wildcards.id]}/models/report.zip"
    return HTTP.remote(url, keep_local=True)

rule swissmodel_download:
    """
    Download project reports from SWISS-MODEL
    """
    input:
        get_swissmodel_file

    output:
        'data/swissmodel/{id}.zip'

    log:
        'logs/swissmodel_download/{id}.log'

    shell:
        "mv {input} {output} &> {log}"

rule swissmodel_unzip:
    """
    Extract and format downloaded SWISS-MODEL report
    """
    input:
        'data/swissmodel/{id}.zip'

    output:
        directory('data/swissmodel/{id}'),
        'data/swissmodel/{id}/.unzipped'

    log:
        'logs/swissmodel_unzip/{id}.log'

    shell:
        """
        bsdtar --cd data/swissmodel/{wildcards.id} --strip-components=1 -xvf {input} &>> {log}
        rm -r data/swissmodel/{wildcards.id}/report.html data/swissmodel/{wildcards.id}/images data/swissmodel/{wildcards.id}/js &>> {log}
        mv data/swissmodel/{wildcards.id}/model/* data/swissmodel/{wildcards.id}/ &>> {log}
        rm -r data/swissmodel/{wildcards.id}/model &>> {log}
        touch data/swissmodel/{wildcards.id}/.unzipped &>> {log}
        """

checkpoint swissmodel_select:
    """
    Identify the best homology models to use for a protein
    """
    input:
        'data/swissmodel/{id}/.unzipped'

    output:
        'data/swissmodel/{id}.models'

    log:
        'logs/swissmodel_select/{id}.log'

    shell:
        'python bin/swissmodel_select.py --seq_id {config[swissmodel][min_seq_id]} --coverage {config[swissmodel][min_coverage]} --qmean_z {config[swissmodel][min_qmean_z]} data/swissmodel/{wildcards.id} > {output} 2> {log}'
