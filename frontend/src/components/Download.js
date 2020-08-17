import React from "react";
import Typography from '@material-ui/core/Typography';
import Grid from '@material-ui/core/Grid';
import Link from '@material-ui/core/Link';

const Download = () => {
    return(
        <Grid container direction='column' alignItems='center' justify='center' spacing={4}>
            <Grid item xs={8}>
                <Typography variant='h4'>
                    Summary table (summary.tsv)
                </Typography>
                <Typography>
                    This table contains summary data of each feature, containing the key result metric but not additional columns breaking down the result.<br/>Columns:
                    <ul>
                        <li>uniprot: Uniprot ID</li>
                        <li>name: Protein Name</li>
                        <li>position: Position in protein</li>
                        <li>wt: WT Amino Acid</li>
                        <li>mut: Mutant Amino Acid</li>
                        <li>sift_score: SIFT4G Score</li>
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
            </Grid>
            <Grid item xs={8}>
                <Typography variant='h4'>
                    SIFT4G Results (sift.tsv)
                </Typography>
                <Typography>
                    This table contains the results from&nbsp;
                    <Link
                      href="https://sift.bii.a-star.edu.sg/sift4g/"
                      target="_blank"
                      rel="noopener noreferrer">
                        SIFT4G
                    </Link><br/>Columns:
                    <ul>
                        <li>uniprot: Uniprot ID</li>
                        <li>name: Protein Name</li>
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
            </Grid>
            <Grid item xs={8}>
                <Typography variant='h4'>
                    FoldX results (foldx.tsv)
                </Typography>
                <Typography>
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
                        <li>name: Protein Name</li>
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
            </Grid>
            <Grid item xs={8}>
                <Typography variant='h4'>
                    PTM Positions (ptms.tsv)
                </Typography>
                <Typography>
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
                        <li>name: Protein Name</li>
                        <li>position: Position in protein</li>
                        <li>wt: WT Amino Acid</li>
                        <li>ptm</li>
                        <li>experiment</li>
                        <li>ala_score</li>
                        <li>asp_score</li>
                        <li>glu_score</li>
                        <li>n_seq</li>
                        <li>kinase1</li>
                        <li>kinase1_p</li>
                        <li>kinase2</li>
                        <li>kinase2_p</li>
                        <li>secondary_structure</li>
                        <li>relative_asa</li>
                    </ul>
                </Typography>
            </Grid>
        </Grid>
    )
}

export default Download