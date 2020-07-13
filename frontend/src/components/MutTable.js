import React, { useState } from "react";
import { makeMutKey } from "../lib/mutations"
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import Checkbox from '@material-ui/core/Checkbox';
import FormControl from '@material-ui/core/FormControl';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles({
    root: {
        flexGrow: 1
    },
    item: {
        width: "100%"
    }
});

const ShowNeutralCheck = ({viewAll, setViewAll}) => {
    return(
        <FormControl fullWidth>
            <FormControlLabel
                labelPlacement='start'
                control={<Checkbox
                           checked={viewAll}
                           onChange={(event) => {setViewAll(event.target.checked)}}
                         />}
                label="Show variants without predicted effects"
            />
        </FormControl>
    )
}

const EmptyRow = () => {
    return(
        <TableRow key='noData'>
            <TableCell colSpan={6} align='center'>No Results</TableCell>
        </TableRow>
    )
}

const MutRow = ({mut, setSelectedMut}) => {
    return(
        <TableRow hover onClick={(event) => setSelectedMut(mut)}>
            <TableCell>{mut['uniprot']}</TableCell>
            <TableCell>{mut['name']}</TableCell>
            <TableCell>{mut['position']}</TableCell>
            <TableCell>{mut['wt']}</TableCell>
            <TableCell>{mut['mut']}</TableCell>
            <TableCell>{mut['sift_score']}</TableCell>
        </TableRow>
    )
}

const MutTable = ({ data, setSelectedMut}) => {
    const classes = styles()
    const tableHeaders = ['Uniprot ID', 'Protein', 'Position', 'WT', 'Mutant', 'Predictions']
    const [viewAll, setViewAll] = useState(false)

    const filteredData = data.filter((mut) => {
        return viewAll ||
        (
            mut['sift_score'] < 0.05 ||
            Math.abs(mut['total_energy']) > 1 ||
            mut['ptm'] !== '' ||
            Math.abs(mut['diff_interaction_energy']) > 1 ||
            mut['diff_interface_residues'] !== 0
        )
    });

    return(
        <>
        <Grid
          container
          direction="column"
          alignContent='center'
          justify='flex-end'
          className={classes.root}
        >
            <Grid item className={classes.item} xs={12}>
                <ShowNeutralCheck viewAll={viewAll} setViewAll={setViewAll} />
            </Grid>
        </Grid>
        <Grid container direction="column" alignItems="center" className={classes.root}>
            <Grid item className={classes.item}>
                <TableContainer component={Paper}>
                    <Table>
                        <TableHead>
                            <TableRow key='header'>
                                {tableHeaders.map((i) => <TableCell key={i}>{i}</TableCell>)}
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {data.length === 0 ? <EmptyRow /> : filteredData.map((i) => (
                                <MutRow
                                  mut={i}
                                  setSelectedMut={setSelectedMut}
                                  key={makeMutKey(i)}/>
                            ))}
                        </TableBody>
                    </Table>
                </TableContainer>
            </Grid>
        </Grid>
        </>
    )
}

export default MutTable;