import React, { useState, useEffect} from "react";
import {tsv} from "d3";
import CircularProgress from '@material-ui/core/CircularProgress';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core/styles';
import MutTable from "./MutTable"
import MutSearch from "./MutSearch"
import MutDetails from "./MutDetails"
import { makeMutKey } from "../lib/mutations";

const styles = makeStyles({
    root: {
        flexGrow: 1,
        textAlign: 'center'
    },
    item: {
        width: "75%"
    },
});


const DataController = (props) => {
    const classes = styles();
    const [data, setData] = useState([]);
    const [dataReady, setDataReady] = useState(false);
    const [search, setSearch] = useState([]);
    const [selectedMut, setSelectedMut] = useState(null)

    useEffect(() => {
        console.log('Fetching Data...');
        function reducer(map, value){
            map[makeMutKey(value)] = {
                ...value,
                'position': Number(value['position']),
                'sift_score': Number(value['sift_score']),
                'total_energy': Number(value['total_energy']),
                'interaction_energy': Number(value['interaction_energy']),
                'diff_interaction_energy': Number(value['diff_interaction_energy']),
                'diff_interface_residues': Number(value['diff_interface_residues']),
            };
            return map
        }
        tsv(process.env.PUBLIC_URL + '/data/summary.tsv')
            .then((download) => {
                const mutMap = download.reduce(reducer, {});
                setData(mutMap);
                console.log('Data Loaded');
                setDataReady(true);
            })
    }, []);

    // s_M1A,nsp12_K603D,nsp3_N1810G,nsp7_N69I
    return(
        <Grid container spacing={4} direction="column" alignItems="center" className={classes.root}>
            <Grid item className={classes.item}>
                <MutSearch data={data} setSearch={setSearch}/>
            </Grid>
            <Grid item className={classes.item}>
                <MutDetails mut={selectedMut}/>
            </Grid>
            <Grid item className={classes.item}>
                {dataReady ? (
                    <MutTable data={search.map((k) => data[k])} setSelectedMut={setSelectedMut}/>
                ) : (
                    <><CircularProgress />
                    <br/>
                    <Typography>Loading Data</Typography></>
                )}
            </Grid>
        </Grid>
    )
}

export default DataController;
