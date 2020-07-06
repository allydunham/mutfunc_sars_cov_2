import React from 'react';
import DataController from './components/DataController';
import TitleBar from './components/TitleBar'
import { ThemeProvider } from "@material-ui/styles";
import theme from './theme'

function App() {
    return (
        <ThemeProvider theme={theme}>
            <TitleBar/>
            <DataController/>
        </ThemeProvider>
  );
}

export default App;
