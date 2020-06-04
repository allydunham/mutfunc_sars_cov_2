"""
Rules for generating FoldX ddG predictions
"""

rule foldx_repair:
    """
    Run FoldX RepairPDB command on PDB files
    """
    input:
        pdb="data/swissmodel/{gene}/{model}/model.pdb"

    output:
        "data/foldx/{gene}_{model}/model_Repair.pdb",
        "data/foldx/{gene}_{model}/model_Repair.fxout"

    resources:
        mem_mb = 4000

    log:
        "logs/foldx_repair/{gene}_{model}.log"

    shell:
        "foldx --command=RepairPDB --pdb=model.pdb --pdb-dir=data/swissmodel/{wildcards.gene}/{wildcards.model} --clean-mode=3 --output-dir=data/foldx/{wildcards.gene}_{wildcards.model} &> {log}"

rule foldx_variants:
    """
    Produce a list of all possible variants from a PDB structure, from positions that
    correspond to the regions defined in meta/structures.yaml as part of the analyses protein
    """
    input:
        pdb="data/swissmodel/{gene}/{model}/model.pdb",
        models="data/swissmodel/{gene}.models",

    output:
        muts="data/foldx/{gene}_{model}/individual_list"

    log:
        "logs/foldx_variants/{gene}_{model}.log"

    shell:
        "python bin/foldx_variants.py --models {input.models} {input.pdb} > {output.muts} 2> {log}"

checkpoint foldx_split:
    """
    Split variants lists into subsections to parralelise FoldX
    """
    input:
        "data/foldx/{structure}/individual_list"

    output:
        directory("data/foldx/{structure}/processing")

    params:
        n_lines = config['foldx']['variants_per_run']

    log:
        "logs/foldx_split/{structure}.log"

    shell:
        """
        mkdir data/foldx/{wildcards.structure}/processing &> {log}
        split -l {params.n_lines} data/foldx/{wildcards.structure}/individual_list data/foldx/{wildcards.structure}/processing/individual_list_ &> {log}
        """

rule foldx_model:
    """
    Run FoldX BuildModel on a PDB and a paired list of variants
    """
    input:
        pdb="data/foldx/{structure}/model_Repair.pdb",
        muts="data/foldx/{structure}/processing/individual_list_{n}"

    output:
        "data/foldx/{structure}/processing/Average_{n}_model_Repair.fxout",
        "data/foldx/{structure}/processing/Dif_{n}_model_Repair.fxout",
        "data/foldx/{structure}/processing/Raw_{n}_model_Repair.fxout",
        "data/foldx/{structure}/processing/PdbList_{n}_model_Repair.fxout"

    resources:
        mem_mb = 4000

    log:
        "logs/foldx_model/{structure}_{n}.log"

    shell:
        'foldx --command=BuildModel --pdb=model_Repair.pdb --pdb-dir=data/foldx/{wildcards.structure} --mutant-file={input.muts} --output-file="{wildcards.n}" --output-dir=data/foldx/{wildcards.structure}/processing --numberOfRuns=3 --clean-mode=3 --out-pdb=false &> {log}'

def get_foldx_split_files(wildcards):
    """
    Retrieve the IDs of split FoldX jobs
    """
    checkpoint_outdir = checkpoints.foldx_split.get(structure=wildcards.structure).output[0]
    fx_output = expand('data/foldx/{structure}/processing/{fi}_{n}_model_Repair.fxout',
                       structure=wildcards.structure,
                       n=glob_wildcards(os.path.join(checkpoint_outdir, "individual_list_{n}")).n,
                       fi=('Average', 'Dif', 'Raw'))
    in_lists = expand('data/foldx/{structure}/processing/individual_list_{n}',
                      structure=wildcards.structure,
                      n=glob_wildcards(os.path.join(checkpoint_outdir, "individual_list_{n}")).n)
    return fx_output + in_lists

rule foldx_combine:
    """
    Combined output of split FoldX model results for a structure
    """
    input:
        get_foldx_split_files

    output:
        "data/foldx/{structure}/average.fxout",
        "data/foldx/{structure}/dif.fxout",
        "data/foldx/{structure}/raw.fxout"

    log:
        "logs/foldx_combine/{structure}.log"

    shell:
        """
        python bin/foldx_combine.py --foldx data/foldx/{wildcards.structure}/processing/Average_*_model_Repair.fxout --variants data/foldx/{wildcards.structure}/processing/individual_list_* --type=average > data/foldx/{wildcards.structure}/average.fxout 2>> {log}

        python bin/foldx_combine.py --foldx data/foldx/{wildcards.structure}/processing/Dif_*_model_Repair.fxout --variants data/foldx/{wildcards.structure}/processing/individual_list_* --type=dif > data/foldx/{wildcards.structure}/dif.fxout 2>> {log}

        python bin/foldx_combine.py --foldx data/foldx/{wildcards.structure}/processing/Raw_*_model_Repair.fxout --variants data/foldx/{wildcards.structure}/processing/individual_list_* --type=raw > data/foldx/{wildcards.structure}/raw.fxout 2>> {log}
        """

def get_foldx_models(wildcards):
    """
    Identify output files from selected models for FoldX to process
    """
    models = []
    for gene in SWISSMODEL_IDS.keys():
        model_table = checkpoints.swissmodel_select.get(id=gene).output[0]
        mods = pd.read_csv(model_table, sep='\t', dtype={'model': str})

        if mods.model.empty:
            print(f'No good SWISS-MODEL models for {gene}', file=sys.stderr)
            continue

        for mod in mods.model:
            models.append(f'{gene}_{mod}')
    return [f'data/foldx/{i}/average.fxout' for i in models]

rule foldx_tsv:
    """
    Combine FoldX results from the selected models across all genes
    """
    input:
        get_foldx_models

    output:
        "data/output/foldx.tsv"

    log:
        "logs/foldx_tsv.log"

    shell:
        "python bin/foldx_tsv.py {input} > {output} 2> {log}"