"""
Rules for managing structure downloads from SWISS-MODEL
"""
from limiting_http import RemoteProvider as RateLimitedHTTPRemoteProvider
from limiting_http import RemoteObject
RemoteObject.min_wait = 10
HTTP = RateLimitedHTTPRemoteProvider()

def get_swissmodel_file(wildcards):
    """
    Workout URL for each gene and return the correct remote file
    """
    url = f"swissmodel.expasy.org/interactive/{SWISSMODEL_IDS[wildcards.gene_id]}/models/report.zip"
    path = f'data/swissmodel/{wildcards.gene_id}.zip'
    if not config['general']['check_online_updates'] and os.path.isfile(path):
        return path
    return HTTP.remote(url, keep_local=True)

rule swissmodel_download:
    """
    Download project reports from SWISS-MODEL
    """
    input:
        get_swissmodel_file

    output:
        'data/swissmodel/{gene_id}.zip'

    log:
        'logs/swissmodel_download/{gene_id}.log'

    shell:
        "mv {input} {output} &> {log}"

rule swissmodel_unzip:
    """
    Extract and format downloaded SWISS-MODEL report
    """
    input:
        'data/swissmodel/{gene_id}.zip'

    output:
        directory('data/swissmodel/{gene_id}'),
        'data/swissmodel/{gene_id}/.unzipped'

    wildcard_constraints:
        gene_id="[A-Z0-9]*_[A-Za-z0-9]*"

    log:
        'logs/swissmodel_unzip/{gene_id}.log'

    shell:
        """
        unzip -d data/swissmodel/{wildcards.gene_id} {input} &>> {log}
        outdir=$(ls data/swissmodel/{wildcards.gene_id}) &>> {log}
        mv data/swissmodel/{wildcards.gene_id}/${{outdir}}/model/* data/swissmodel/{wildcards.gene_id}/ &>> {log}
        rm -r data/swissmodel/{wildcards.gene_id}/${{outdir}} &>> {log}
        touch data/swissmodel/{wildcards.gene_id}/.unzipped &>> {log}
        """

rule swissmodel_select:
    """
    Identify the best homology models to use for a protein
    """
    input:
        'data/swissmodel/{gene_id}/.unzipped'

    output:
        'data/swissmodel/{gene_id}.models'

    log:
        'logs/swissmodel_select/{gene_id}.log'

    shell:
        'python bin/swissmodel_select.py --seq_id {config[swissmodel][min_seq_id]} --qmean_z {config[swissmodel][min_qmean_z]} data/swissmodel/{wildcards.gene_id} > {output} 2> {log}'
