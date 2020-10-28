import React from "react";
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import Dialog from '@material-ui/core/Dialog';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogContent from '@material-ui/core/DialogContent';
import ProteinViewer from './ProteinViewer'

const StructurePopup = ({mut, int, open, setOpen, width=900, height=700}) => {
    let template = ''
    let chain = ''
    let path = ''
    let int_chain = ''

    if (int){
        [template, chain, int_chain] = int['template'].split('.')
        path = [process.env.PUBLIC_URL, 'data/pdb_interface/', template, '.pdb'].join('')
    } else {
        [template, chain] = mut['template'].split('.')
        path = [process.env.PUBLIC_URL, 'data/pdb_foldx/', mut['uniprot'], '_',
                mut['name'], '/', template, '.pdb'].join('')
    }

    return(
        <Dialog open={open} onClose={() => setOpen(false)} scroll='body' fullWidth maxWidth='lg'>
            <DialogTitle>
                {int ? 'Interface Structure Model' : 'Structure Model'}
            </DialogTitle>
            <DialogContent>
                <Grid container justify='space-evenly' alignItems='center'>
                    <Grid item xs={12}>
                        <ProteinViewer
                          pdb_path={path}
                          position={mut['position']}
                          chain={chain}
                          int_chain={int_chain}
                          width={width}
                          height={height}
                        />
                    </Grid>
                    <Grid item>
                        <Typography display='inline' variant='h5' style={{color: '#e6180d'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Mutant</Typography>
                    </Grid>
                    <Grid item>
                        <Typography display='inline' variant='h5' style={{color: '#8cb2f2'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Mutated Protein</Typography>
                    </Grid>
                    {int ? (
                    <Grid item>
                        <Typography display='inline' variant='h5' style={{color: '#fa8ce6'}}>
                            &#9632;&nbsp;
                        </Typography>
                        <Typography display='inline'>Interface Protein</Typography>
                    </Grid>
                    ) : null}
                </Grid>
            </DialogContent>
        </Dialog>
    )
}

export default StructurePopup