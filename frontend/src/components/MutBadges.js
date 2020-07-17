import React from "react";
import Avatar from '@material-ui/core/Avatar';
import { deepPurple, amber, lightBlue, green } from '@material-ui/core/colors';
import { makeStyles } from '@material-ui/core/styles';

const styles = makeStyles((theme) => ({
    badgeRoot: {
        display: 'flex',
        '& > *': {
            marginRight : theme.spacing(1),
        },
    },
    siftBadge: {
        color: theme.palette.getContrastText(green['A700']),
        backgroundColor: green['A700'],
        width: theme.spacing(4),
        height: theme.spacing(4)
    },
    foldxBadge: {
        color: theme.palette.getContrastText(deepPurple['A700']),
        backgroundColor: deepPurple['A700'],
        width: theme.spacing(4),
        height: theme.spacing(4)
    },
    ptmBadge: {
        color: theme.palette.getContrastText(lightBlue['A700']),
        backgroundColor: lightBlue['A700'],
        width: theme.spacing(4),
        height: theme.spacing(4)
    },
    interfaceBadge: {
        color: theme.palette.getContrastText(amber['A700']),
        backgroundColor: amber['A700'],
        width: theme.spacing(4),
        height: theme.spacing(4)
    },
}));

const MutBadges = ({mut}) => {
    const classes = styles()
    return(
        <div className={classes.badgeRoot}>
        {mut['sift_score'] < 0.05 ? (
            <Avatar className={classes.siftBadge}>C</Avatar>
        ) : null}
        {Math.abs(mut['total_energy']) > 1 ? (
            <Avatar className={classes.foldxBadge}>S</Avatar>
        ) : null}
        {mut['ptm'] !== '' ? (
            <Avatar className={classes.ptmBadge}>P</Avatar>
        ) : null}
        {mut['int_name'] !== '' ? (
            <Avatar className={classes.interfaceBadge}>I</Avatar>
        ) : null}
        </div>
    )
}

export default MutBadges