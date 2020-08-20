import React from "react";
import {sarsGenePositions, sarsDisplayNames} from "../lib/sars";

const darkCol = "#1f78b4"
const lightCols = ["#a6cee3", "#cde3ef"]

const genes = {
    'nsp1': 'center', 'nsp2': 'center', 'nsp3': 'center',
    'nsp4': 'center', 'nsp5': 'above', 'nsp6': 'center',
    'nsp7': 'above', 'nsp8': 'center', 'nsp9': 'above',
    'nsp10': 'below', 'nsp11': 'none', 'nsp12': 'center', 'nsp13': 'center',
    'nsp14': 'center', 'nsp15': 'center', 'nsp16': 'center',
    's': 'center', 'orf3a': 'center', 'e': 'center',
    'm': 'center', 'orf6': 'above', 'orf7a': 'below',
    'orf7b': 'doubleAbove', 'orf8': 'above',
    'orf9b': 'below', 'nc': 'center', 'orf10': 'above'
}

const labY = {doubleAbove: 100, above: 350, below: 1120, center: 800}
const labBaseline = {above: 'baseline', below: 'hanging', center: 'middle'}

const Gene = ({name, colour, label=''}) => {
    const x = sarsGenePositions[name][0]
    const width = sarsGenePositions[name][1] - sarsGenePositions[name][0]
    const position = label !== '' ? label : genes[name]
    const textY = labY[position]
    const baseline = labBaseline[position]
    return(
        <>
        <rect x={x} y="500" width={width} height="600" rx="15" fill={colour}/>
        {position !== 'none' ? (<text
            x={x + width / 2} y={textY}
            fontSize="300"
            dominantBaseline={baseline}
            textAnchor="middle"
            fill={colour === darkCol && position === 'center' ? 'white' : 'black'}>
                {sarsDisplayNames[name]}
        </text>) : null}
        </>
    )
}

// Set heights properly
// Text above and below rects
// Marker for mut position
// Do nsp11 + orf1ab manually
const GenomeViewer = ({geneName, mutPosition}) => {
    const mutPos = sarsGenePositions[geneName][0] + 3 * mutPosition
    const mutPoints = [[mutPos - 75, 450], [mutPos + 75, 450], [mutPos, 650]]
                       .map((i) => i.join(','))
                       .join(' ')
    return(
        <svg width="90%" viewBox="-300 -200 30600 1900">
            <line x1="1" y1="800" x2="29903" y2="800" stroke="black" strokeWidth="0.25%"/>
            <text
              x="-200"
              y="800"
              fontSize="300"
              dominantBaseline="middle"
              textAnchor="middle">
                5'
            </text>
            <text
              x="30150"
              y="800"
              fontSize="300"
              dominantBaseline="middle"
              textAnchor="middle">
                3'
            </text>
            {Object.keys(genes).map((gene, i) => (
                <Gene
                  key={gene}
                  name={gene}
                  colour={gene === geneName ? darkCol : lightCols[i % 2]}
                />
            ))}
            <Gene
                name='nsp11'
                colour={lightCols[0]}
                label='doubleAbove'
            />
            <polygon points={mutPoints} fill='red'/>
        </svg>
    )
}

export default GenomeViewer