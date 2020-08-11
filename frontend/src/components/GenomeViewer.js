import React from "react";
import {sarsGenePositions} from "../lib/sars";

const lightCols = ["#a6cee3", "#cde3ef"]

const Gene = ({name, colour}) => {
    const x = sarsGenePositions[name][0]
    const width = sarsGenePositions[name][1] - sarsGenePositions[name][0]
    return(
        <>
        <rect x={x} y="100" width={width} height="600" rx="15" fill={colour}/>
        <text
            x={x + width / 2} y="400" font-size="300"
            dominant-baseline="middle"
            text-anchor="middle">
                {name}
        </text>
        </>
    )
}

const genes = ['nsp1', 'nsp2', 'nsp3','nsp4', 'nsp5',
               'nsp6','nsp7', 'nsp8', 'nsp9', 'nsp10',
               'nsp12', 'nsp13', 'nsp14',
               'nsp15', 'nsp16', 's', 'orf3a', 'e',
               'm', 'orf6','orf7a', 'orf7b', 'orf8',
               'nc', 'orf10', 'orf9b']

// Set heights properly
// Text above and below rects
// Marker for mut position
// Do nsp11 + orf1ab manually
const GenomeViewer = ({gene_name}) => {
    return(
        <svg width="90%" viewBox="1 0 29903 1000">
            <line x1="1" y1="400" x2="29903" y2="400" stroke="black" strokeWidth="0.25%"/>
            {genes.map((gene, i) => (
                <Gene name={gene} colour={gene === gene_name ? "#1f78b4" : lightCols[i % 2]}/>
            ))}
        </svg>
    )
}

export default GenomeViewer