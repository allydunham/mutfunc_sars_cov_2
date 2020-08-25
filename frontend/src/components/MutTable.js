import React, { useState, useEffect } from "react";
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import TablePagination from '@material-ui/core/TablePagination';
import Button from "@material-ui/core/Button";
import IconButton from '@material-ui/core/IconButton';
import FirstPageIcon from '@material-ui/icons/FirstPage';
import KeyboardArrowLeft from '@material-ui/icons/KeyboardArrowLeft';
import KeyboardArrowRight from '@material-ui/icons/KeyboardArrowRight';
import LastPageIcon from '@material-ui/icons/LastPage';
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
import MutBadges, { BadgeKey, LabeledMutBadge } from './MutBadges';
import { sarsDisplayNames } from '../lib/sars'
import * as deleterious from '../lib/deleterious';

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

const TableOptions = ({options, setOptions}) => {
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
          endIcon={<SettingsIcon/>}
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
                                    />}
                            label="Only show observed variants"
                        />
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['viewAll']}
                                       onChange={(event) => updateOptions('viewAll', event)}
                                    />}
                            label="Show variants without predicted effects"
                        />
                    </FormGroup>

                    <FormLabel component="legend">Only show variants with at least one of:</FormLabel>
                    <FormGroup className={classes.tableControlGroup}>
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                      checked={options['frequency']}
                                      disabled={options['viewAll']}
                                      onChange={(event) => updateOptions('frequency', event)}
                                    />}
                            label={<LabeledMutBadge type='frequency' variant='body2'/>}
                        />
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['conservation']}
                                       disabled={options['viewAll']}
                                       onChange={(event) => updateOptions('conservation', event)}
                                    />}
                            label={<LabeledMutBadge type='conservation' variant='body2'/>}
                        />
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['structure']}
                                       disabled={options['viewAll']}
                                       onChange={(event) => updateOptions('structure', event)}
                                    />}
                            label={<LabeledMutBadge type='structure' variant='body2'/>}
                        />
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['ptm']}
                                       disabled={options['viewAll']}
                                       onChange={(event) => updateOptions('ptm', event)}
                                    />}
                            label={<LabeledMutBadge type='ptm' variant='body2'/>}
                        />
                        <FormControlLabel
                            labelPlacement='end'
                            control={<Checkbox
                                       checked={options['interfaces']}
                                       disabled={options['viewAll']}
                                       onChange={(event) => updateOptions('interfaces', event)}
                                    />}
                            label={<LabeledMutBadge type='interfaces' variant='body2'/>}
                        />
                    </FormGroup>


                </FormControl>
            </DialogContent>
        </Dialog>
        </>
    )
}

const TablePaginationActions = ({count, page, rowsPerPage, onChangePage}) => {
    const classes = styles();

    const handleFirstPageButtonClick = (event) => {
        onChangePage(event, 0);
    };

    const handleBackButtonClick = (event) => {
        onChangePage(event, page - 1);
    };

    const handleNextButtonClick = (event) => {
        onChangePage(event, page + 1);
    };

    const handleLastPageButtonClick = (event) => {
        onChangePage(event, Math.max(0, Math.ceil(count / rowsPerPage) - 1));
    };

    return (
        <div className={classes.pageButton}>
            <IconButton
                onClick={handleFirstPageButtonClick}
                disabled={page === 0}
            >
                <FirstPageIcon/>
            </IconButton>
            <IconButton onClick={handleBackButtonClick} disabled={page === 0}>
                <KeyboardArrowLeft />
            </IconButton>
            <IconButton
                onClick={handleNextButtonClick}
                disabled={page >= Math.ceil(count / rowsPerPage) - 1}
            >
                <KeyboardArrowRight />
            </IconButton>
            <IconButton
                onClick={handleLastPageButtonClick}
                disabled={page >= Math.ceil(count / rowsPerPage) - 1}
            >
                <LastPageIcon/>
            </IconButton>
        </div>
    );
  }

const EmptyRow = () => {
    return(
        <TableRow key='noData'>
            <TableCell colSpan={6} align='center'>No Results</TableCell>
        </TableRow>
    )
}

const MutRow = ({mutId, mutData, setSelectedMut}) => {
    const mut = mutData[mutId]
    return(
        <TableRow hover onClick={(event) => setSelectedMut(mutId)}>
            <TableCell>{mut['uniprot']}</TableCell>
            <TableCell>{sarsDisplayNames[mut['name']]}</TableCell>
            <TableCell>{mut['position']}</TableCell>
            <TableCell>{mut['wt']}</TableCell>
            <TableCell>{mut['mut']}</TableCell>
            <TableCell><MutBadges mut={mut}/></TableCell>
        </TableRow>
    )
}

const MutTable = ({ mutIds, mutData, setSelectedMut}) => {
    const classes = styles()
    const tableHeaders = ['Uniprot ID', 'Protein', 'Position', 'WT', 'Mutant', 'Predictions']

    const [options, setOptions] = useState({
        observed: false,
        viewAll: false,
        frequency: true,
        conservation: true,
        structure: true,
        ptm: true,
        interfaces: true
    })
    const [filteredIds, setFilteredIds] = useState([])
    const [page, setPage] = React.useState(0);
    const [rowsPerPage, setRowsPerPage] = React.useState(50);

    console.log(options)

    useEffect(() => {
        console.log('Filtering...')
        setFilteredIds(mutIds.filter((i) => {
            const mut = mutData[i]
            if (options['observed'] && isNaN(mut['freq'])){
                return false
            }

            if (options['viewAll']){
                return true
            }

            if (options['frequency'] && deleterious.frequency(mut)){
                return true
            }

            if (options['conservation'] && deleterious.conservation(mut)){
                return true
            }

            if (options['structure'] && deleterious.structure(mut)){
                return true
            }

            if (options['ptm'] && deleterious.ptm(mut)){
                return true
            }

            if (options['interfaces'] && deleterious.interfaces(mut)){
                return true
            }

            return false
        }))
    }, [mutIds, options, mutData])

    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };

    const handleChangeRowsPerPage = (event) => {
        setRowsPerPage(parseInt(event.target.value, 10));
        setPage(0);
    };

    return(
        <>
        <div className={classes.tableControls}>
            <TableOptions
                options={options}
                setOptions={setOptions}
            />
        </div>
        <div className={classes.tablePaper}>
            <TableContainer>
                <Table>
                    <TableHead>
                        <TableRow>
                            <TableCell colSpan={3}>
                                <BadgeKey/>
                            </TableCell>
                            <TablePagination
                            rowsPerPageOptions={[10, 25, 50, 100]}
                            colSpan={3}
                            count={filteredIds.length}
                            rowsPerPage={rowsPerPage}
                            page={page}
                            onChangePage={handleChangePage}
                            onChangeRowsPerPage={handleChangeRowsPerPage}
                            ActionsComponent={TablePaginationActions}
                            />
                        </TableRow>
                        <TableRow key='header'>
                            {tableHeaders.map((i) => <TableCell key={i}>{i}</TableCell>)}
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {filteredIds.length === 0 ? <EmptyRow /> : (
                            filteredIds
                              .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                              .map((i) => (
                                <MutRow
                                    mutId={i}
                                    mutData={mutData}
                                    setSelectedMut={setSelectedMut}
                                    key={i}
                                />
                        )))}
                    </TableBody>
                </Table>
            </TableContainer>
        </div>
        </>
    )
}

export default MutTable;