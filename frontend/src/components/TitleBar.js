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
import { Link, useLocation } from "react-router-dom";
// import BarChartIcon from '@material-ui/icons/BarChart';
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

const buttons = [
    {name: 'search', path: '/', icon: <SearchIcon/>},
    // Don't necessarily need this section, but could include some overview plots of the data.
    // Likely they can just go in the paper
    //{type: 'analysis', icon: <BarChartIcon/>},
    {name: 'help', path: '/help', icon: <HelpOutlineIcon/>},
    {name: 'download', path: '/download', icon: <GetAppIcon/>},
    {name: 'about', path: '/about', icon: <InfoIcon/>}
]

const PageButton = ({text, path, icon}) => {
    const classes = styles(useTheme())
    const page = useLocation()

    return(
        <Button
          component={Link}
          to={path}
          className={page.pathname === path ? classes.selectedButton : classes.button}
          startIcon={icon}>
            {text}
        </Button>
    )
}

const PageList = ({text, path, icon, setDrawerOpen}) => {
    const classes = styles(useTheme())
    const page = useLocation()

    return(
        <ListItem
          button
          component={Link}
          to={path}
          onClick={() => {setDrawerOpen(false)}}
          className={page.pathname === path ? classes.selectedListButton : classes.listButton}>
            <ListItemIcon>{icon}</ListItemIcon>
            <ListItemText primary={text}/>
        </ListItem>
    )
}

const TitleBar = () => {
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
                                  text={i['name']}
                                  path={i['path']}
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
                          text={i['name']}
                          path={i['path']}
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
