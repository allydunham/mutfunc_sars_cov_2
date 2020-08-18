import React, { useState, useEffect } from "react";
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import TablePagination from '@material-ui/core/TablePagination';
import IconButton from '@material-ui/core/IconButton';
import FirstPageIcon from '@material-ui/icons/FirstPage';
import KeyboardArrowLeft from '@material-ui/icons/KeyboardArrowLeft';
import KeyboardArrowRight from '@material-ui/icons/KeyboardArrowRight';
import LastPageIcon from '@material-ui/icons/LastPage';
import Checkbox from '@material-ui/core/Checkbox';
import FormControl from '@material-ui/core/FormControl';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import { makeStyles } from '@material-ui/core/styles';
import MutBadges, { BadgeKey } from './MutBadges';
import { sarsDisplayNames } from '../lib/sars'

const styles = makeStyles((theme) => ({
    tableControls: {
        display: 'flex',
        justifyContent: 'flex-end',
        alignItems: 'center',
        width: '100%'
    },
    tablePaper: {
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        width: '100%'
    },
    pageButton: {
        flexShrink: 0
    }
}));

// Split these up into lower level components?
const ShowNeutralCheck = ({viewAll, setViewAll}) => {
    return(
        <FormControl fullWidth>
            <FormControlLabel
                labelPlacement='start'
                control={<Checkbox
                           checked={viewAll}
                           onChange={(event) => {setViewAll(event.target.checked)}}
                         />}
                label="Show variants without predicted effects"
            />
        </FormControl>
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
    const [viewAll, setViewAll] = useState(false)
    const [filteredIds, setFilteredIds] = useState([])
    const [page, setPage] = React.useState(0);
    const [rowsPerPage, setRowsPerPage] = React.useState(50);

    useEffect(() => {
        setFilteredIds(mutIds.filter((i) => {
            return viewAll ||
            (
                mutData[i]['sift_score'] < 0.05 ||
                Math.abs(mutData[i]['total_energy']) > 1 ||
                mutData[i]['ptm'] !== '' ||
                mutData[i]['int_name'] !== '' ||
                mutData[i]['freq'] > 0.01
            )
        }))
    }, [mutIds, viewAll, mutData])

    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };

    const handleChangeRowsPerPage = (event) => {
        setRowsPerPage(parseInt(event.target.value, 10));
        setPage(0);
    };

    return(
        <>
        <div className={classes.badgeKey}>
            <ShowNeutralCheck
                viewAll={viewAll}
                setViewAll={setViewAll}
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