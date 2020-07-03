import React, { useState, useEffect} from "react";
import {tsv} from "d3";
import DataViewer from "./DataViewer"
import SearchBox from "./SearchBox"
import { makeMutKey } from "../lib/mutations";

const DataController = (props) => {
    const [data, setData] = useState([])
    const [dataReady, setDataReady] = useState(false)
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

    // P0DTC2_s_1MA, P0DTD1_nsp12_603KD, P0DTD1_nsp3_1810NG, P0DTD1_nsp7_69NI
    const [search, setSearch] = useState([]);
    return(
        <div className='DataController'>
            <SearchBox setSearch={setSearch}/>
            <DataViewer data={search.map((k) => data[k])} dataReady={dataReady}/>
        </div>
    )
}

export default DataController;
