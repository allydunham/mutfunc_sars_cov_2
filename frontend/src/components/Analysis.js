import React from "react";
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles({
    root: {
        flexGrow: 1,
        margin: 'auto',
        padding: '10px',
        width: '70%'
    },
    heading: {
        paddingTop: '50px'
    },
    content: {
        paddingTop: '25px',
    }
});


const Analysis = () => {
    const classes = styles()
    return(
        <div className={classes.root}>
            <Typography variant='h5' className={classes.heading}>
                Analysis of the Overall Dataset
            </Typography>
        </div>
    )
}

export default Analysis