import React, { useState } from "react";
import Grid from '@material-ui/core/Grid';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import MuiTableCell from '@material-ui/core/TableCell';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogContent from '@material-ui/core/DialogContent';
import Link from "@material-ui/core/Link";
import { makeStyles, withStyles } from '@material-ui/core/styles';

import ProteinViewer from './ProteinViewer'
import SiftAlignment from './SiftAlignment'
import GenomeViewer from './GenomeViewer'
import MutBadges from './MutBadges'

const TableCell = withStyles({
    root: {
      borderBottom: "none",
      padding: '2px'
    }
  })(MuiTableCell);

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

const getInterfaceNumString = (change) => {
    switch (Math.sign(change)){
        case 0:
            return('No change in interface residues')
        case 1:
            return(change + ' interface residues gained')
        case -1:
            return(Math.abs(change) + ' interface residues lost')
        default:
            return('Unknown interface residue count change')
    }
}

const AlignmentPopup = ({mut, open, setOpen}) => {
    return(
        <Dialog open={open} onClose={() => setOpen(false)} scroll='body' fullWidth maxWidth='lg'>
            <DialogTitle>
                SIFT4G Alignment
            </DialogTitle>
            <DialogContent>
                <Grid container justify='center' alignItems='center'>
                    <Grid item xs={12}>
                        <SiftAlignment
                          gene={mut['uniprot'] + '_' + mut['name']}
                          width={1100}
                        />
                    </Grid>
                </Grid>
            </DialogContent>
        </Dialog>
    )
}

const StructurePopup = ({mut, interfaceModel, open, setOpen}) => {
    let template = ''
    let chain = ''
    let path = ''
    let int_chain = ''
    if (interfaceModel){
        [template, chain, int_chain] = mut['int_template'].split('.')
        path = [process.env.PUBLIC_URL, 'data/pdb_interface/', template, '.pdb'].join('')
    } else {
        [template, chain] = mut['template'].split('.')
        path = [process.env.PUBLIC_URL, 'data/pdb_foldx/', mut['uniprot'], '_',
                mut['name'], '/', template, '.pdb'].join('')
    }

    return(
        <Dialog open={open} onClose={() => setOpen(false)} scroll='body' fullWidth maxWidth='lg'>
            <DialogTitle>
                {interfaceModel ? 'Interface Structure Model' : 'Structure Model'}
            </DialogTitle>
            <DialogContent>
                <Grid container justify='space-evenly' alignItems='center'>
                    <Grid item xs={12}>
                        <ProteinViewer
                          pdb_path={path}
                          position={mut['position']}
                          chain={chain}
                          int_chain={int_chain}
                          width={900}
                          height={700}
                        />
                    </Grid>
                    <Grid item>
                        <Typography display='inline' variant='h5' style={{color: '#e6180d'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Mutant</Typography>
                    </Grid>
                    <Grid item>
                        <Typography display='inline' variant='h5' style={{color: '#8cb2f2'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Mutated Protein</Typography>
                    </Grid>
                    {interfaceModel ? (
                    <Grid item>
                        <Typography display='inline' variant='h5' style={{color: '#fa8ce6'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Interface Protein</Typography>
                    </Grid>
                    ) : null}
                </Grid>
            </DialogContent>
        </Dialog>
    )
}

const MutDetailStats = ({mut}) => {
    const [fxOpen, setFxOpen] = useState(false);
    const [intOpen, setIntOpen] = useState(false);
    const [alignOpen, setAlignOpen] = useState(false);

    return(
        <Grid
          container
          spacing={3}
          direction='row'
          justify="space-evenly"
          alignItems="flex-start"
        >
            <Grid item xs={4}>
                <Typography variant='h6' align='center'>Conservation</Typography>
                <Table>
                    <TableBody>
                        <TableRow>
                            <TableCell align='right'>
                                Frequency:
                            </TableCell>
                            <TableCell align='left'>
                                {isNaN(mut['freq']) ? 'Not Observed': mut['freq']}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align='right'>
                                PTM:
                            </TableCell>
                            <TableCell align='left'>
                                {mut['ptm'] === "" ? 'None' : mut['ptm']}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align='right'>
                                SIFT4G Score:
                            </TableCell>
                            <TableCell align='left'>
                                {isNaN(mut['sift_score']) ? 'NA': mut['sift_score']}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell colSpan={2} align='center'>
                                <Button
                                  color='secondary'
                                  onClick={() => setAlignOpen(true)}
                                  disabled={isNaN(mut['sift_score'])}>
                                    View SIFT4G alignment
                                </Button>
                                <AlignmentPopup mut={mut} open={alignOpen} setOpen={setAlignOpen}/>
                            </TableCell>
                        </TableRow>
                    </TableBody>
                </Table>
            </Grid>

            <Grid item xs={4}>
                <Typography variant='h6' align='center'>Structure</Typography>
                <Table>
                    <TableBody>
                        <TableRow>
                            <TableCell align='right'>
                                Template:
                            </TableCell>
                            <TableCell align='left'>
                                {mut['template'] === '' ? (
                                    "None"
                                ) : (
                                    <Link
                                      href={"https://www.ebi.ac.uk/pdbe/entry/pdb/" + mut['template'].split('.')[0]}
                                      target="_blank"
                                      rel="noopener noreferrer">
                                        {mut['template']}
                                    </Link>
                                )}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align='right'>
                                FoldX &Delta;&Delta;G:
                            </TableCell>
                            <TableCell align='left'>
                                {mut['ptm'] === "" ? 'None' : mut['ptm']}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell colSpan={2} align='center'>
                                <Button
                                  color='secondary'
                                  onClick={() => setFxOpen(true)}
                                  disabled={mut['template'] === ''}>
                                    View Structure
                                </Button>
                                <StructurePopup mut={mut} open={fxOpen} setOpen={setFxOpen}/>
                            </TableCell>
                        </TableRow>
                    </TableBody>
                </Table>
            </Grid>

            <Grid item xs={4}>
                <Typography variant='h6' align='center'>Interfaces</Typography>
                <Table>
                    <TableBody>
                        <TableRow>
                            <TableCell align='right'>
                                Interface partner:
                            </TableCell>
                            <TableCell align='left'>
                                {mut['int_name'] !== '' ? (
                                    <Link
                                      href={"https://www.uniprot.org/uniprot/" + mut['int_uniprot']}
                                      target="_blank"
                                      rel="noopener noreferrer">
                                        {mut['int_uniprot']}
                                    </Link>
                                ) : null}
                                {mut['int_name'] !== '' ? " " + mut['int_name'] : "None"}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align='right'>
                                Template:
                            </TableCell>
                            <TableCell align='left'>
                                {mut['int_template'] === '' ? (
                                    "None"
                                ) : (
                                    <Link
                                    href={"https://www.ebi.ac.uk/pdbe/entry/pdb/" + mut['int_template'].split('.')[0]}
                                    target="_blank"
                                    rel="noopener noreferrer">
                                        {mut['int_template']}
                                    </Link>
                                )}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align='right'>
                                Interface &Delta;&Delta;G:
                            </TableCell>
                            <TableCell align='left'>
                                {isNaN(mut['diff_interaction_energy']) ? 'NA': mut['diff_interaction_energy']}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell colSpan={2} align='center'>
                                {getInterfaceNumString(mut['diff_interface_residues'])}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell colSpan={2} align='center'>
                                <Button
                                  color='secondary'
                                  onClick={() => setIntOpen(true)}
                                  disabled={mut['int_template'] === ''}>
                                    View Interface
                                </Button>
                                <StructurePopup
                                  mut={mut}
                                  interfaceModel
                                  open={intOpen}
                                  setOpen={setIntOpen}
                                />
                            </TableCell>
                        </TableRow>
                    </TableBody>
                </Table>
            </Grid>
        </Grid>
    )
}

const MutDetails = ({mut}) => {
   const classes = styles();

    if (mut == null){
        return(
            <Paper className={classes.root} variant="outlined" elevation={3}>
                <Typography align='center'>Click a result to view details</Typography>
            </Paper>
        )
    }

    const mut_text = [mut['name'], ' ', mut['wt'],
                      mut['position'], mut['mut']].join('')

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
                        <Link
                          href={"https://www.uniprot.org/uniprot/" + mut['uniprot']}
                          target="_blank"
                          rel="noopener noreferrer">
                            {mut['uniprot']}
                        </Link>
                        &nbsp;
                        {mut_text}
                        &nbsp;
                        <MutBadges mut={mut}/>
                    </Typography>
                </Grid>
                <Grid item xs={12} className={classes.root}>
                    <GenomeViewer geneName={mut['name']} mutPosition={mut['position']}/>
                </Grid>
                <Grid item xs={10}>
                    <MutDetailStats mut={mut}/>
                </Grid>
            </Grid>
        </Paper>
    )
}

export default MutDetails