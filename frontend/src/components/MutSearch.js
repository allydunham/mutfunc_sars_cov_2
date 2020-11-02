import React, { useState } from "react";
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import Dialog from '@material-ui/core/Dialog';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import red from '@material-ui/core/colors/red';
import { makeStyles } from '@material-ui/core/styles';

// add e to test very large search
const sampleSearch = `s M1A
nsp12 K603D
nsp3 N1810G
nsp10 I38A
nsp10 V42A
nsp8 P116A
nsp7 N69I
s 10
P0DTC3 133
P0DTC3 C133K
orf10 I4L`

const searchHelpText = `Search for SARS-CoV-2 variants

Enter terms in the following formats, separated by newlines, commas (,) or semicolons (;):
- Protein names (e.g. nsp1)
- Uniprot IDs (e.g. P0DTC7)
- Protein positions (e.g. nsp2 1 or nsp2 A1)
- Specific variants (e.g. nsp12 K603D or nsp12 603D)
`

const styles = makeStyles((theme) => ({
    root: {
        flexGrow: 1
    },
    item: {
        [theme.breakpoints.down('sm')]: {
            width: "90%"
        },
        [theme.breakpoints.up('md')]: {
            width: "66%"
        }
    },
    errorButton: {
        color: red[900]
    }
}));

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
                    Unrecognised search terms:
                    <ul>
                        {errors.map((e) => (
                            <li key={e}>
                                {e}
                            </li>
                        ))}
                    </ul>

                    Searches of the following formats are supported:
                    <ul>
                        <li>Protein name (e.g. nsp1)</li>
                        <li>Uniprot ID can replace protein name when it unambiguously identifies the protein (e.g. P0DTC7 but not P0DTD1 as it is the orf1ab polyprotein)</li>
                        <li>Protein position (e.g. nsp2 1 or nsp2 A1, specifying the WT)</li>
                        <li>Specific variant (e.g. nsp12 K603D or nsp12 603D, without specifying the WT). Not specifying the WT is slightly slower to search.</li>
                    </ul>

                    Note: some syntatically valid searches yield no results too, for example if the position is not within the protein.
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
                    color="primary"
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