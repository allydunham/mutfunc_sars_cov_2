"""
Rules to analyse interface interactions using FoldX's AnalyseComplex command
"""
from snakemake.exceptions import MissingInputException

COMPLEXES = ['nsp9_nsp9', 'nsp7_nsp8', 'nsp7_nsp8_pol', 'nsp10_nsp14',
             'nsp10_nsp16', 'ace2_spike', 'nsp1_40s', 's_s', 'nc_nc',
             'orf3a_orf3a', 'orf9b_orf9b']

# TODO add possibility of protocols other than https
def get_complex_file(wildcards):
    """
    Workout URL for each gene and return the correct remote file
    """
    yaml = YAML(typ='safe')
    pdb_conf = yaml.load(Path(f'data/complex/{wildcards.complex}/model.yaml'))
    path = f'data/complex/{wildcards.complex}/model.pdb'
    if pdb_conf['url'] is None:
        return path
    url = pdb_conf['url'].replace('https://', '')
    if not config['general']['check_online_updates'] and os.path.isfile(path):
        return path
    return HTTP.remote(url, keep_local=True)

rule complex_download:
    """
    Download a complex PDB file
    """
    input:
        get_complex_file

    output:
        'data/complex/{complex}/model.pdb'

    log:
        'logs/complex_download/{complex}.log'

    shell:
        "mv {input} {output} &> {log}"

rule complex_repair:
    """
    Repair complex PDB file to use with FoldX
    """
    input:
        'data/complex/{complex}/model.pdb'

    output:
        'data/complex/{complex}/model_Repair.pdb',
        'data/complex/{complex}/model_Repair.fxout'

    resources:
        mem_mb = 8000

    log:
        "logs/complex_repair/{complex}.log"

    shell:
        "foldx --command=RepairPDB --pdb=model.pdb --pdb-dir=data/complex/{wildcards.complex} --clean-mode=3 --output-dir=data/complex/{wildcards.complex} &> {log}"

rule complex_wt_analysis:
    """
    Analyse a WT complex interface to identify interface residues
    """
    input:
        pdb='data/complex/{complex}/model_Repair.pdb'

    output:
        'data/complex/{complex}/{interface}/wt/Indiv_energies_model_Repair_AC.fxout',
        'data/complex/{complex}/{interface}/wt/Interaction_model_Repair_AC.fxout',
        'data/complex/{complex}/{interface}/wt/Interface_Residues_model_Repair_AC.fxout',
        'data/complex/{complex}/{interface}/wt/Summary_model_Repair_AC.fxout'

    resources:
        mem_mb = 8000

    log:
        'logs/complex_wt_analysis/{complex}_{interface}.log'

    run:
        root = f'data/complex/{wildcards.complex}/{wildcards.interface}'
        shell(f'mkdir {root} &> {log} && echo "mkdir {root}" &> {log} || true')
        shell(f'mkdir {root}/wt &> {log} && echo "mkdir {root}/wt" &> {log} || true')
        shell(f"foldx --command=AnalyseComplex --pdb=model_Repair.pdb --pdb-dir=data/complex/{wildcards.complex} --clean-mode=3 --output-dir=data/complex/{wildcards.complex}/{wildcards.interface}/wt --analyseComplexChains={wildcards.interface.replace('_', ',')} &> {log}")

rule complex_variants:
    """
    Make list of variants in an interface
    """
    input:
        yaml='data/complex/{complex}/model.yaml',
        residues='data/complex/{complex}/{interface}/wt/Interface_Residues_model_Repair_AC.fxout'

    output:
        'data/complex/{complex}/{interface}/individual_list'

    log:
        'logs/complex_variants/{complex}_{interface}.log'

    run:
        # Supply chains string if in the config yaml, else use all chains defined in the interface
        yaml = YAML(typ='safe')
        config = yaml.load(Path(input.yaml))
        allowed_chains = config['mutate_chains'] if 'mutate_chains' in config else wildcards.interface.replace('_', '')
        regex = f"--regex '^[A-Z][{allowed_chains}][0-9]*$' "
        shell(f"tail -n +10 {input.residues} | grep -v interface | tr '\n' '\t' | xargs python bin/protein_variants.py --unique --suffix $';\n' --exclude --wt 0 --foldx --sort 2 {regex}> {output} 2> {log}")

rule complex_mutant_models:
    """
    Generate PDBs with each mutation in the interface using FoldX BuildModel
    """
    input:
        muts='data/complex/{complex}/{interface}/individual_list',
        pdb='data/complex/{complex}/model_Repair.pdb'

    output:
        directory('data/complex/{complex}/{interface}/mutant_pdbs'),
        'data/complex/{complex}/{interface}/mutant_models_made'

    resources:
        mem_mb = 16000

    log:
        'logs/complex_mutant_models/{complex}_{interface}.log'

    shell:
        """
        mkdir data/complex/{wildcards.complex}/{wildcards.interface}/mutant_pdbs &> {log}
        foldx --command=BuildModel --pdb-dir=data/complex/{wildcards.complex} --pdb=model_Repair.pdb --mutant-file={input.muts} --output-dir=data/complex/{wildcards.complex}/{wildcards.interface}/mutant_pdbs --numberOfRuns=1 --clean-mode=3 --out-pdb=true &> {log}
        rm data/complex/{wildcards.complex}/{wildcards.interface}/mutant_pdbs/WT_* &> {log}
        touch 'data/complex/{wildcards.complex}/{wildcards.interface}/mutant_models_made' &> {log}
        """

rule complex_mut_analysis:
    """
    Analyse mutant interfaces using FoldX AnalyseComplex.
    """
    input:
        'data/complex/{complex}/{interface}/mutant_models_made'

    output:
        directory('data/complex/{complex}/{interface}/mutant'),
        'data/complex/{complex}/{interface}/mutant_list',
        'data/complex/{complex}/{interface}/mutant_analysis_done'

    resources:
        mem_mb = 32000

    log:
        'logs/complex_mut_analysis/{complex}_{interface}.log'

    run:
        root = f'data/complex/{wildcards.complex}/{wildcards.interface}'

        # Make mutant list
        mut_nums = [int(i) for i in glob_wildcards(f'{root}/mutant_pdbs/model_Repair_{{n}}.pdb').n]
        with open(f'{root}/mutant_list', 'w') as mutant_list:
            print(*[f'model_Repair_{n}.pdb' for n in sorted(mut_nums)], sep='\n', file=mutant_list)

        # Analyse complexes
        shell(f'mkdir {root}/mutant &> {log} && echo "mkdir {root}/mutant" &> {log} || true')
        shell(f"foldx --command=AnalyseComplex --pdb-list=data/complex/{wildcards.complex}/{wildcards.interface}/mutant_list --pdb-dir=data/complex/{wildcards.complex}/{wildcards.interface}/mutant_pdbs --clean-mode=3 --output-dir=data/complex/{wildcards.complex}/{wildcards.interface}/mutant --analyseComplexChains={wildcards.interface.replace('_', ',')} &> {log}")
        shell(f"touch {root}/mutant_analysis_done &> {log}")

rule complex_combine:
    """
    Combine output files from running complex_mut_analysis
    """
    input:
        flag='data/complex/{complex}/{interface}/mutant_analysis_done',
        mutants='data/complex/{complex}/{interface}/individual_list',
        wt_interface='data/complex/{complex}/{interface}/wt/Interface_Residues_model_Repair_AC.fxout',
        wt_interaction='data/complex/{complex}/{interface}/wt/Interaction_model_Repair_AC.fxout',
        wt_indiv='data/complex/{complex}/{interface}/wt/Indiv_energies_model_Repair_AC.fxout',
        wt_summary='data/complex/{complex}/{interface}/wt/Summary_model_Repair_AC.fxout'

    output:
        indiv='data/complex/{complex}/{interface}/individual_energies.tsv',
        interaction='data/complex/{complex}/{interface}/interactions.tsv',
        interface='data/complex/{complex}/{interface}/interface_residues.tsv',
        summary='data/complex/{complex}/{interface}/summary.tsv'

    log:
        'logs/complex_combine/{complex}_{interface}.log'

    run:
        shell(f"python bin/complex_combine.py {input.mutants} {input.wt_indiv} data/complex/{wildcards.complex}/{wildcards.interface}/mutant > {output.indiv} 2> {log}")
        shell(f"python bin/complex_combine.py {input.mutants} {input.wt_interaction} data/complex/{wildcards.complex}/{wildcards.interface}/mutant > {output.interaction} 2> {log}")
        shell(f"python bin/complex_combine.py {input.mutants} {input.wt_interface} data/complex/{wildcards.complex}/{wildcards.interface}/mutant > {output.interface} 2> {log}")
        shell(f"python bin/complex_combine.py {input.mutants} {input.wt_summary} data/complex/{wildcards.complex}/{wildcards.interface}/mutant > {output.summary} 2> {log}")

def get_complex_tsv_files(complex):
    """
    Determine required input for complex_tsv from a given complex
    """
    yaml = YAML(typ='safe')
    config = yaml.load(Path(f'data/complex/{complex}/model.yaml'))
    required = [f'data/complex/{complex}/model.yaml']
    for interface in config['interfaces']:
        required.extend([f'data/complex/{complex}/{interface}/interactions.tsv',
                         f'data/complex/{complex}/{interface}/interface_residues.tsv'])
    return required

rule complex_tsv:
    """
    Combine complex FoldX results into one tsv
    """
    input:
        [get_complex_tsv_files(c) for c in COMPLEXES]

    output:
        'data/output/complex.tsv'

    log:
        'logs/complex_tsv.log'

    shell:
        f'python bin/complex_tsv.py {" ".join(f"data/complex/{c}/model.yaml" for c in COMPLEXES)} > {{output}} 2> {{log}}'
