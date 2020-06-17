"""
Rules to analyse interface interactions using FoldX's AnalyseComplex command
"""

# TODO More complexs, automatically fetch complexes?
COMPLEXES = ['nsp9_nsp9']

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
    Analyse the WT complex to identify interface residues
    """
    input:
        pdb='data/complex/{complex}/model_Repair.pdb',
        yaml='data/complex/{complex}/model.yaml'

    output:
        'data/complex/{complex}/wt/Indiv_energies_model_Repair_AC.fxout',
        'data/complex/{complex}/wt/Interaction_model_Repair_AC.fxout',
        'data/complex/{complex}/wt/Interface_Residues_model_Repair_AC.fxout',
        'data/complex/{complex}/wt/Summary_model_Repair_AC.fxout'

    log:
        'logs/complex_wt_analysis/{complex}.log'

    run:
        yaml = YAML(typ='safe')
        config = yaml.load(Path(input.yaml))
        shell(f'mkdir data/complex/{wildcards.complex}/wt && echo "mkdir data" || true &> {log}')
        shell(f"foldx --command=AnalyseComplex --pdb=model_Repair.pdb --pdb-dir=data/complex/{wildcards.complex} --clean-mode=3 --output-dir=data/complex/{wildcards.complex}/wt --analyseComplexChains={config['chains']} &> {log}")

rule complex_variants:
    """
    Make list of variants in an interface
    """
    input:
        'data/complex/{complex}/wt/Interface_Residues_model_Repair_AC.fxout'

    output:
        'data/complex/{complex}/individual_list'

    log:
        'logs/complex_variants/{complex}.log'

    shell:
        'tail -n 1 {input} | xargs python bin/protein_variants.py --suffix ";\n" --exclude 0 > {output} 2> {log}'

checkpoint complex_mutant_models:
    """
    Generate PDBs with each mutation in the interface using FoldX BuildModel
    """
    input:
        muts='data/complex/{complex}/individual_list',
        pdb='data/complex/{complex}/model_Repair.pdb'

    output:
        directory('data/complex/{complex}/mutant_pdbs')

    log:
        'logs/complex_mutant_models/{complex}.log'

    shell:
        """
        mkdir data/complex/{wildcards.complex}/mutant_pdbs &> {log}
        foldx --command=BuildModel --pdb-dir=data/complex/{wildcards.complex} --pdb=model_Repair.pdb --mutant-file={input.muts} --output-dir=data/complex/{wildcards.complex}/mutant_pdbs --numberOfRuns=1 --clean-mode=3 --out-pdb=true &> {log}
        rm data/complex/{wildcards.complex}/mutant_pdbs/WT_* &> {log}
        """

def get_mutant_pdbs(wildcards):
    """
    Identify mutant PDB files from complex_mutant_models
    """
    checkpoint_outdir = checkpoints.complex_mutant_models.get(complex=wildcards.complex).output[0]
    pdbs = expand('data/complex/{complex}/mutant_pdbs/model_Repair_{n}.pdb',
                  complex=wildcards.complex,
                  n=glob_wildcards(os.path.join(checkpoint_outdir, "model_Repair_{n}.pdb")).n)
    return {'pdb': pdbs, 'yaml': f'data/complex/{wildcards.complex}/model.yaml'}

checkpoint complex_mut_analysis:
    """
    Analyse mutant interfaces using FoldX AnalyseComplex.
    """
    input:
        unpack(get_mutant_pdbs)

    output:
        directory('data/complex/{complex}/mutant'),
        'data/complex/{complex}/mutant_list'

    log:
        'logs/complex_mut_analysis/{complex}.log'

    run:
        yaml = YAML(typ='safe')
        config = yaml.load(Path(input.yaml))
        with open(f'data/complex/{wildcards.complex}/mutant_list', 'w') as mutant_list:
            pdbs = sorted(input.pdb, key=lambda x: int(x.replace('.', '_').split('_')[-2]))
            for pdb in pdbs:
                print(Path(pdb).name, file=mutant_list)
        shell(f'mkdir data/complex/{wildcards.complex}/mutant && echo "mkdir data" || true &> {log}')
        shell(f"foldx --command=AnalyseComplex --pdb-list=data/complex/{wildcards.complex}/mutant_list --pdb-dir=data/complex/{wildcards.complex}/mutant_pdbs --clean-mode=3 --output-dir=data/complex/{wildcards.complex}/mutant --analyseComplexChains={config['chains']} &> {log}")

def get_mutant_interface_files(wildcards):
    """
    Identify mutant interface files produced by complex_mut_analysis
    """
    checkpoint_outdir = checkpoints.complex_mut_analysis.get(complex=wildcards.complex).output[0]
    n = glob_wildcards(os.path.join(checkpoint_outdir, "Summary_model_Repair_{n}_AC.fxout")).n
    root = f'data/complex/{wildcards.complex}/mutant'
    return {
        'indiv': [f'{root}/Indiv_energies_model_Repair_{i}_AC.fxout' for i in n],
        'interaction': [f'{root}/Interaction_model_Repair_{i}_AC.fxout' for i in n],
        'interface': [f'{root}/Interface_Residues_model_Repair_{i}_AC.fxout' for i in n],
        'summary': [f'{root}/Summary_energies_model_Repair_{i}_AC.fxout' for i in n],
        'mutants': f'data/complex/{wildcards.complex}/individual_list'
    }

rule complex_combine:
    """
    Combine output files from running complex_mut_analysis
    """
    input:
        unpack(get_mutant_interface_files)

    output:
        indiv='data/complex/{complex}/indivdual_energies.tsv',
        interaction='data/complex/{complex}/interactions.tsv',
        interface='data/complex/{complex}/interface_residues.tsv',
        summary='data/complex/{complex}/summary.tsv'

    log:
        'logs/complex_combine/{complex}.log'

    run:
        shell(f"python bin/complex_combine.py {input.mutants} {input.indiv} > {output.indiv} 2> {log}")
        shell(f"python bin/complex_combine.py {input.mutants} {input.interaction} > {output.interaction} 2> {log}")
        shell(f"python bin/complex_combine.py {input.mutants} {input.interface} > {output.interface} 2> {log}")
        shell(f"python bin/complex_combine.py {input.mutants} {input.summary} > {output.summary} 2> {log}")

rule complex_tsv:
    """
    Combine complex FoldX results into one tsv
    """
    input:
        indiv=[f'data/complex/{c}/indivdual_energies.tsv' for c in COMPLEXES],
        interaction=[f'data/complex/{c}/interactions.tsv' for c in COMPLEXES],
        interface=[f'data/complex/{c}/interface_residues.tsv' for c in COMPLEXES],
        summary=[f'data/complex/{c}/summary.tsv' for c in COMPLEXES]

    output:
        'data/output/complex.tsv'

    log:
        'logs/complex_tsv.log'

    shell:
        'echo "NOT IMPLEMENTED YET"'
