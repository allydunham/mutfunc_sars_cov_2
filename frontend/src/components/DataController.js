import React, { useState, useEffect} from "react";
import {tsv} from "d3";

const DataController = (props) => {
    const [data, setData] = useState([])
    const [dataReady, setDataReady] = useState(false)
    useEffect(() => {
        console.log('Fetching Data...');
        tsv(process.env.PUBLIC_URL + '/data/summary.tsv')
            .then((download) => {
                console.log(download);
                setData(download);
                setDataReady(true);
                console.log('Data Loaded');
        })
    }, []);

    const [search, setSearch] = useState([])

    return(
        <span>{dataReady ? 'Data Loaded' : 'Data Loading'}</span>
    )
}

export default DataController;
