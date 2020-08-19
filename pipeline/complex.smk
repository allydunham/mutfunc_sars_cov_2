"""
Rules to analyse interface interactions using FoldX's AnalyseComplex command
"""
from snakemake.exceptions import MissingInputException

COMPLEXES = ['nsp9_nsp9', 'nsp7_nsp8', 'nsp7_nsp8_pol', 'nsp10_nsp14',
             'nsp10_nsp16', 'ace2_spike']

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
        mem_mb = 4000

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
        'data/complex/{complex}/{interface}/wt/Interface_Residues_model_Repair_AC.fxout'

    output:
        'data/complex/{complex}/{interface}/individual_list'

    log:
        'logs/complex_variants/{complex}_{interface}.log'

    shell:
        "tail -n +10 {input} | grep -v interface | tr '\n' '\t' | xargs python bin/protein_variants.py --unique --suffix $';\n' --exclude --wt 0 --foldx --sort 2 > {output} 2> {log}"

checkpoint complex_mutant_models:
    """
    Generate PDBs with each mutation in the interface using FoldX BuildModel
    """
    input:
        muts='data/complex/{complex}/{interface}/individual_list',
        pdb='data/complex/{complex}/model_Repair.pdb'

    output:
        directory('data/complex/{complex}/{interface}/mutant_pdbs')

    log:
        'logs/complex_mutant_models/{complex}_{interface}.log'

    shell:
        """
        mkdir data/complex/{wildcards.complex}/{wildcards.interface}/mutant_pdbs &> {log}
        foldx --command=BuildModel --pdb-dir=data/complex/{wildcards.complex} --pdb=model_Repair.pdb --mutant-file={input.muts} --output-dir=data/complex/{wildcards.complex}/{wildcards.interface}/mutant_pdbs --numberOfRuns=1 --clean-mode=3 --out-pdb=true &> {log}
        rm data/complex/{wildcards.complex}/{wildcards.interface}/mutant_pdbs/WT_* &> {log}
        """

def get_mutant_pdbs(wildcards):
    """
    Identify mutant PDB files from complex_mutant_models
    """
    checkpoint_outdir = checkpoints.complex_mutant_models.get(**wildcards).output[0]
    pdbs = expand('data/complex/{complex}/{interface}/mutant_pdbs/model_Repair_{n}.pdb',
                  complex=wildcards.complex, interface=wildcards.interface,
                  n=glob_wildcards(os.path.join(checkpoint_outdir, "model_Repair_{n}.pdb")).n)
    return pdbs

checkpoint complex_mut_analysis:
    """
    Analyse mutant interfaces using FoldX AnalyseComplex.
    """
    input:
        get_mutant_pdbs

    output:
        directory('data/complex/{complex}/{interface}/mutant'),
        'data/complex/{complex}/{interface}/mutant_list'

    resources:
        mem_mb = 32000

    log:
        'logs/complex_mut_analysis/{complex}_{interface}.log'

    run:
        root = f'data/complex/{wildcards.complex}/{wildcards.interface}'
        with open(f'{root}/mutant_list', 'w') as mutant_list:
            pdbs = sorted(input, key=lambda x: int(x.replace('.', '_').split('_')[-2]))
            for pdb in pdbs:
                print(Path(pdb).name, file=mutant_list)
        shell(f'mkdir {root}/mutant &> {log} && echo "mkdir {root}/mutant" &> {log} || true')
        shell(f"foldx --command=AnalyseComplex --pdb-list=data/complex/{wildcards.complex}/{wildcards.interface}/mutant_list --pdb-dir=data/complex/{wildcards.complex}/{wildcards.interface}/mutant_pdbs --clean-mode=3 --output-dir=data/complex/{wildcards.complex}/{wildcards.interface}/mutant --analyseComplexChains={wildcards.interface.replace('_', ',')} &> {log}")

def get_mutant_interface_files(wildcards):
    """
    Identify mutant interface files produced by complex_mut_analysis
    """
    checkpoint_outdir = checkpoints.complex_mut_analysis.get(**wildcards).output[0]
    n = glob_wildcards(os.path.join(checkpoint_outdir, "Summary_model_Repair_{n}_AC.fxout")).n
    root = f'data/complex/{wildcards.complex}/{wildcards.interface}/mutant'
    wt_root = f'data/complex/{wildcards.complex}/{wildcards.interface}/wt'
    return {
        'indiv': [f'{root}/Indiv_energies_model_Repair_{i}_AC.fxout' for i in n],
        'interaction': [f'{root}/Interaction_model_Repair_{i}_AC.fxout' for i in n],
        'interface': [f'{root}/Interface_Residues_model_Repair_{i}_AC.fxout' for i in n],
        'summary': [f'{root}/Summary_model_Repair_{i}_AC.fxout' for i in n],
        'mutants': f'data/complex/{wildcards.complex}/{wildcards.interface}/individual_list',
        'wt_interface': f'{wt_root}/Interface_Residues_model_Repair_AC.fxout',
        'wt_interaction': f'{wt_root}/Interaction_model_Repair_AC.fxout',
        'wt_indiv': f'{wt_root}/Indiv_energies_model_Repair_AC.fxout',
        'wt_summary': f'{wt_root}/Summary_model_Repair_AC.fxout'
    }

rule complex_combine:
    """
    Combine output files from running complex_mut_analysis
    """
    input:
        unpack(get_mutant_interface_files)

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
