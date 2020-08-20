import React from "react";
import Typography from '@material-ui/core/Typography';
import Link from '@material-ui/core/Link';
import { makeStyles } from '@material-ui/core/styles';
import { MutBadge } from './MutBadges'
import * as deleterious from '../lib/deleterious'

const styles = makeStyles({
    root: {
        flexGrow: 1,
        margin: 'auto',
        padding: '10px',
        width: '70%'
    },
    badgeList: {
        marginTop: 5,
        listStyle: 'none'
    },
    badgeKey: {
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'flex-start',
        marginTop: 10
    }
});

const Help = () => {
    const classes = styles()
    return(
        <div className={classes.root}>
            <Typography>
                Mutfunc: SARS-CoV-2 provides a subset of <Link href='https://www.mutfunc.com'>Mutfunc</Link> variant effect predictions for SARS-CoV-2, the novel coronavirus responsible for COVID-19.
                Mutfunc is a database of precomputed variant effect predictions from various tools for all <i>S. cerevisiae</i>, <i>H. sapians</i> and <i>E. coli</i> variants.
                The main Mutfunc website has predictions conservation, structural consequences, protein interfaces, post-transational modifications, transcription factor binding sites and linear motifs.
                Mutfunc: SARS-CoV-2 currently covers observed variant frequency, conservation, structural consequences, protein interfaces and phosphosites.

                The website provides an interface for searching variants online, downloading complete dataset and gives an overview analysis of the data.
            </Typography>
            <Typography variant='h5'>
                Searching Variants
            </Typography>
            <Typography>
                The search interface allows you to search SARS-CoV-2 variants with a number of terms:

                <ul>
                    <li>Protein names - all variants in a given protein (e.g. nsp1).</li>
                    <li>Uniprot ID - all variants for a Uniprot ID (e.g. P0DTC3)</li>
                    <li>Positions - A specific gene position (e.g. nsp1 1). Wildtype amino acid specification is also supported (e.g. nsp1 M1)</li>
                    <li>Specific variants - A specific variant (e.g. nsp1 M1A). Searching without the wildtype is also supported (e.g. nsp1 1A) but is slightly slower.</li>
                </ul>

                Formatting:
                <ul>
                    <li>Search terms should be separated by newlines, commas (,) or semicolons (;).</li>
                    <li>Any time a gene name is used the corresponding Uniprot ID can be used if it uniquely identifies the gene. The Uniprot IDs for the two polyprotein variants (P0DTD1 and P0DTC1) cannot replace names as they refer to multiple final proteins.</li>
                    <li>Gene name synonymns (sourced from Uniprot) are also supported, for example Pol, RdRp and nsp12 all refer to the same protein.</li>
                    <li>Gene names and Uniprot IDs are both case insensitive.</li>
                </ul>
            </Typography>
            <Typography variant='h5'>
                Results Table
            </Typography>
            <Typography>
                The mutations returned by your search are displayed in a table, by default filtered to only display variants with a significant predicted effect.
                All identified variants can be displayed using the checkbox in the table controls.
                Variants are predicted to be significant if they fulfil any of the following conditions:

                <ul className={classes.badgeList}>
                    <li className={classes.badgeKey}>
                        <MutBadge type='frequency'/>
                        &nbsp;&nbsp;Frequency: {deleterious.frequencyText}
                    </li>
                    <li className={classes.badgeKey}>
                        <MutBadge type='conservation'/>
                        &nbsp;&nbsp;Conservation: {deleterious.conservationText}
                    </li>
                    <li className={classes.badgeKey}>
                        <MutBadge type='structure'/>
                        &nbsp;&nbsp;Structure: {deleterious.structureText}
                    </li>
                    <li className={classes.badgeKey}>
                        <MutBadge type='interfaces'/>
                        &nbsp;&nbsp;Interfaces: {deleterious.interfacesText}
                    </li>
                    <li className={classes.badgeKey}>
                        <MutBadge type='ptm'/>
                        &nbsp;&nbsp;PTM: {deleterious.ptmText}
                    </li>
                </ul>

                The predictions column shows which factors are predicted to be significant.
                Clicking on a variants row opens a panel with additional details on predictions.
            </Typography>
            <Typography variant='h5'>
                Predictions
            </Typography>
            <Typography>
                Three categories of predictions and measurement are shown in hte details panel of each variant: conservation, structure and interfaces.
            </Typography>
            <Typography variant='subtitle1'>
                Conservation
            </Typography>
            <Typography>
                <ul>
                    <li>The observed frequency of the variant, calculated from the <Link href='https://www.gisaid.org/' target="_blank" rel="noopener noreferrer">GISAID</Link> datatset</li>
                    <li>Whether the position has an post-translational modifications (currently only phosphorylations from <Link href="https://europepmc.org/article/med/32645325" target="_blank" rel="noopener noreferrer"> Bouhaddou et al. (2020) </Link> are included)</li>
                    <li><Link href="https://sift.bii.a-star.edu.sg/sift4g/" target="_blank" rel="noopener noreferrer"> SIFT4G </Link> score</li>
                    <li>The alignment generated by SIFT4G</li>
                </ul>

                SIFT4G scores are often generated from reasonably closely related sequences and need to be interpretted with caution
            </Typography>
            <Typography variant='subtitle1'>
                Structure
            </Typography>
            <Typography>
                The structural consequences are calculated by <Link href="http://foldxsuite.crg.eu/" target="_blank" rel="noopener noreferrer">FoldX</Link> and summarised by the &Delta;&Delta;G statistic.
                This measures the predicted stabilisation (&lt;0) or destabilisation (&gt;0) of the variant, with absolute values greater than one being considered significant.
                The PDB model used is also listed as well as being viewable with the variant highlighted.
                These models were identified using the <Link href="https://swissmodel.expasy.org/repository/species/2697049" target="_blank" rel="noopener noreferrer">SWISS-Model COVID Repository</Link> and contain a mixture of direct SARS-CoV-2 models and homology models.
            </Typography>
            <Typography variant='subtitle1'>
                Interfaces
            </Typography>
            <Typography>
                Protein interfaces, again gathered from the SWISS-Model COVID Repository, were also analysed using FoldX.
                It identifies the amino acids involved in an inerface and assesses the properties of the interface.
                The amino acids in the interfaces were computationally mutated to all other amino acids and the interface assessed again by FoldX to determine variants affect on stability.
                This is again summarised by the &Delta;&Delta;G statistic and also includes the predicted change in the number of amino acids involved in the interface.
                Again the template and a viewable structure are available.
            </Typography>

            <Typography>
                Additional breakdowns of all statistics, for example the factors contributing to FoldX's &Delta;&Delta;G statistic, are available in the full dataset.
            </Typography>
        </div>
    )
}

export default Help