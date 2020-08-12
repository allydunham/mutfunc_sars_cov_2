import React, { useState } from "react";
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import DialogTitle from '@material-ui/core/DialogTitle';
import Dialog from '@material-ui/core/Dialog';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import Typography from '@material-ui/core/Typography';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import red from '@material-ui/core/colors/red';
import { makeStyles } from '@material-ui/core/styles';

// add e to test very large search
const defaultSearch = `s M1A
nsp12 K603D
nsp3 N1810G
nsp7 N69I
s 10
P0DTC3 133
P0DTC3 C133K
orf10 I4L`

const styles = makeStyles({
    root: {
        flexGrow: 1,
    },
    item: {
        width: "66%"
    },
    errorButton: {
        color: red[900]
    }
});

const ErrorDialog = ({errors}) => {
    const classes = styles()
    const [open, setOpen] = React.useState(false);

    return(
        <>
        <Button
          variant='outlined'
          className={classes.errorButton}
          onClick={() => setOpen(true)}>
            See details of unrecognised searches ({errors.length})
        </Button>
        <Dialog
            open={open}
            onClose={() => setOpen(false)}
        >
            <DialogTitle>Unrecognised Searches</DialogTitle>
            <DialogContent>
                <DialogContentText>
                    <List dense={true}>
                        {errors.map((e) => (
                            <ListItem key={e}>
                                <ListItemText
                                    primary={e}
                                    primaryTypographyProps={{variant:"body1"}}
                                />
                            </ListItem>
                        ))}
                    </List>
                </DialogContentText>
            </DialogContent>
        </Dialog>
        </>
    )
}

const MutSearch = ({ search, setSearch, errors, searching, setSearching }) => {
    const classes = styles();
    const [newSearch, setNewSearch] = useState(defaultSearch)

    const processSearch = (event) => {
        event.preventDefault();
        if (!searching && newSearch !== search){
            setSearch(newSearch);
            setSearching(true);
        }
    }

    return(
        <Grid container spacing={2} direction="column"
              alignItems="center" className={classes.root}>
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
            {errors.length > 0 ? (
                <Grid item className={classes.item}>
                    <ErrorDialog errors={errors}/>
                </Grid>
            ) : null}
            {search === false ? (
                <Grid item className={classes.item}>
                    <Typography variant='body1'>Search for SARS-CoV2 Variants</Typography>
                </Grid>
            ) : null}
        </Grid>
    )
}

export default MutSearch