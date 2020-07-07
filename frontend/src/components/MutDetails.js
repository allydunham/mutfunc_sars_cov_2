import React from "react";
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableRow from '@material-ui/core/TableRow';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles((theme) => ({
    root: {
        flexGrow: 1
    },
    title: {
        paddingLeft: theme.spacing(1),
        paddingTop: theme.spacing(0),
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
        <Paper variant="outlined" elevation={2}>
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
                    </Typography>
                </Grid>
                <Grid item xs={5}>
                    <Paper color='secondary'>
                        <Typography align='center' style={{height: 100}}>
                            Structure Viewer
                        </Typography>
                    </Paper>
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
                                <TableCell align='left'>{mut['sift_score']}</TableCell>
                                <TableCell align='right'>FoldX &Delta;&Delta;G:</TableCell>
                                <TableCell align='left'>{mut['total_energy']}</TableCell>
                                <TableCell align='right'>PTM:</TableCell>
                                <TableCell align='left'>
                                    {mut['ptm'] === "" ? 'None' : mut['ptm']}
                                </TableCell>
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
                                        {mut['diff_interaction_energy']}
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