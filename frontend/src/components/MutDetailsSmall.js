import React, { useState } from "react";
import Grid from '@material-ui/core/Grid';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import MuiTableCell from '@material-ui/core/TableCell';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import Link from "@material-ui/core/Link";
import Button from '@material-ui/core/Button';
import { makeStyles, withStyles } from '@material-ui/core/styles';
import { sarsDisplayNames } from '../lib/sars'

import MutBadges from './MutBadges'
import AlignmentPopup from './AlignmentPopup'
import StructurePopup from './StructurePopup'

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

const MutDetailStats = ({mut}) => {
    const [fxOpen, setFxOpen] = useState(false);
    const [intOpen, setIntOpen] = useState(false);
    const [alignOpen, setAlignOpen] = useState(false);

    return(
        <Table>
            <TableBody>
                <TableRow>
                    <TableCell variant='head'>
                        <Typography variant='h6'>
                            Conservation
                        </Typography>
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell>
                        Frequency: {isNaN(mut['freq']) ? 'Not Observed': mut['freq']}
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell>
                        PTM: {mut['ptm'] === "" ? 'None' : mut['ptm']}
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell>
                        SIFT4G Score: {isNaN(mut['sift_score']) ? 'NA': mut['sift_score']}
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell>
                        SIFT4G Median IC: {isNaN(mut['sift_median']) ? 'NA': mut['sift_median']}
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell>
                        <Button
                          color='secondary'
                          onClick={() => setAlignOpen(true)}
                          disabled={isNaN(mut['sift_score'])}>
                            View SIFT4G alignment
                        </Button>
                        <AlignmentPopup
                          mut={mut}
                          open={alignOpen}
                          setOpen={setAlignOpen}
                          width={200}
                        />
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell variant='head'>
                        <Typography variant='h6'>
                            Structure
                        </Typography>
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell>
                        Template: {mut['template'] === '' ? "None" : (
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
                    <TableCell>
                        FoldX &Delta;&Delta;G: {isNaN(mut['total_energy']) ? 'NA': mut['total_energy']}
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell>
                        <Button
                          color='secondary'
                          onClick={() => setFxOpen(true)}
                          disabled={mut['template'] === ''}>
                            View Structure
                        </Button>
                        <StructurePopup
                          mut={mut}
                          open={fxOpen}
                          setOpen={setFxOpen}
                          width={200}
                          height={200}
                        />
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell variant='head'>
                        <Typography variant='h6'>
                            Interfaces
                        </Typography>
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell>
                        Interface partner: {mut['int_name'] === '' ? null : (
                            <Link
                                href={"https://www.uniprot.org/uniprot/" + mut['int_uniprot']}
                                target="_blank"
                                rel="noopener noreferrer">
                                {mut['int_uniprot']}
                            </Link>
                        )}
                        {mut['int_name'] === '' ? "None" : " " + mut['int_name']}
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell>
                        Template: {mut['int_template'] === '' ? "None" : (
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
                    <TableCell>
                        Interface &Delta;&Delta;G: {isNaN(mut['diff_interaction_energy']) ? 'NA': mut['diff_interaction_energy']}
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell>
                        {getInterfaceNumString(mut['diff_interface_residues'])}
                    </TableCell>
                </TableRow>

                <TableRow>
                    <TableCell>
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
                          width={200}
                          height={200}
                        />
                    </TableCell>
                </TableRow>
            </TableBody>
        </Table>
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

    const mut_text = [sarsDisplayNames[mut['name']], ' ', mut['wt'],
                      mut['position'], mut['mut']].join('')

    return(
        <Paper variant="outlined" elevation={2} className={classes.root}>
            <Grid
              container
              spacing={1}
              direction='column'
              justify="space-evenly"
              alignItems="center"
            >
                <Grid item>
                    <Typography align='left' variant='h6' className={classes.title}>
                        <Link
                          href={"https://www.uniprot.org/uniprot/" + mut['uniprot']}
                          target="_blank"
                          rel="noopener noreferrer">
                            {mut['uniprot']}
                        </Link>
                        &nbsp;
                        {mut_text}
                    </Typography>
                </Grid>
                <Grid item>
                    <MutBadges mut={mut}/>
                </Grid>
                <Grid item>
                    <MutDetailStats mut={mut}/>
                </Grid>
            </Grid>
        </Paper>
    )
}

export default MutDetails