"""
Rules for generating SIFT4G predictions
"""

# Genes SIFT fails on
SIFT_GENE_ERRORS = ['P0DTC1_nsp11', 'A0A663DJA2_orf10' ]

rule sift4g_download_database:
    """
    Download the NCBI coronaviridae dataset to make the SIFT4G database
    """
    output:
        "data/sift/database/coronaviridae.fa"

    log:
        "logs/sift4g_download_database.log"

    shell:
        """
        mkdir data/sift/database || echo "dir already exists" &> {log}
        cd data/sift/database &> {log}
        curl -X GET "https://api.ncbi.nlm.nih.gov/datasets/v1alpha/virus/taxon/11118/genome/download?exclude_sequence=true&include_annotation_type=PROT_FASTA" -H "Accept: application/zip, application/json" > coronaviridae.zip 2> {log}
        unzip coronaviridae.zip  &> {log}
        rm coronaviridae.zip README.md &> {log}
        mv ncbi_dataset/data/protein.faa coronaviridae.fa > {output}
        rm -r data/sift/ncbi_dataset &> {log}
        """

rule sift4g_cluster_database:
    """
    Generate the DB fasta file for SIFT4G using MMseqs2
    """
    input:
        fasta=ancient("data/sift/database/coronaviridae.fa")

    output:
        filtered_fasta="data/sift/database/coronaviridae_filtered.fa",
        db_dir=directory("data/sift/database/db"),
        clustered_fasta="data/sift/database/coronaviridae_clustered.fa"

    log:
        "logs/sift4g_cluster_database.log"

    threads: 8

    resources:
        mem_mb = 6000

    shell:
        """
        cd data/sift/database &> {log}
        python bin/filter_sift_db.py {input.fasta} > {output.filtered_fasta} 2> {log}
        mkdir {output.db_dir} &> {log}
        mmseqs createdb {output.filtered_fasta} {output.db_dir}/db &> {log}
        mkdir tmp &> {log}
        mmseqs cluster --min-seq-id 0.95 -c 0.8 --threads 8 {output.db_dir}/db {output.db_dir}/db_clu tmp &> {log}
        mmseqs createsubdb {output.db_dir}/db_clu {output.db_dir}/db {output.db_dir}/db_clu_rep &> {log}
        mmseqs convert2fasta {output.db_dir}/db_clu_rep coronaviridae_clustered.fa &> {log}
        """

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
        db = "data/sift/database/coronaviridae_clustered.fa"

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
