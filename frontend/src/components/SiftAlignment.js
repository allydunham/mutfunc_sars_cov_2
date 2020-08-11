import React, { useEffect, useState} from "react";
import Typography from '@material-ui/core/Typography';
import {json} from 'd3';
import {
    Labels,
    MSAViewer,
    PositionBar,
    SequenceViewer,
  } from 'react-msa-viewer';

const SiftAlignmnet = ({gene, hidden}) => {
    const [seqs, setSeqs] = useState([])

    useEffect(() => {
        console.log('Fetching Fasta: ' + gene);
        const url = process.env.PUBLIC_URL + '/data/sift_alignments/' + gene + '.json'
        json(url)
          .then((fasta) => setSeqs(fasta))
          .catch((err) => setSeqs([]))
    }, [gene]);

    return(
        <div hidden={hidden} width={400} height={300}>
            {seqs.length > 0 ? (
                <MSAViewer
                  sequences={seqs}
                  width={400}
                  height={300}
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