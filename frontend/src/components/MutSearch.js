import React, { useState } from "react";
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles({
    root: {
        flexGrow: 1,
    },
    item: {
        width: "50%"
    }
});

const MutSearch = ({ setSearch, data}) => {
    const classes = styles()
    const [newSearch, setNewSearch] = useState('')

    const processSearch = (event) => {
        event.preventDefault();
        const search = newSearch.split(/[\n,]+/);
        setSearch(search);
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