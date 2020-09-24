import React from "react";
import Avatar from '@material-ui/core/Avatar';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import { deepPurple, amber, lightBlue, green, red } from '@material-ui/core/colors';
import { makeStyles } from '@material-ui/core/styles';
import clsx from  'clsx';
import * as deleterious from '../lib/deleterious';

const styles = makeStyles((theme) => ({
    badgeRoot: {
        display: 'flex',
        '& > *': {
            marginRight : theme.spacing(1),
        },
    },
    conservationBadge: {
        color: theme.palette.getContrastText(green['A700']),
        backgroundColor: green['A700']
    },
    conservationWeakBadge: {
        color: theme.palette.getContrastText(green['A100']),
        backgroundColor: green['A100']
    },
    structureBadge: {
        color: theme.palette.getContrastText(deepPurple['A700']),
        backgroundColor: deepPurple['A700']
    },
    ptmBadge: {
        color: theme.palette.getContrastText(lightBlue['A700']),
        backgroundColor: lightBlue['A700']
    },
    interfacesBadge: {
        color: theme.palette.getContrastText(amber['A700']),
        backgroundColor: amber['A700']
    },
    frequencyBadge: {
        color: theme.palette.getContrastText(red['A700']),
        backgroundColor: red['A700']
    },
    large: {
        width: theme.spacing(4),
        height: theme.spacing(4)
    },
    small: {
        width: theme.spacing(2),
        height: theme.spacing(2),
        fontSize: 'small'
    },
    badgeKey: {
        display: 'flex',
        alignItems: 'center',
        margin: 'auto'
    }
}));

const badgeLetters = {
    'conservation': 'C',
    'conservationWeak': 'C',
    'structure': 'S',
    'ptm': 'P',
    'interfaces': 'I',
    'frequency': 'F',
}

export const MutBadge = ({type, small}) => {
    const classes = styles()
    return(
        <Avatar className={clsx(classes[type + 'Badge'],
                                small ? classes.small : classes.large)}>
            {badgeLetters[type]}
        </Avatar>
    )
}

export const LabeledMutBadge = ({type, small, variant='body1'}) => {
    const classes = styles()
    return(
        <Typography variant={variant} display='inline' className={classes.badgeKey}>
            <MutBadge type={type} small={small}/>&nbsp; {deleterious[type + 'Text']}
        </Typography>
    )
}

export const BadgeKey = ({column}) => {
    return(
        <Grid container spacing={2} justify='center' direction={column ? 'column' : 'row'}>
            <Grid item>
                <LabeledMutBadge type='conservation' small variant='caption'/>
            </Grid>
            <Grid item>
                <LabeledMutBadge type='conservationWeak' small variant='caption'/>
            </Grid>
            <Grid item>
                <LabeledMutBadge type='structure' small variant='caption'/>
            </Grid>
            <Grid item>
                <LabeledMutBadge type='ptm' small variant='caption'/>
            </Grid>
            <Grid item>
                <LabeledMutBadge type='interfaces' small variant='caption'/>
            </Grid>
            <Grid item>
                <LabeledMutBadge type='frequency' small variant='caption'/>
            </Grid>
        </Grid>
    )
}

const MutBadges = ({mut}) => {
    const classes = styles()
    return(
        <div className={classes.badgeRoot}>
        {deleterious.conservation(mut) ? (
            <MutBadge type='conservation'/>
        ) : (deleterious.conservationWeak(mut) ? (
            <MutBadge type='conservationWeak'/>
        ) : null)}
        {deleterious.structure(mut) ? (
            <MutBadge type='structure'/>
        ) : null}
        {deleterious.ptm(mut) ? (
            <MutBadge type='ptm'/>
        ) : null}
        {deleterious.interfaces(mut) ? (
            <MutBadge type='interfaces'/>
        ) : null}
        {deleterious.frequency(mut) ? (
            <MutBadge type='frequency'/>
        ) : null}
        </div>
    )
}

export default MutBadges