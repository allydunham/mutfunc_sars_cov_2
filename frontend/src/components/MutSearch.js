import React, { useState } from "react";
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';

const defaultSearch = `s M1A
nsp12 K603D
nsp3 N1810G
nsp7 N69I
nsp10
s 10
P0DTD1
P0DTC3
P0DTC3 133
P0DTC3 C133K`

const styles = makeStyles({
    root: {
        flexGrow: 1,
    },
    item: {
        width: "66%"
    }
});

const MutSearch = ({ setSearch, setSearching }) => {
    const classes = styles()
    const [newSearch, setNewSearch] = useState(defaultSearch)
    const [oldSearch, setOldSearch] = useState("")

    const processSearch = (event) => {
        event.preventDefault();
        if (newSearch !== oldSearch){
            setSearch(newSearch);
            setSearching(true);
            setOldSearch(newSearch)
        }
    }

    return(
        <Grid container direction="column" alignItems="center" className={classes.root}>
            <Grid item className={classes.item}>
                <TextField
                    value={newSearch}
                    onChange={(e) => setNewSearch(e.target.value)}
                    variant="outlined"
                    multiline
                    margin="normal"
                    rows={8}
                    fullWidth
                />
            </Grid>
            <Grid item className={classes.item}>
                <Button
                    onClick={processSearch}
                    variant="contained"
                    color="secondary"
                    fullWidth>
                    Search
                </Button>
            </Grid>
        </Grid>
    )
}

export default MutSearch