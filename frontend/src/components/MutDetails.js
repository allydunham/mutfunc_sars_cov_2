import React, { useState, useEffect } from "react";
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import Tabs from '@material-ui/core/Tabs';
import Tab from '@material-ui/core/Tab';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import Button from '@material-ui/core/Button';
import { makeStyles } from '@material-ui/core/styles';

import ProteinViewer from './ProteinViewer'
import SiftAlignment from './SiftAlignment'
import GenomeViewer from './GenomeViewer'
import MutBadges from './MutBadges'

const styles = makeStyles((theme) => ({
    root: {
        flexGrow: 1
    },
    title: {
        display: 'flex',
        paddingLeft: theme.spacing(1),
        paddingTop: theme.spacing(1),
        paddingRight: theme.spacing(0),
        paddingBottom: theme.spacing(0)
    }

}));

const getInterfaceNumString = (change) => {
    switch (Math.sign(change)){
        case 0:
            return('No change in interface residues')
        case 1:
            return(change + ' interface residues gained')
        case -1:
            return(Math.abs(change) + ' interface residues lost')
        default:
            return('Unknown interface residue count change')
    }
}

const MutStructure = ({mut}) => {
    const [tab, setTab] = useState(0);
    const [fx_template, fx_chain] = mut['template'].split('.')
    const [int_template, int_chain, int_interactor_chain] = mut['int_template'].split('.')

    useEffect(() => {
        let startTab = 0
        if (!isNaN(mut['sift_score']) && mut['sift_score'] < 0.05){
            startTab = 0
        } else if (fx_template !== '' || Math.abs(mut['total_energy']) > 1) {
            startTab = 1
        } else if (int_template !== '') {
            startTab = 2
        }
        setTab(startTab)
    }, [mut, fx_template, int_template])

    const foldx_path = [process.env.PUBLIC_URL, 'data/pdb_foldx/', mut['uniprot'],
                        '_', mut['name'], '/', fx_template, '.pdb'].join('')
    const int_path = [process.env.PUBLIC_URL, 'data/pdb_interface/',
                      int_template, '.pdb'].join('')

    const rootStyle = {width: 1200, display: 'flex', marginLeft: 'auto',
                       marginRight: 'auto', flexDirection: 'column',
                       justifyContent: 'center'}

    return(
        <div style={{width: '100%', margin: 5}}>
            <div style={rootStyle}>
                <Tabs value={tab} onChange={(event, i) => setTab(i)}>
                    <Tab label="SIFT4G" disabled={isNaN(mut['sift_score'])}/>
                    <Tab label="FoldX" disabled={fx_template === ''}/>
                    <Tab label="Interface" disabled={int_template === ''}/>
                </Tabs>
                <SiftAlignment
                  gene={mut['uniprot'] + '_' + mut['name']}
                  hidden={tab !== 0}
                  width={1000}
                />
                <ProteinViewer
                    hidden={tab !== 1}
                    pdb_path={fx_template !== '' ? foldx_path : ''}
                    position={mut['position']}
                    chain={fx_chain}
                    width={1200}
                    height={900}
                />
                <ProteinViewer
                    hidden={tab !== 2}
                    pdb_path={int_template !== '' ? int_path : ''}
                    position={mut['position']}
                    chain={int_chain}
                    int_chain={int_interactor_chain}
                    width={1200}
                    height={900}
                    />
                <Grid container justify='space-around' alignItems='center'>
                    <Grid hidden={tab === 0} item>
                        <Typography display='inline' variant='h5' style={{color: '#e6180d'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Mutant</Typography>
                    </Grid>
                    <Grid hidden={tab === 0} item>
                        <Typography display='inline' variant='h5' style={{color: '#8cb2f2'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Mutated Protein</Typography>
                    </Grid>
                    <Grid hidden={tab === 0} item>
                        <Typography display='inline' variant='h5' style={{color: '#fa8ce6'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Interface Protein</Typography>
                    </Grid>
                </Grid>
            </div>
        </div>
    )
}

const MutDetails = ({mut}) => {
   const classes = styles()

    if (mut == null){
        return(
            <Paper className={classes.root} variant="outlined" elevation={3}>
                <Typography align='center'>Click a result to view details</Typography>
            </Paper>
        )
    }

    const mut_text = [mut['uniprot'], ' ', mut['name'], ' ', mut['wt'],
                      mut['position'], mut['mut']].join('')

    return(
        <Paper variant="outlined" elevation={2} className={classes.root}>
            <Grid
              container
              spacing={1}
              direction='row'
              justify="space-around"
              alignItems="stretch"
            >
                <Grid item xs={12}>
                    <Typography align='left' variant='h6' className={classes.title}>
                        {mut_text}
                        &nbsp;
                        <MutBadges mut={mut}/>
                    </Typography>
                </Grid>
                <Grid item xs={12} className={classes.root}>
                    <GenomeViewer geneName={mut['name']} mutPosition={mut['position']}/>
                </Grid>
                <Grid item xs={3}>
                    <List>
                        <ListItemText
                          primary='Conservation'
                          primaryTypographyProps={{variant: 'h6'}}
                        />
                        <ListItemText>
                            Frequency: {isNaN(mut['freq']) ? 'Not Observed': mut['freq']}
                        </ListItemText>
                        <ListItemText>
                            SIFT Score: {isNaN(mut['sift_score']) ? 'NA': mut['sift_score']}
                        </ListItemText>
                        <ListItem>
                            <Button variant='contained'>View SIFT4G alignment</Button>
                        </ListItem>
                    </List>
                </Grid>
                <Grid item xs={3}>
                    <List>
                        <ListItemText
                          primary='Structure'
                          primaryTypographyProps={{variant: 'h6'}}
                        />
                        <ListItemText>
                            FoldX &Delta;&Delta;G: {isNaN(mut['total_energy']) ? 'NA': mut['total_energy']}
                        </ListItemText>
                        <ListItemText>
                            Template: {mut['template'] === '' ? 'None': mut['template']}
                        </ListItemText>
                        <ListItem>
                            <Button variant='contained'>View Structure</Button>
                        </ListItem>
                    </List>
                </Grid>
                <Grid item xs={3}>
                    <List>
                        <ListItemText
                          primary='PTMs'
                          primaryTypographyProps={{variant: 'h6'}}
                        />
                        <ListItemText>
                            {mut['ptm'] === "" ? 'None' : mut['ptm']}
                        </ListItemText>
                    </List>
                </Grid>
                <Grid item xs={3}>
                    <List>
                        <ListItemText
                          primary='Interfaces'
                          primaryTypographyProps={{variant: 'h6'}}
                        />
                        <ListItemText>
                            Interface: {mut['int_name'] === '' ? 'None' : mut['uniprot'] + ' ' + mut['name'] + ' - ' + mut['int_uniprot'] + ' ' +mut['int_name']}
                        </ListItemText>
                        <ListItemText>
                            Interface &Delta;&Delta;G: {isNaN(mut['diff_interaction_energy']) ? 'NA': mut['diff_interaction_energy']}
                        </ListItemText>
                        <ListItemText>
                            {getInterfaceNumString(mut['diff_interface_residues'])}
                        </ListItemText>
                        <ListItemText>
                            Template: {mut['int_template'] === '' ? 'None': mut['int_template']}
                        </ListItemText>
                        <ListItem>
                            <Button variant='contained'>View Structure</Button>
                        </ListItem>
                    </List>
                </Grid>
                <Grid item xs={12}>
                    <MutStructure mut={mut}/>
                </Grid>
            </Grid>
        </Paper>
    )
}

export default MutDetails