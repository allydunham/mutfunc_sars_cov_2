import React from "react";
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles({
    separater: {
        flexGrow: 1,
        alignSelf: 'flex-end'
    },
    footer: {
        display: 'flex',
        flexDirection: 'row',
        top: 'auto',
        bottom: 0,
        paddingLeft: 10,
        paddingRight: 10,
        background: 'transparent',
        boxShadow: 'none'
    }
});

const Footer = () => {
    const classes = styles()
    return(
        <footer className={classes.footer}>
            <img
              src={process.env.PUBLIC_URL + 'ebi_logo.svg'}
              alt='ebi-logo'
              width='10%'
            />
            <div className={classes.separater}>
                <Typography align='right'>
                    v1.0 - Data Updated: 19/08/2020
                </Typography>
            </div>
        </footer>
    )
}

export default Footer