import React, { useState, useEffect } from "react";
import Typography from "@material-ui/core/Typography";
import Link from "@material-ui/core/Link";
import Grid from "@material-ui/core/Grid";
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import MuiTableCell from '@material-ui/core/TableCell';
import TableRow from '@material-ui/core/TableRow';
import { withStyles } from '@material-ui/core/styles';

const TableCell = withStyles({
    root: {
      borderBottom: "none",
      padding: '2px'
    }
  })(MuiTableCell);

const SearchSummary = ({searchResults, data}) => {
    const [showDetails, setShowDetails] = useState(false);
    const [results, setResults] = useState([]);
    const [counts, setCounts] = useState({});

    useEffect(() => {
        setResults(searchResults.map((i) => data[i]));
    }, [searchResults, data]);

    useEffect(() => {
        setCounts(results.reduce((c, mut) => {
            let sig = false;
            if (!isNaN(mut['freq'])){
                c['observed'] += 1
                if (mut['freq'] > 0.01){
                    sig = true
                    c['frequent'] += 1
                }
            }
            if (mut['sift_score'] < 0.05){
                sig = true
                c['sift'] += 1
            }
            if (Math.abs(mut['total_energy']) > 1){
                sig = true
                c['foldx'] += 1
            }
            if (mut['ptm'] !== ''){
                sig = true
                c['ptm'] += 1
            }
            if (mut['int_name'] !== ''){
                sig = true
                c['interface'] += 1
            }
            if (sig){
                sig = true
                c['significant'] += 1
            }
            return(c)
        }, {observed: 0, frequent: 0, sift: 0, foldx: 0, ptm: 0, interface: 0, significant: 0}))
    }, [results]);

    return(
        <Grid
            container
            spacing={1}
            direction='row'
            justify="space-around"
            alignItems="stretch"
        >
            <Grid item xs={12}>
                <Typography align='left' variant='subtitle1' display='inline'>
                    Found {results.length} variants, of which {counts['significant']} have significant predicted effects (
                    <Link component='button' onClick={() => setShowDetails(!showDetails)}>
                        {showDetails ? 'Hide details' : 'Show details'}
                    </Link>)
                </Typography>

            </Grid>
            {showDetails ? (
                <Grid item>
                    <Table>
                    <TableBody>
                        <TableRow>
                            <TableCell align="right">
                                Total:
                            </TableCell>
                            <TableCell align="left">
                                {results.length}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align="right">
                                Observed in nature:
                            </TableCell>
                            <TableCell align="left">
                                {counts['observed']}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align="right">
                                Frequency &gt; 0.01:
                            </TableCell>
                            <TableCell align="left">
                                {counts['frequent']}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align="right">
                                Significant predicted effects:
                            </TableCell>
                            <TableCell align="left">
                                {counts['significant']}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align="right">
                                SIFT4G Score &lt; 0.05:
                            </TableCell>
                            <TableCell align="left">
                                {counts['sift']}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align="right">
                                |FoldX Score| &gt; 1 kj&nbsp;mol<sup>-1</sup>:
                            </TableCell>
                            <TableCell align="left">
                                {counts['foldx']}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align="right">
                                PTM site variants:
                            </TableCell>
                            <TableCell align="left">
                                {counts['ptm']}
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell align="right">
                                Interface variants:
                            </TableCell>
                            <TableCell align="left">
                                {counts['interface']}
                            </TableCell>
                        </TableRow>
                    </TableBody>
                    </Table>
                </Grid>
            ) : null}
        </Grid>
    )
}

export default SearchSummary