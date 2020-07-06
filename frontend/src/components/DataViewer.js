import React, { useState } from "react";
import { makeMutKey } from "../lib/mutations"
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import CircularProgress from '@material-ui/core/CircularProgress';
import Checkbox from '@material-ui/core/Checkbox';
import FormControl from '@material-ui/core/FormControl';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles({
    root: {
        flexGrow: 1,
    },
    item: {
        width: "65%"
    }
});

const ShowNeutralCheck = ({viewAll, setViewAll}) => {
    return(
        <FormControl>
            <FormControlLabel
                control={<Checkbox
                           checked={viewAll}
                           onChange={(event) => {setViewAll(event.target.checked)}}
                         />}
                label="Show variants without predicted effects"
            />
        </FormControl>
    )
}

const DataViewer = ({ data, dataReady }) => {
    const classes = styles()
    const tableHeaders = ['Uniprot ID', 'Protein', 'Position', 'WT', 'Mutant', 'Predictions']
    const [viewAll, setViewAll] = useState(false)

    if (!dataReady){
        return(
            <CircularProgress />
        )
    }

    if (data.length === 0){
        return(
            <Grid container direction="column" alignItems="center" className={classes.root}>
                <Grid item className={classes.item}>
                    <ShowNeutralCheck viewAll={viewAll} setViewAll={setViewAll} />
                </Grid>
                <Grid item className={classes.item}>
                    <TableContainer component={Paper}>
                        <Table>
                            <TableHead>
                                <TableRow key='header'>
                                    {tableHeaders.map((i) => <TableCell key={i}>{i}</TableCell>)}
                                </TableRow>
                            </TableHead>
                            <TableBody>
                                <TableRow key='noData'>
                                    <TableCell align='center'>No Results</TableCell>
                                </TableRow>
                            </TableBody>
                        </Table>
                    </TableContainer>
                </Grid>
            </Grid>
        )
    }

    console.log(data)

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
        <div className='DataViewer'>
            <ShowNeutralCheck viewAll={viewAll} setViewAll={setViewAll} />
            <TableContainer component={Paper}>
                <Table>
                    <TableHead>
                        <TableRow key='header'>
                            {tableHeaders.map((i) => <TableCell key={i}>{i}</TableCell>)}
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {filteredData.map((i) =>
                            <TableRow key={makeMutKey(i)}>
                                <TableCell>{i['uniprot']}</TableCell>
                                <TableCell>{i['name']}</TableCell>
                                <TableCell>{i['position']}</TableCell>
                                <TableCell>{i['wt']}</TableCell>
                                <TableCell>{i['mut']}</TableCell>
                                <TableCell>{i['sift_score']}</TableCell>
                            </TableRow>
                        )}
                    </TableBody>
                </Table>
            </TableContainer>
        </div>
    )
}

export default DataViewer;