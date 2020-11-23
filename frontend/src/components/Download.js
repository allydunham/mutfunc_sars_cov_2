import React from "react";
import Typography from '@material-ui/core/Typography';
import Link from '@material-ui/core/Link';
import IconButton from '@material-ui/core/IconButton';
import GetAppIcon from '@material-ui/icons/GetApp';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles({
    root: {
        flexGrow: 1,
        margin: 'auto',
        padding: '10px',
        width: '70%'
    },
    heading: {
        paddingTop: '50px'
    },
    content: {
        paddingTop: '25px',
    }
});

const Download = () => {
    const classes = styles()
    return(
        <div className={classes.root}>
            <Typography className={classes.content}>
                The output data from the combined tools and sources is avaiable to download here and on the <Link href="http://ftp.ebi.ac.uk/pub/databases/mutfunc/" target="_blank" rel="noopener noreferrer">Mutfunc FTP</Link>.
                Note that the protein names used in these tables are the internal identifiers and in some cases are slightly different from those displayed on the website, for example all are lower case and "nc" is used for N.
            </Typography>

            <Typography variant='h5' className={classes.heading}>
                Summary table
                <IconButton href={process.env.PUBLIC_URL + 'data/summary.tsv'}>
                    <GetAppIcon/>
                </IconButton>
            </Typography>
            <Typography component={'span'} className={classes.content}>
                This table contains summary data of each feature, containing the key result metric but not additional columns breaking down the result.<br/>Columns:
                <ul>
                    <li>uniprot: Uniprot ID</li>
                    <li>name: Protein name</li>
                    <li>position: Position in protein</li>
                    <li>wt: WT Amino Acid</li>
                    <li>mut: Mutant Amino Acid</li>
                    <li>sift_score: SIFT4G Score</li>
                    <li>sift_median: SIFT4G Median IC</li>
                    <li>template: FoldX PDB Model Template (from SWISS-MODEL, sometimes this will be a direct model of the target protein and sometimes a homology model). Takes the format PDBID.Chain</li>
                    <li>total_energy: FoldX &Delta;&Delta;G Prediction</li>
                    <li>ptm: Post Translational Modification at the site</li>
                    <li>int_uniprot: Uniprot ID of interface protein</li>
                    <li>int_name: Name of interface protein</li>
                    <li>int_template: PDB model template of the interface interaction</li>
                    <li>interaction_energy: FoldX &Delta;G Prediction for the interface binding energy with the mutation</li>
                    <li>diff_interaction_energy: Change in interface &Delta;G from the wilt-type</li>
                    <li>diff_interface_residues: FoldX prediction for the change in the number of residues involved in the interface after the mutation</li>
                    <li>freq: Observed frequency of the mutation in the wild (based on GISAID compiled data)</li>
                </ul>
            </Typography>
            <Typography variant='h5' className={classes.heading}>
                Observed Frequencies
                <IconButton href={process.env.PUBLIC_URL + 'data/frequency.tsv'}>
                    <GetAppIcon/>
                </IconButton>
            </Typography>
            <Typography component={'span'} className={classes.content}>
                This table contains data on observed mutation frequencies in the wild, based on the data collected by GSAID.
                <br/>Columns:
                <ul>
                    <li>uniprot: Uniprot ID</li>
                    <li>name: Protein Name</li>
                    <li>position: Position in protein</li>
                    <li>wt: WT Amino Acid</li>
                    <li>mut: Mutant Amino Acid</li>
                    <li>overall: Observed frequency across all samples</li>
                    <li>last90days: Observed frequency across samples from the last 90 days</li>
                    <li>NorthAfrica-Oceania: Observed frequency across samples from the specified region</li>
                </ul>
            </Typography>
            <Typography variant='h5' className={classes.heading}>
                SIFT4G Results
                <IconButton href={process.env.PUBLIC_URL + 'data/sift.tsv'}>
                    <GetAppIcon/>
                </IconButton>
            </Typography>
            <Typography component={'span'} className={classes.content}>
                This table contains the results from&nbsp;
                <Link
                    href="https://sift.bii.a-star.edu.sg/sift4g/"
                    target="_blank"
                    rel="noopener noreferrer">
                    SIFT4G
                </Link><br/>Columns:
                <ul>
                    <li>uniprot: Uniprot ID</li>
                    <li>name: Protein name</li>
                    <li>position: Position in protein</li>
                    <li>wt: WT Amino Acid</li>
                    <li>mut: Mutant Amino Acid</li>
                    <li>sift_prediction: Whether SIFT4G predicts the variant to be DELETERIOUS or TOLERATED</li>
                    <li>sift_score: SIFT4G Score</li>
                    <li>sift_median: Median information content at that position in the alignmnet. This measures sequence diversity from 0 to 4.32. Values between 2.75 and 3.5 are considered good by SIFT4G, with &gt; 3.5 indicating all sequences are closely related</li>
                    <li>num_aa: Number of Amino Acid types observed at that position</li>
                    <li>num_seq: Number of sequences in the alignment for that position</li>
                </ul>
            </Typography>
            <Typography variant='h5' className={classes.heading}>
                FoldX results
                <IconButton href={process.env.PUBLIC_URL + 'data/foldx.tsv'}>
                    <GetAppIcon/>
                </IconButton>
            </Typography>
            <Typography component={'span'} className={classes.content}>
                This table contains results from&nbsp;
                <Link
                    href="http://foldxsuite.crg.eu/"
                    target="_blank"
                    rel="noopener noreferrer">
                    FoldX's
                </Link>
                &nbsp;
                <Link
                    href="http://foldxsuite.crg.eu/command/BuildModel"
                    target="_blank"
                    rel="noopener noreferrer">
                    BuildModel
                </Link>
                &nbsp;command<br/>Columns:
                <ul>
                    <li>uniprot: Uniprot ID</li>
                    <li>name: Protein name</li>
                    <li>model: SWISS-MODEL model number</li>
                    <li>template: FoldX PDB Model Template (from SWISS-MODEL).</li>
                    <li>Chain: PDB Chain</li>
                    <li>position: Position in protein</li>
                    <li>wt: WT Amino Acid</li>
                    <li>mut: Mutant Amino Acid</li>
                    <li>sd: FoldX &Delta;&Delta;G Standard deviation over multiple model runs</li>
                    <li>total_energy: FoldX &Delta;&Delta;G Prediction</li>
                    <li>backbone_hbond - entropy_complex: &Delta;&Delta;G from each component</li>
                </ul>
            </Typography>
            <Typography variant='h5' className={classes.heading}>
                Interface analysis
                <IconButton href={process.env.PUBLIC_URL + 'data/complex.tsv'}>
                    <GetAppIcon/>
                </IconButton>
            </Typography>
            <Typography component={'span'} className={classes.content}>
                This table contains results from&nbsp;
                <Link
                    href="http://foldxsuite.crg.eu/"
                    target="_blank"
                    rel="noopener noreferrer">
                    FoldX's
                </Link>
                &nbsp;
                <Link
                    href="http://foldxsuite.crg.eu/command/AnalyseComplex"
                    target="_blank"
                    rel="noopener noreferrer">
                    AnalyseComplex
                </Link>
                &nbsp;command, which assesses the binding interface between two proteins in complex. Complex models were sourced from SWISS-Model and only amino acids FoldX predicts to be involved in the interface are tested for mutations.<br/>Columns:
                <ul>
                    <li>uniprot: Uniprot ID</li>
                    <li>name: Protein name</li>
                    <li>position: Position in protein</li>
                    <li>wt: WT Amino Acid</li>
                    <li>mut: Mutant Amino Acid</li>
                    <li>int_uniprot: Interface protein Uniprot ID</li>
                    <li>int_name: Interface protein name</li>
                    <li>model: PDB model ID</li>
                    <li>chain: Chain of main protein</li>
                    <li>int_chain: Chain of interface protein</li>
                    <li>intraclashesgroup1: Number of clashes in the mutant interface from the target protein</li>
                    <li>diff_intraclashesgroup1: Change in intraclashesgroup1 compared to the WT protein</li>
                    <li>intraclashesgroup2: Same as intraclashesgroup1 but for amino acids on the interfacing protein</li>
                    <li>diff_intraclashesgroup2: Change in intraclashesgroup2 from WT to mutant</li>
                    <li>interaction_energy: Interface &Delta;G for the mutant protein</li>
                    <li>diff_interaction_energy: &Delta;&Delta;G from WT to mutant</li>
                    <li>backbone_hbond - entropy_complex: Breakdown of &Delta;G contributions to interaction_energy from the different terms in FoldX's model</li>
                    <li>diff_backbone_hbond - diff_entropy_complex: Same breakdown for &Delta;&Delta;G between each term in WT and mutant</li>
                    <li>number_of_residues: Number of residues in the interface</li>
                    <li>diff_number_of_residues: Change in number of interface residues between WT and mutant</li>
                    <li>number_of_interface_residues: Number of amino acids involved in the mutant interface</li>
                    <li>diff_interface_residues: Change in number_of_interface_residues compared to the WT</li>
                    <li>interface_residues_clashing: Number of clashing interface residues in the mutant</li>
                    <li>diff_interface_residues_clashing: Change in clashing residues from the WT</li>
                    <li>interface_residues_vdw_clashing: Number of interface residues with Van der Waals clashes in the mutant</li>
                    <li>diff_interface_residues_vdw_clashing: Change in number of Van der Waals clasing residues from the WT</li>
                    <li>interface_residues_bb_clashing: Number of interface residues with backbone clashes</li>
                    <li>diff_interface_residues_bb_clashing: Change in number of interface residues with backbone clashes between WT and mutant</li>
                    <li>residues_lost: List of amino acids lost from the interface on mutation</li>
                    <li>residues_gained: List of amino acids added to the interface on mutation</li>
                    <li>interface_residues: List of amino acids in the mutated interface</li>
                </ul>
            </Typography>
            <Typography variant='h5' className={classes.heading}>
                PTM Positions
                <IconButton href={process.env.PUBLIC_URL + 'data/ptms.tsv'}>
                    <GetAppIcon/>
                </IconButton>
            </Typography>
            <Typography component={'span'} className={classes.content}>
                This table contains data on known PTM sites (
                <Link
                    href="https://europepmc.org/article/med/32645325"
                    target="_blank"
                    rel="noopener noreferrer">
                    Bouhaddou et al. (2020)
                </Link>)
                <br/>Columns:
                <ul>
                    <li>uniprot: Uniprot ID</li>
                    <li>name: Protein name</li>
                    <li>position: Position in protein</li>
                    <li>wt: WT Amino Acid</li>
                    <li>ptm: Post Translational Modification</li>
                    <li>experiment: Source experiment</li>
                    <li>ala_score: SIFT Score for mutation to alanine</li>
                    <li>asp_score: SIFT Score for mutation to aspartate</li>
                    <li>glu_score: SIFT Score for mutation to glutamate</li>
                    <li>n_seq: Number of sequences in SIFT alignment</li>
                    <li>kinase1: Top kinase hit</li>
                    <li>kinase1_p: Top kinase hit p value</li>
                    <li>kinase2: Second best kinase hit</li>
                    <li>kinase2_p: Second best kinase p value</li>
                    <li>secondary_structure: Secondary structure at the position</li>
                    <li>relative_asa: Relative accessible surface accessiblity</li>
                </ul>
            </Typography>
        </div>
    )
}

export default Download