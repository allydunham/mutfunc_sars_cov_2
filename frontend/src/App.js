import React, { useState } from 'react';
import About from './components/About';
import Download from './components/Download';
import DataController from './components/DataController';
import TitleBar from './components/TitleBar';
import { ThemeProvider } from "@material-ui/styles";
import theme from './theme';

function App() {
    const [page, setPage] = useState('search')

    return (
        <ThemeProvider theme={theme}>
            <TitleBar setPage={setPage}/>
            {page === 'about'? <About/> : null}
            {page === 'download'? <Download/> : null}
            <DataController hidden={page !== 'search'}/>
        </ThemeProvider>
  );
}

export default App;
