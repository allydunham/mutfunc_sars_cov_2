import React from 'react';
import About from './components/About';
import Download from './components/Download';
import Help from './components/Help';
import Changelog from './components/Changelog';
import DataController from './components/DataController';
import TitleBar from './components/TitleBar';
import Footer from './components/Footer';
import { BrowserRouter as Router, Switch, Route, useLocation } from "react-router-dom";
import { ThemeProvider } from "@material-ui/styles";
import { makeStyles } from '@material-ui/core/styles';
import theme from './theme';

const styles = makeStyles({
    main: {
        display: 'flex',
        minHeight: '87vh',
        flexDirection: 'column',
        flex: 1,
        overflow: 'hidden'
    }
});

function InnerApp() {
    const classes = styles()
    const page = useLocation()

    return(
        <>
        <TitleBar/>
        <div className={classes.main}>
            <Switch>
                <Route path="/help">
                    <Help/>
                </Route>
                <Route path="/about">
                    <About/>
                </Route>
                <Route path="/download">
                    <Download/>
                </Route>
                <Route path="/changelog">
                    <Changelog/>
                </Route>
            </Switch>
            <DataController hidden={page.pathname !== '/'}/>
        </div>
        <Footer/>
        </>
    )
}

function App() {
    return (
        <ThemeProvider theme={theme}>
            <Router>
                <InnerApp/>
            </Router>
        </ThemeProvider>
  );
}

export default App;
