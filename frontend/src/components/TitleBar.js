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
import { makeStyles, useTheme } from '@material-ui/core/styles';

const styles = makeStyles((theme) => ({
    logo: {
        marginRight: '10px',
    },
    separater: {
        flexGrow: 1
    },
    button: {
        color: theme.palette.primary.contrastText
    },
    selectedButton: {
        color: theme.palette.secondary.main
  }
}));

const PageButton = ({type, page, setPage, icon}) => {
    const classes = styles(useTheme())
    return(
        <Button
          className={page === type ? classes.selectedButton : classes.button}
          onClick={() => setPage(type)}
          startIcon={icon}>
            {type.toUpperCase()}
        </Button>
    )
}

const TitleBar = ({page, setPage}) => {
    const classes = styles(useTheme())
    return(
        <AppBar position='sticky'>
            <Toolbar>
                <img
                  src={process.env.PUBLIC_URL + 'images/mutfunc_logo.svg'}
                  alt='mutfunc-logo'
                  width='20%'
                  className={classes.logo}
                />
                <div className={classes.separater}/>
                <PageButton type='search' page={page} setPage={setPage} icon={<SearchIcon/>}/>
                <PageButton type='analysis' page={page} setPage={setPage} icon={<BarChartIcon/>}/>
                <PageButton type='help' page={page} setPage={setPage} icon={<HelpOutlineIcon/>}/>
                <PageButton type='download' page={page} setPage={setPage} icon={<GetAppIcon/>}/>
                <PageButton type='about' page={page} setPage={setPage} icon={<InfoIcon/>}/>
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
