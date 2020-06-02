"""
Rules for managing structure downloads from SWISS-MODEL
"""
from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
HTTP = HTTPRemoteProvider()

# Mapping between genes and SWISS-MODEL project IDs
SWISSMODEL_IDS = {
    'P0DTD1_nsp1': 'YxJyvF', 'P0DTD1_nsp2': 'UrUkRp', 'P0DTD1_nsp3': '5hYU6g',
    'P0DTD1_nsp4': '0cKKrV', 'P0DTD1_nsp5': '4dt6Sh', 'P0DTD1_nsp6': '27R5bK',
    'P0DTD1_nsp7': 'GDvqSz', 'P0DTD1_nsp8': 'M4qFvm', 'P0DTD1_nsp9': 'GqQg8A',
    'P0DTD1_nsp10': '3xFkkB', 'P0DTD1_nsp12': 'JDUya4', 'P0DTD1_nsp13': 'N2NgU3',
    'P0DTD1_nsp14': '7BgWuu', 'P0DTD1_nsp15': 'H9prKX', 'P0DTD1_nsp16': 'X6zRCV',
    'P0DTC2_s': '7dVLxC', 'P0DTC3_orf3a': '1rtnjU', 'P0DTC4_e': '8Tdwfx',
    'P0DTC5_m': '9LzAZz', 'P0DTC6_orf6': 'NWaxq5', 'P0DTC7_orf7a': '5Bbtxw',
    'P0DTC8_orf8': 'FKMnGv', 'P0DTC9_nc': 'UfqxZJ', 'P0DTD2_orf9b': '1SagwD'
}

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
        'test/swissmodel/{id}.zip'

    log:
        'logs/swissmodel_download/{id}.log'

    shell:
        "mv {input} {output} &> {log}"

rule swissmodel_unzip:
    """
    Extract and format downloaded SWISS-MODEL report
    """
    input:
        'test/swissmodel/{id}.zip'

    output:
        directory('test/swissmodel/{id}')

    log:
        'logs/swissmodel_unzip/{id}.log'

    shell:
        """
        mkdir test/swissmodel/{wildcards.id} &> {log}
        bsdtar --cd test/swissmodel/{wildcards.id} --strip-components=1 -xvf test/swissmodel/P0DTD1_nsp1.zip &>> {log}
        rm -r test/swissmodel/{wildcards.id}/report.html test/swissmodel/{wildcards.id}/images test/swissmodel/{wildcards.id}/js &>> {log}
        mv test/swissmodel/{wildcards.id}/model/* test/swissmodel/{wildcards.id}/ &>> {log}
        rm -r test/swissmodel/{wildcards.id}/model &>> {log}
        """

checkpoint swissmodel_select:
    """
    Identify the best homology models to use for a protein
    """
    input:
        directory('test/swissmodel/{id}')

    output:
        'test/swissmodel/{id}.models'

    log:
        'logs/swissmodel_select/{id}.log'

    shell:
        'python bin/swissmodel_select.py {input} > {output} 2> {log}'
