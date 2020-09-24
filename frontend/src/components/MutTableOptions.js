import React, { useState } from "react";
import Button from "@material-ui/core/Button";
import SettingsIcon from '@material-ui/icons/Settings';
import Dialog from '@material-ui/core/Dialog';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogContent from '@material-ui/core/DialogContent';
import Checkbox from '@material-ui/core/Checkbox';
import FormControl from '@material-ui/core/FormControl';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import FormGroup from '@material-ui/core/FormGroup';
import FormLabel from '@material-ui/core/FormLabel';
import { makeStyles } from '@material-ui/core/styles';
import { LabeledMutBadge } from './MutBadges';

const styles = makeStyles((theme) => ({
    tableControls: {
        display: 'flex',
        flex: 1,
        justifyContent: 'flex-end',
        alignItems: 'center',
        width: '100%'
    },
    tableControlButton:{
        textTransform: 'none'
    },
    tableControlGroup:{
        paddingBottom: '10px'
    },
    tablePaper: {
        display: 'flex',
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        width: '100%'
    },
    pageButton: {
        flexShrink: 0
    }
}));

const MutTableOptions = ({options, setOptions}) => {
    const classes = styles()
    const [open, setOpen] = useState(false)

    const updateOptions = (opt, event) => {
        let newOpt = {...options}
        newOpt[opt] = event.target.checked
        setOptions(newOpt)
    }

    return(
        <>
        <Button
          startIcon={<SettingsIcon/>}
          onClick={() => setOpen(true)}
          size='small'
          className={classes.tableControlButton}>
            Table Options
        </Button>
        <Dialog open={open} onClose={() => setOpen(false)} scroll='body' fullWidth maxWidth='sm'>
            <DialogTitle>
                Table Options
            </DialogTitle>
            <DialogContent>
                <FormControl fullWidth>
                    <FormLabel component="legend">General Filters</FormLabel>
                    <FormGroup className={classes.tableControlGroup}>
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['observed']}
                                       onChange={(event) => updateOptions('observed', event)}
                                       color='primary'
                                    />}
                            label="Only show observed variants"
                        />
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['viewAll']}
                                       onChange={(event) => updateOptions('viewAll', event)}
                                       color='primary'
                                    />}
                            label="Show variants without predicted effects"
                        />
                    </FormGroup>

                    <FormLabel component="legend">Options</FormLabel>
                    <FormGroup className={classes.tableControlGroup}>
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['strictSift']}
                                       onChange={(event) => updateOptions('strictSift', event)}
                                       color='primary'
                                    />}
                            label="Only show SIFT4G "
                        />
                    </FormGroup>

                    <FormLabel component="legend">Show variants with at least one of:</FormLabel>
                    <FormGroup className={classes.tableControlGroup}>
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                      checked={options['frequency']}
                                      disabled={options['viewAll']}
                                      onChange={(event) => updateOptions('frequency', event)}
                                      color='primary'
                                    />}
                            label={<LabeledMutBadge small type='frequency' variant='body2'/>}
                        />
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['conservation']}
                                       disabled={options['viewAll']}
                                       onChange={(event) => updateOptions('conservation', event)}
                                       color='primary'
                                    />}
                            label={<LabeledMutBadge small type='conservation' variant='body2'/>}
                        />
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['conservationWeak']}
                                       disabled={options['viewAll']}
                                       onChange={(event) => updateOptions('conservationWeak', event)}
                                       color='primary'
                                    />}
                            label={<LabeledMutBadge small type='conservationWeak' variant='body2'/>}
                        />
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['structure']}
                                       disabled={options['viewAll']}
                                       onChange={(event) => updateOptions('structure', event)}
                                       color='primary'
                                    />}
                            label={<LabeledMutBadge small type='structure' variant='body2'/>}
                        />
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['ptm']}
                                       disabled={options['viewAll']}
                                       onChange={(event) => updateOptions('ptm', event)}
                                       color='primary'
                                    />}
                            label={<LabeledMutBadge small type='ptm' variant='body2'/>}
                        />
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['interfaces']}
                                       disabled={options['viewAll']}
                                       onChange={(event) => updateOptions('interfaces', event)}
                                       color='primary'
                                    />}
                            label={<LabeledMutBadge small type='interfaces' variant='body2'/>}
                        />
                    </FormGroup>
                </FormControl>
            </DialogContent>
        </Dialog>
        </>
    )
}

export default MutTableOptions