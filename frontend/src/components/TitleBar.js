import React from "react";
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';

const TitleBar = () => {
    return(
        <AppBar position='static'>
            <Toolbar>
                <Typography variant='h6'>
                    SARS-CoV2 Mutfunc
                </Typography>
            </Toolbar>
        </AppBar>
    )
}

export default TitleBar
