import React, { useState } from "react";
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import Dialog from '@material-ui/core/Dialog';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import red from '@material-ui/core/colors/red';
import { makeStyles } from '@material-ui/core/styles';

// add e to test very large search
const sampleSearch = `s M1A
nsp12 K603D
nsp3 N1810G
nsp10 I38A
nsp7 N69I
s 10
P0DTC3 133
P0DTC3 C133K
orf10 I4L`

const searchHelpText = `Search for SARS-CoV-2 variants:

Enter:
- Protein names (e.g. nsp1)
- Uniprot IDs (e.g. P0DTC7)
- Gene positions (e.g. nsp2 1)
- Specific variants (e.g. nsp12 K603D)
`

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
    const [newSearch, setNewSearch] = useState('')

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
                    placeholder={searchHelpText}
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
                    <Button onClick={() => setNewSearch(sampleSearch)}>
                        Load sample search
                    </Button>
                </Grid>
            ) : null}
        </Grid>
    )
}

export default MutSearch