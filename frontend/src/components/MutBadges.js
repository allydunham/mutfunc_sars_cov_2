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
    structureBadge: {
        color: theme.palette.getContrastText(deepPurple['A700']),
        backgroundColor: deepPurple['A700']
    },
    ptmBadge: {
        color: theme.palette.getContrastText(lightBlue['A700']),
        backgroundColor: lightBlue['A700']
    },
    interfaceBadge: {
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
    'structure': 'S',
    'ptm': 'P',
    'interface': 'I',
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

export const BadgeKey = () => {
    const classes = styles()
    const listTypoProps = {variant:'caption', display:'inline', className: classes.badgeKey}
    return(
        <Grid container spacing={2}>
            <Grid item>
                <Typography {...listTypoProps}>
                    <MutBadge type='conservation' small/>&nbsp; {deleterious.conservationText}
                </Typography>
            </Grid>
            <Grid item>
                <Typography {...listTypoProps}>
                    <MutBadge type='structure' small/>&nbsp; {deleterious.structureText}
                </Typography>
            </Grid>
            <Grid item>
                <Typography {...listTypoProps}>
                    <MutBadge type='ptm' small/>&nbsp; {deleterious.ptmText}
                </Typography>
            </Grid>
            <Grid item>
                <Typography {...listTypoProps}>
                    <MutBadge type='interface' small/>&nbsp; {deleterious.interfacesText}
                </Typography>
            </Grid>
            <Grid item>
                <Typography {...listTypoProps}>
                    <MutBadge type='frequency' small/>&nbsp; {deleterious.frequencyText}
                </Typography>
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
        ) : null}
        {deleterious.structure(mut) ? (
            <MutBadge type='structure'/>
        ) : null}
        {deleterious.ptm(mut) ? (
            <MutBadge type='ptm'/>
        ) : null}
        {deleterious.interfaces(mut) ? (
            <MutBadge type='interface'/>
        ) : null}
        {deleterious.frequency(mut) ? (
            <MutBadge type='frequency'/>
        ) : null}
        </div>
    )
}

export default MutBadges