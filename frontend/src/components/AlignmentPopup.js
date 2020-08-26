import React from "react";
import Grid from '@material-ui/core/Grid';
import Dialog from '@material-ui/core/Dialog';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogContent from '@material-ui/core/DialogContent';
import SiftAlignment from './SiftAlignment'

const AlignmentPopup = ({mut, open, setOpen, width=1000}) => {
    return(
        <Dialog open={open} onClose={() => setOpen(false)} scroll='body' fullWidth maxWidth='lg'>
            <DialogTitle>
                SIFT4G Alignment
            </DialogTitle>
            <DialogContent>
                <Grid container justify='center' alignItems='center'>
                    <Grid item xs={12}>
                        <SiftAlignment
                          gene={mut['uniprot'] + '_' + mut['name']}
                          width={width}
                        />
                    </Grid>
                </Grid>
            </DialogContent>
        </Dialog>
    )
}

export default AlignmentPopup