import React, { useState } from "react";
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Drawer from '@material-ui/core/Drawer';
import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import Button from '@material-ui/core/Button';
import IconButton from '@material-ui/core/IconButton';
import MenuIcon from '@material-ui/icons/Menu';
import GetAppIcon from '@material-ui/icons/GetApp';
import GitHubIcon from '@material-ui/icons/GitHub';
import SearchIcon from '@material-ui/icons/Search';
import InfoIcon from '@material-ui/icons/Info';
import HelpOutlineIcon from '@material-ui/icons/HelpOutline';
import BarChartIcon from '@material-ui/icons/BarChart';
import { makeStyles, useTheme } from '@material-ui/core/styles';
import useMediaQuery from '@material-ui/core/useMediaQuery';

const styles = makeStyles((theme) => ({
    logo: {
        marginRight: '10px',
        width: 'auto',
        maxWidth: '50%',
        height: '3vh'
    },
    separater: {
        flexGrow: 1
    },
    button: {
        color: theme.palette.secondary.contrastText,
        textTransform: 'capitalize'
    },
    selectedButton: {
        color: theme.palette.primary.main,
        textTransform: 'capitalize'
    },
    listButton: {
        color: theme.palette.secondary.contrastText,
        textTransform: 'capitalize'
    },
    selectedListButton: {
        color: theme.palette.primary.main,
        textTransform: 'capitalize'
    }
}));

const PageButton = ({type, page, setPage, icon}) => {
    const classes = styles(useTheme())
    return(
        <Button
          className={page === type ? classes.selectedButton : classes.button}
          onClick={() => setPage(type)}
          startIcon={icon}>
            {type}
        </Button>
    )
}

const PageList = ({type, page, setPage, setDrawerOpen, icon}) => {
    const classes = styles(useTheme())
    return(
        <ListItem
          button={true}
          onClick={() => {setPage(type); setDrawerOpen(false)}}
          className={page === type ? classes.selectedListButton : classes.listButton}>
            <ListItemIcon>{icon}</ListItemIcon>
            <ListItemText primary={type}/>
        </ListItem>
    )
}

const buttons = [
    {type: 'search', icon: <SearchIcon/>},
    {type: 'analysis', icon: <BarChartIcon/>},
    {type: 'help', icon: <HelpOutlineIcon/>},
    {type: 'download', icon: <GetAppIcon/>},
    {type: 'about', icon: <InfoIcon/>}
]

const TitleBar = ({page, setPage}) => {
    const theme = useTheme();
    const classes = styles(theme);
    const small = useMediaQuery(theme.breakpoints.down('sm'));
    const [drawerOpen, setDrawerOpen] = useState(false)

    return(
        <AppBar position='sticky' elevation={0} color='secondary'>
            <Toolbar>
                <img
                    src={process.env.PUBLIC_URL + 'images/mutfunc_logo.svg'}
                    alt='mutfunc-logo'
                    className={classes.logo}
                />
                <div className={classes.separater}/>
                {small ? (
                    <>
                    <IconButton onClick={() => setDrawerOpen(true)}><MenuIcon/></IconButton>
                    <Drawer anchor='right' open={drawerOpen} onClose={() => setDrawerOpen(false)}>
                        <List>
                            {buttons.map((i, index) => (
                                <PageList
                                  key={index}
                                  type={i['type']}
                                  page={page}
                                  setPage={setPage}
                                  setDrawerOpen={setDrawerOpen}
                                  icon={i['icon']}
                                />
                                ))}
                            <Divider/>
                            <ListItem
                              className={classes.listButton}
                              button={true}
                              href='https://github.com/allydunham/covid19_mutfunc'
                              target="_blank"
                              rel="noopener noreferrer">
                                <ListItemIcon><GitHubIcon/></ListItemIcon>
                                <ListItemText primary='Source'/>
                            </ListItem>
                        </List>
                    </Drawer>
                    </>
                ) : (
                    <>
                    {buttons.map((i, index) => (
                        <PageButton
                          key={index}
                          type={i['type']}
                          page={page}
                          setPage={setPage}
                          icon={i['icon']}
                        />
                    ))}
                    <Button
                      className={classes.button}
                      href='https://github.com/allydunham/covid19_mutfunc'
                      target="_blank"
                      rel="noopener noreferrer"
                      startIcon={<GitHubIcon/>}>
                        Source
                    </Button>
                    </>
                )}
            </Toolbar>
        </AppBar>
    )
}

export default TitleBar
