import React, { useState } from "react";
import { makeMutKey } from "../lib/mutations"

const DataViewer = ({ data, dataReady }) => {
    const [viewAll, setViewAll] = useState(false)

    const handleViewClick = () => {
        setViewAll(!viewAll);
    }
    //console.log(data)

    if (!dataReady){
        return(
            <p>Loading Data</p>
        )
    }

    if (data.length === 0){
        return(
            <div>
                <button onClick={handleViewClick}>
                {(viewAll ? 'Hide' : 'View')} variants without predicted effects
                </button>
                <ul>
                </ul>
            </div>
        )
    }

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
            <button onClick={handleViewClick}>
            {(viewAll ? 'Hide' : 'View')} variants without predicted effects
            </button>
            <ul>
                {[filteredData.map((i) => <li key={makeMutKey(i)}>
                    {[i['uniprot'], i['name'], i['position'], i['wt'], '->',
                      i['mut'], 'SIFT:', i['sift_score']].join(' ')}
                </li>)]}
            </ul>
        </div>
    )
}

export default DataViewer;