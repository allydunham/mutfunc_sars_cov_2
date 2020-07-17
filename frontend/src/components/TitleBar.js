import React from "react";
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import IconButton from '@material-ui/core/IconButton';
import Button from '@material-ui/core/Button';
import GetAppIcon from '@material-ui/icons/GetApp';
import GitHubIcon from '@material-ui/icons/GitHub';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles({
    title: {
        flexGrow: 1,
        textAlign: 'left'
    },
    button: {
        color: 'white'
    }
});

const TitleBar = ({setPage}) => {
    const classes = styles()
    return(
        <AppBar position='sticky'>
            <Toolbar>
                <Typography variant='h6' className={classes.title}>
                    SARS-CoV2 Mutfunc
                </Typography>
                <Button className={classes.button} onClick={() => setPage('search')}>
                    Search
                </Button>
                <Button className={classes.button} onClick={() => setPage('about')}>
                    About
                </Button>
                <IconButton className={classes.button}>
                    <GetAppIcon/>
                </IconButton>
                <IconButton
                  href='https://github.com/allydunham/covid19_mutfunc'
                  className={classes.button}>
                    <GitHubIcon/>
                </IconButton>
            </Toolbar>
        </AppBar>
    )
}

export default TitleBar
