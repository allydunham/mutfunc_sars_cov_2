import React, { useState, useEffect} from "react";
import {tsv} from "d3";
import CircularProgress from '@material-ui/core/CircularProgress';
import CheckIcon from '@material-ui/icons/Check';
import { green } from '@material-ui/core/colors';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core/styles';
import MutTable from "./MutTable"
import MutSearch from "./MutSearch"
import MutDetails from "./MutDetails"
import { makeMutKey, searchMutations } from "../lib/mutations";

const styles = makeStyles({
    root: {
        flexGrow: 1,
        textAlign: 'center'
    },
    item: {
        width: "75%"
    },
    check: {
        color: green[500]
    }
});

const DataDisplay = (props) => {
    const classes = styles();
    const {dataReady, dataNotification, searchResults,
           searching, data, selectedMut, setSelectedMut,
           search} = props;
    const [longSearch, setLongSearch] = useState(false)

    // Reset longSearch when a search starts of finishes
    useEffect(() => setLongSearch(false),[searching])

    if (!dataReady){
        return(
            <Grid item className={classes.item}>
                <CircularProgress />
                <br/>
                <Typography>Loading Data</Typography>
            </Grid>
        )
    }

    if (searching){
        if (!longSearch){
            setTimeout(() => {if(searching){setLongSearch(true)}}, 500)
            return <></>
        } else {
            return(
                <Grid item className={classes.item}>
                    <CircularProgress />
                    <br/>
                    <Typography>Searching...</Typography>
                </Grid>
            )
        }
    }

    if (!dataNotification && searchResults.length === 0){
        return(
            <Grid item className={classes.item}>
                <CheckIcon className={classes.check} fontSize='large'/>
                <br/>
                <Typography>Data Loaded!</Typography>
            </Grid>
        )
    }

    // Keep site clean before a search has happened, once data loaded etc.
    if (search === false){
        return <></>
    }

    // Return results table if no special case is found
    return(
        <>
        <Grid item className={classes.item}>
            <MutDetails mut={selectedMut}/>
        </Grid>
        <Grid item className={classes.item}>
            <MutTable data={searchResults.map((k) => data[k])} setSelectedMut={setSelectedMut}/>
        </Grid>
        </>
    )
}

function nanOrNumber(x){
    return x === ''? NaN : Number(x)
}

const DataController = (props) => {
    const classes = styles();

    const [data, setData] = useState([]);
    const [dataReady, setDataReady] = useState(false);
    const [dataNotification, setDataNotification] = useState(false);

    const [search, setSearch] = useState(false);
    const [searching, setSearching] = useState(false);
    const [searchResults, setSearchResults] = useState([]);

    const [selectedMut, setSelectedMut] = useState(null)

    useEffect(() => {
        console.log('Fetching Data...');
        function reducer(map, value){
            map[makeMutKey(value)] = {
                ...value,
                'position': nanOrNumber(value['position']),
                'sift_score': nanOrNumber(value['sift_score']),
                'total_energy': nanOrNumber(value['total_energy']),
                'interaction_energy': nanOrNumber(value['interaction_energy']),
                'diff_interaction_energy': nanOrNumber(value['diff_interaction_energy']),
                'diff_interface_residues': nanOrNumber(value['diff_interface_residues']),
            };
            return map
        }
        tsv(process.env.PUBLIC_URL + '/data/summary.tsv')
            .then((download) => {
                const mutMap = download.reduce(reducer, {});
                setData(mutMap);
                console.log('Data Loaded');
                setDataReady(true);
                setTimeout(() => setDataNotification(true), 2000)
            })
    }, []);

    useEffect(() => {
        if (!(search === false)){
            searchMutations(search).then((result) => {
                console.log(result)
                setSearchResults(result);
                setTimeout(() => setSearching(false), 5000);
            })
        }
    }, [search])

    return(
        <Grid container spacing={4} direction="column" alignItems="center" className={classes.root}>
            <Grid item className={classes.item}>
                <MutSearch setSearch={setSearch} setSearching={setSearching}/>
            </Grid>
            {search === false ? (
                <Grid item className={classes.item}>
                    <Typography>Search for SARS-CoV2 Variants</Typography>
                </Grid>
            ) : null}
            <DataDisplay
              dataReady={dataReady}
              dataNotification={dataNotification}
              search={search}
              searchResults={searchResults}
              searching={searching}
              data={data}
              selectedMut={selectedMut}
              setSelectedMut={setSelectedMut}
            />
        </Grid>
    )
}

export default DataController;
