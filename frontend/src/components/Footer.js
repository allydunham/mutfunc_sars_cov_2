import React from "react";
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles({
    separater: {
        flexGrow: 1
    },
    footer: {
        top: 'auto',
        bottom: 0,
        background: 'transparent',
        boxShadow: 'none'
    }
});

const Footer = () => {
    const classes = styles()
    return(
        <AppBar position='fixed' color='transparent' className={classes.footer}>
            <Toolbar>
                <img
                  src={process.env.PUBLIC_URL + 'ebi_logo.svg'}
                  alt='ebi-logo'
                  width='10%'
                />
                <div className={classes.separater}/>
            </Toolbar>
        </AppBar>
    )
}

export default Footer