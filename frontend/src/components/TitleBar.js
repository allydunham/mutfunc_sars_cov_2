import React from "react";
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Button from '@material-ui/core/Button';
import GetAppIcon from '@material-ui/icons/GetApp';
import GitHubIcon from '@material-ui/icons/GitHub';
import SearchIcon from '@material-ui/icons/Search';
import InfoIcon from '@material-ui/icons/Info';
import HelpOutlineIcon from '@material-ui/icons/HelpOutline';
import BarChartIcon from '@material-ui/icons/BarChart';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles({
    logo: {
        marginRight: '10px',
    },
    text: {
        color: '#333334'
    },
    separater: {
        flexGrow: 1
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
                <img
                  src={process.env.PUBLIC_URL + 'mutfunc_logo.svg'}
                  alt='mutfunc-logo'
                  width='20%'
                  className={classes.logo}
                />
                <div className={classes.separater}/>
                <Button
                  className={classes.button}
                  onClick={() => setPage('search')}
                  startIcon={<SearchIcon/>}>
                    Search
                </Button>
                <Button
                  className={classes.button}
                  onClick={() => setPage('analysis')}
                  startIcon={<BarChartIcon/>}>
                    Analysis
                </Button>
                <Button
                  className={classes.button}
                  onClick={() => setPage('help')}
                  startIcon={<HelpOutlineIcon/>}>
                    Help
                </Button>
                <Button
                  className={classes.button}
                  onClick={() => setPage('download')}
                  startIcon={<GetAppIcon/>}>
                    Download
                </Button>
                <Button
                  className={classes.button}
                  onClick={() => setPage('about')}
                  startIcon={<InfoIcon/>}>
                    About
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
