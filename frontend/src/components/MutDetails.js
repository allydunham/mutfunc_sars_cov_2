import React from "react";
import Typography from '@material-ui/core/Typography';

const MutDetails = ({mut}) => {
    if (mut == null){
        return(<Typography align='center'>No variant selected</Typography>)
    }

    const mut_text = [mut['uniprot'], ' ', mut['name'], ' ', mut['position'], ' ',
                      mut['wt'], '>', mut['mut']].join('')

    return(<Typography align='center'>{mut_text}</Typography>)
}

export default MutDetails