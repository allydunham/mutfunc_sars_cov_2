import React, { useState, useEffect } from "react";
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import Tabs from '@material-ui/core/Tabs';
import Tab from '@material-ui/core/Tab';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableRow from '@material-ui/core/TableRow';
import { makeStyles } from '@material-ui/core/styles';
import ProteinViewer from './ProteinViewer'
import SiftAlignment from './SiftAlignment'
import GenomeViewer from './GenomeViewer'
import MutBadges from './MutBadges'

const styles = makeStyles((theme) => ({
    root: {
        flexGrow: 1
    },
    title: {
        display: 'flex',
        paddingLeft: theme.spacing(1),
        paddingTop: theme.spacing(1),
        paddingRight: theme.spacing(0),
        paddingBottom: theme.spacing(0)
    }

}));

const InterfaceNumCell = ({change}) => {
    switch (Math.sign(change)){
        case 0:
            return(
                <TableCell colSpan={2} align='center'>
                    No change in interface residues
                </TableCell>
            )
        case 1:
            return(
                <TableCell colSpan={2} align='center'>
                    {change} interface residues gained
                </TableCell>
            )
        case -1:
            return(
                <TableCell colSpan={2} align='center'>
                    {Math.abs(change)} interface residues lost
                </TableCell>
            )
        default:
            return(
                <TableCell colSpan={2} align='center'>
                    Unknown interface residue count change
                </TableCell>
            )
    }
}

const MutStructure = ({mut}) => {
    const [tab, setTab] = useState(0);
    const [fx_template, fx_chain] = mut['template'].split('.')
    const [int_template, int_chain, int_interactor_chain] = mut['int_template'].split('.')

    useEffect(() => {
        let startTab = 0
        if (!isNaN(mut['sift_score']) && mut['sift_score'] < 0.05){
            startTab = 0
        } else if (fx_template !== '' || Math.abs(mut['total_energy']) > 1) {
            startTab = 1
        } else if (int_template !== '') {
            startTab = 2
        }
        setTab(startTab)
    }, [mut, fx_template, int_template])

    const foldx_path = [process.env.PUBLIC_URL, 'data/pdb_foldx/', mut['uniprot'],
                        '_', mut['name'], '/', fx_template, '.pdb'].join('')
    const int_path = [process.env.PUBLIC_URL, 'data/pdb_interface/',
                      int_template, '.pdb'].join('')

    const rootStyle = {width: 500, display: 'flex', marginLeft: 'auto',
                       marginRight: 'auto', flexDirection: 'column',
                       justifyContent: 'center'}

    return(
        <div style={{width: '100%', margin: 5}}>
            <div style={rootStyle}>
                <Tabs value={tab} onChange={(event, i) => setTab(i)}>
                    <Tab label="SIFT4G" disabled={isNaN(mut['sift_score'])}/>
                    <Tab label="FoldX" disabled={fx_template === ''}/>
                    <Tab label="Interface" disabled={int_template === ''}/>
                </Tabs>
                <SiftAlignment gene={mut['uniprot'] + '_' + mut['name']} hidden={tab !== 0}/>
                <ProteinViewer
                    hidden={tab !== 1}
                    pdb_path={fx_template !== '' ? foldx_path : ''}
                    position={mut['position']}
                    chain={fx_chain}/>
                <ProteinViewer
                    hidden={tab !== 2}
                    pdb_path={int_template !== '' ? int_path : ''}
                    position={mut['position']}
                    chain={int_chain}
                    int_chain={int_interactor_chain}/>
                <Grid container justify='space-around' alignItems='center'>
                    <Grid hidden={tab === 0} item>
                        <Typography display='inline' variant='h5' style={{color: '#e6180d'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Mutant</Typography>
                    </Grid>
                    <Grid hidden={tab === 0} item>
                        <Typography display='inline' variant='h5' style={{color: '#8cb2f2'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Mutated Protein</Typography>
                    </Grid>
                    <Grid hidden={tab === 0} item>
                        <Typography display='inline' variant='h5' style={{color: '#fa8ce6'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Interface Protein</Typography>
                    </Grid>
                </Grid>
            </div>
        </div>
    )
}

const MutDetails = ({mut}) => {
   const classes = styles()

    if (mut == null){
        return(
            <Paper className={classes.root} variant="outlined" elevation={3}>
                <Typography align='center'>No variant selected</Typography>
            </Paper>
        )
    }

    const mut_text = [mut['name'], ' ', mut['wt'], mut['position'], mut['mut']].join('')

    return(
        <Paper variant="outlined" elevation={2} className={classes.root}>
            <Grid
              container
              spacing={1}
              direction='row'
              justify="space-around"
              alignItems="stretch"
            >
                <Grid item xs={12}>
                    <Typography align='left' variant='h6' className={classes.title}>
                        {mut_text}
                        &nbsp;
                        <MutBadges mut={mut}/>
                    </Typography>
                </Grid>
                <Grid item xs={12} className={classes.root}>
                    <GenomeViewer gene_name={mut['name']}/>
                </Grid>
                <Grid item xs={5}>
                    <MutStructure mut={mut}/>
                </Grid>
                <Grid item xs={7} >
                    <Table>
                        <TableBody>
                            <TableRow>
                                <TableCell align='right'>Gene:</TableCell>
                                <TableCell align='left'>{mut['uniprot']}</TableCell>
                                <TableCell align='right'>Protein:</TableCell>
                                <TableCell align='left'>{mut['name']}</TableCell>
                                <TableCell align='right'>Mutation:</TableCell>
                                <TableCell align='left'>
                                    {mut['wt'] + mut['position'] + mut['mut']}
                                </TableCell>
                            </TableRow>
                            <TableRow>
                                <TableCell align='right'>SIFT Score:</TableCell>
                                <TableCell align='left'>
                                    {isNaN(mut['sift_score']) ? 'NA': mut['sift_score']}
                                </TableCell>
                                <TableCell align='right'>FoldX &Delta;&Delta;G:</TableCell>
                                <TableCell align='left'>
                                    {isNaN(mut['total_energy']) ? 'NA': mut['total_energy']}
                                </TableCell>
                                <TableCell align='right'>PTM:</TableCell>
                                <TableCell align='left'>
                                    {mut['ptm'] === "" ? 'None' : mut['ptm']}
                                </TableCell>
                            </TableRow>
                            <TableRow>
                                <TableCell align='right'>Frequency:</TableCell>
                                <TableCell align='left'>
                                    {isNaN(mut['freq']) ? 'Not Observed': mut['freq']}
                                </TableCell>
                                <TableCell align='right'></TableCell>
                                <TableCell align='left'></TableCell>
                                <TableCell align='right'></TableCell>
                                <TableCell align='left'></TableCell>
                            </TableRow>
                            {mut['int_name'] === "" ? (
                                <TableRow>
                                    <TableCell align='right'>Interface:</TableCell>
                                    <TableCell align='left'>None</TableCell>
                                    <TableCell align='right'></TableCell>
                                    <TableCell align='left'></TableCell>
                                    <TableCell align='right'></TableCell>
                                    <TableCell align='left'></TableCell>
                                </TableRow>
                            ) : (
                                <TableRow>
                                    <TableCell align='right'>Interface:</TableCell>
                                    <TableCell align='left'>{mut['int_name']}</TableCell>
                                    <TableCell align='right'>Interface &Delta;&Delta;G:</TableCell>
                                    <TableCell align='left'>
                                        {isNaN(mut['diff_interaction_energy']) ? 'NA':
                                         mut['diff_interaction_energy']}
                                    </TableCell>
                                    <InterfaceNumCell change={mut['diff_interface_residues']} />
                                </TableRow>
                            )}
                        </TableBody>
                    </Table>
                </Grid>
            </Grid>
        </Paper>
    )
}

export default MutDetails