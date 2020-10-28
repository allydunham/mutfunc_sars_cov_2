import React, { useState, useEffect} from "react";
import {tsv} from "d3";
import CircularProgress from '@material-ui/core/CircularProgress';
import CheckIcon from '@material-ui/icons/Check';
import { green } from '@material-ui/core/colors';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import { makeStyles, useTheme } from '@material-ui/core/styles';
import useMediaQuery from '@material-ui/core/useMediaQuery';
import MutSearch from "./MutSearch"
import MutDetails from "./MutDetails"
import MutDetailsSmall from "./MutDetailsSmall"
import MutTable from "./MutTable"
import MutTableSmall from "./MutTableSmall"
import SearchSummary from "./SearchSummary"
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
    },
    hidden: {
        display: 'none'
    }
});

const DataDisplay = (props) => {
    const theme = useTheme();
    const classes = styles();
    const small = useMediaQuery(theme.breakpoints.down('sm'));
    const {dataReady, dataNotification, searchResults,
           searching, data, selectedMut, setSelectedMut,
           search} = props;
    const [longSearch, setLongSearch] = useState(false)

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
            setTimeout(() => setLongSearch(true), 500)
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
    } else if (longSearch) {
        setLongSearch(false)
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
            <SearchSummary searchResults={searchResults} data={data}/>
        </Grid>
        <Grid item className={classes.item}>
            {small ? (
                <MutDetailsSmall mut={data[selectedMut]}/>
            ) : (
                <MutDetails mut={data[selectedMut]}/>
            )}
        </Grid>
        <Grid item className={classes.item}>
            {small ? (
            <MutTableSmall mutIds={searchResults} mutData={data} setSelectedMut={setSelectedMut}/>
            ) : (
            <MutTable mutIds={searchResults} mutData={data} setSelectedMut={setSelectedMut}/>
            )}
        </Grid>
        </>
    )
}

function nanOrNumber(x){
    return x === ''? NaN : Number(x)
}

const DataController = ({hidden}) => {
    const classes = styles();

    const [data, setData] = useState([]);
    const [dataReady, setDataReady] = useState(false);
    const [dataNotification, setDataNotification] = useState(false);

    const [search, setSearch] = useState(false);
    const [searching, setSearching] = useState(false);
    const [searchResults, setSearchResults] = useState([]);
    const [searchErrors, setSearchErrors] = useState([]);

    const [selectedMut, setSelectedMut] = useState(null)

    useEffect(() => {
        console.log('Fetching Data...');
        function reducer(map, value){
            const key = makeMutKey(value)
            if (!(key in map)){
                map[key] = {
                    'uniprot': value['uniprot'],
                    'name': value['name'],
                    'position': nanOrNumber(value['position']),
                    'wt': value['wt'],
                    'mut': value['mut'],
                    'sift_score': nanOrNumber(value['sift_score']),
                    'sift_median': nanOrNumber(value['sift_median']),
                    'template': value['template'],
                    'total_energy': nanOrNumber(value['total_energy']),
                    'ptm': value['ptm'],
                    'freq': nanOrNumber(value['freq']),
                    'interfaces': []
                }
            }

            if (value['int_name'] !== ''){
                map[key]['interfaces'].push({
                    'name': value['int_name'],
                    'uniprot': value['int_uniprot'],
                    'template': value['int_template'],
                    'interaction_energy': nanOrNumber(value['interaction_energy']),
                    'diff_interaction_energy': nanOrNumber(value['diff_interaction_energy']),
                    'diff_interface_residues': nanOrNumber(value['diff_interface_residues'])
                })
            }

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
            setSelectedMut(null)
            searchMutations(search, data).then((result) => {
                console.log(result)
                setSearchResults(result['results']);
                setSearchErrors(result['errors']);
                setSearching(false)
                // Simulate long search for testing
                //setTimeout(() => setSearching(false), 5000);
            })
        }
    }, [search, data])

    return(
        <Grid container spacing={4} direction="column" alignItems="center"
              className={hidden ? classes.hidden : classes.root}>
            <Grid item className={classes.item}>
                <MutSearch
                  search={search}
                  setSearch={setSearch}
                  errors={searchErrors}
                  searching={searching}
                  setSearching={setSearching}/>
            </Grid>
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
