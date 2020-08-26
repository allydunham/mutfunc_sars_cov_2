import React from "react";
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles({
    separater: {
        flexGrow: 1
    },
    footer: {
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'flex-end',
        top: 'auto',
        bottom: 0,
        paddingLeft: 10,
        paddingRight: 10,
        background: 'transparent',
        boxShadow: 'none'
    },
    logo: {
        marginRight: '10px',
        width: 'auto',
        maxWidth: '40%',
        height: '5vh'
    }
});

const Footer = () => {
    const classes = styles()
    return(
        <footer className={classes.footer}>
            <img
              src={process.env.PUBLIC_URL + 'images/ebi_logo.svg'}
              alt='ebi-logo'
              className={classes.logo}
            />
            <div className={classes.separater}/>
            <Typography variant='caption' align='right'>
                v1.0 - Data Updated: 19/08/2020
            </Typography>
        </footer>
    )
}

export default Footer