import React, { useEffect, useState} from "react";
import Typography from '@material-ui/core/Typography';
import {json} from 'd3';
import {
    Labels,
    MSAViewer,
    PositionBar,
    SequenceViewer,
  } from 'react-msa-viewer';

const SiftAlignmnet = ({gene, hidden, width=600, height=0}) => {
    const [seqs, setSeqs] = useState([])

    useEffect(() => {
        console.log('Fetching Fasta: ' + gene);
        const url = process.env.PUBLIC_URL + '/data/sift_alignments/' + gene + '.json'
        json(url)
          .then((fasta) => setSeqs(fasta))
          .catch((err) => setSeqs([]))
    }, [gene]);

    height = height === 0 ? Math.max(50 + 20 * seqs.length, 100) : height

    return(
        <div hidden={hidden} width={width} height={height}>
            {seqs.length > 0 ? (
                <MSAViewer
                  sequences={seqs}
                  width={width}
                  height={height}
                  markerSteps={4}
                  sequenceScrollBarPositionX='top'
                >
                    <div style={{display: "flex"}} >
                        <div>
                            <br/>
                            <br/>
                            <Labels/>
                        </div>
                        <div>
                            <br/>
                            <PositionBar />
                            <SequenceViewer/>
                        </div>
                    </div>
                </MSAViewer>
            ) : (
                <Typography>No alignment</Typography>
            )}
        </div>
    )
}

export default SiftAlignmnet