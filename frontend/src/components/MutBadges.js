import React from "react";
import Avatar from '@material-ui/core/Avatar';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import { deepPurple, amber, lightBlue, green, red } from '@material-ui/core/colors';
import { makeStyles } from '@material-ui/core/styles';
import clsx from  'clsx';

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
                    <MutBadge type='conservation' small/>&nbsp; SIFT Score &lt; 0.05
                </Typography>
            </Grid>
            <Grid item>
                <Typography {...listTypoProps}>
                    <MutBadge type='structure' small/>&nbsp; |FoldX &Delta;&Delta;G| &gt; 1
                </Typography>
            </Grid>
            <Grid item>
                <Typography {...listTypoProps}>
                    <MutBadge type='ptm' small/>&nbsp; PTM Site
                </Typography>
            </Grid>
            <Grid item>
                <Typography {...listTypoProps}>
                    <MutBadge type='interface' small/>&nbsp; Protein Interface Site
                </Typography>
            </Grid>
            <Grid item>
                <Typography {...listTypoProps}>
                    <MutBadge type='frequency' small/>&nbsp; Observed Frequency &gt; 0.01
                </Typography>
            </Grid>
        </Grid>
    )
}

const MutBadges = ({mut}) => {
    const classes = styles()
    return(
        <div className={classes.badgeRoot}>
        {mut['sift_score'] < 0.05 ? (
            <MutBadge type='conservation'/>
        ) : null}
        {Math.abs(mut['total_energy']) > 1 ? (
            <MutBadge type='structure'/>
        ) : null}
        {mut['ptm'] !== '' ? (
            <MutBadge type='ptm'/>
        ) : null}
        {mut['int_name'] !== '' ? (
            <MutBadge type='interface'/>
        ) : null}
        {mut['freq'] > 0.01 ? (
            <MutBadge type='frequency'/>
        ) : null}
        </div>
    )
}

export default MutBadges