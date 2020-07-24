import React, { useState } from "react";
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import Accordion from '@material-ui/core/Accordion';
import AccordionSummary from '@material-ui/core/AccordionSummary';
import AccordionDetails from '@material-ui/core/AccordionDetails';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import Typography from '@material-ui/core/Typography';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import { red } from '@material-ui/core/colors';
import { makeStyles } from '@material-ui/core/styles';

// add e to test very large search
const defaultSearch = `s M1A
nsp12 K603D
nsp3 N1810G
nsp7 N69I
s 10
P0DTD1 133
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
    errorAccordion: {
        backgroundColor: red[100],
        margin: '10px'
    }
});

const ErrorAccordion = ({errors}) => {
    const classes = styles();
    return(
        <Accordion className={classes.errorAccordion}>
            <AccordionSummary expandIcon={<ExpandMoreIcon />}>
                <Typography variant='body1' color="error">Search Errors</Typography>
            </AccordionSummary>
            <AccordionDetails>
                <List dense={true}>
                    {errors.map((e) => (
                        <ListItem key={e}>
                            <ListItemText
                                primary={e}
                                primaryTypographyProps={{variant:"body1", color:"error"}}
                            />
                        </ListItem>
                    ))}
                </List>

            </AccordionDetails>
        </Accordion>
    )
}

const MutSearch = ({ search, setSearch, errors, searching, setSearching }) => {
    const classes = styles();
    const [newSearch, setNewSearch] = useState(defaultSearch)

    //
    const processSearch = (event) => {
        event.preventDefault();
        if (!searching && newSearch !== search){
            setSearch(newSearch);
            setSearching(true);
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
            {errors.length > 0 ? (
                <Grid item className={classes.item}>
                    <ErrorAccordion errors={errors}/>
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