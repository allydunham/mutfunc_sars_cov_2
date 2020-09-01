import React, { useState } from 'react';
import About from './components/About';
import Analysis from './components/Analysis';
import Download from './components/Download';
import Help from './components/Help';
import DataController from './components/DataController';
import TitleBar from './components/TitleBar';
import Footer from './components/Footer';
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

function App() {
    const classes = styles()
    const [page, setPage] = useState('search')

    return (
        <ThemeProvider theme={theme}>
            <TitleBar page={page} setPage={setPage}/>
            <div className={classes.main}>
                {page === 'analysis'? <Analysis/> : null}
                {page === 'help'? <Help/> : null}
                {page === 'about'? <About/> : null}
                {page === 'download'? <Download/> : null}
                <DataController hidden={page !== 'search'}/>
            </div>
            <Footer/>
        </ThemeProvider>
  );
}

export default App;
