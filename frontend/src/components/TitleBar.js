import React from "react";
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import GetAppIcon from '@material-ui/icons/GetApp';
import GitHubIcon from '@material-ui/icons/GitHub';
import SearchIcon from '@material-ui/icons/Search';
import InfoIcon from '@material-ui/icons/Info';
import BarChartIcon from '@material-ui/icons/BarChart';
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
                <Button
                  className={classes.button}
                  onClick={() => setPage('search')}
                  startIcon={<SearchIcon/>}>
                    Search
                </Button>
                <Button
                  className={classes.button}
                  onClick={() => setPage('about')}
                  startIcon={<InfoIcon/>}>
                    About
                </Button>
                <Button
                  className={classes.button}
                  onClick={() => setPage('overview')}
                  startIcon={<BarChartIcon/>}>
                    Data Overview
                </Button>
                <Button
                  className={classes.button}
                  onClick={() => setPage('download')}
                  startIcon={<GetAppIcon/>}>
                    Download
                </Button>
                <Button
                  className={classes.button}
                  href='https://github.com/allydunham/covid19_mutfunc'
                  target="_blank"
                  rel="noopener noreferrer"
                  startIcon={<GitHubIcon/>}>
                    Source
                </Button>
            </Toolbar>
        </AppBar>
    )
}

export default TitleBar
