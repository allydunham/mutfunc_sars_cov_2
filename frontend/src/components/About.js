import React from "react";
import Typography from '@material-ui/core/Typography';
import Link from '@material-ui/core/Link';
import Button from '@material-ui/core/Button';
import TwitterIcon from '@material-ui/icons/Twitter';
import MailOutlineIcon from '@material-ui/icons/MailOutline';
import { makeStyles } from '@material-ui/core/styles';
import config from '../config'

const styles = makeStyles({
    root: {
        flexGrow: 1,
        margin: 'auto',
        padding: '10px',
        width: '70%'
    },
    heading: {
        paddingTop: '50px'
    },
    content: {
        paddingTop: '25px',
    },
    imageContainer: {
        flex: 1,
        flexDirection: 'row',
        paddingLeft: '30px',
        paddingTop: '25px'
    },
    image: {
        marginRight: '10px'
    },
    button: {
        textTransform: 'none'
    }
});

const About = () => {
    const classes = styles()
    return(
        <div className={classes.root}>
            <Typography variant='h5' className={classes.heading}>
                Citation
            </Typography>
            <Typography variant='h5' className={classes.heading}>
                Data Sources
            </Typography>
            <div className={classes.imageContainer}>
                <Link
                  href="https://swissmodel.expasy.org/"
                  target="_blank"
                  rel="noopener noreferrer">
                    <img
                      src={process.env.PUBLIC_URL + 'images/swissmodel.png'}
                      alt='swissmodel-logo'
                      height='75px'
                      className={classes.image}
                    />
                </Link>
                <Link
                  href="https://www.uniprot.org/"
                  target="_blank"
                  rel="noopener noreferrer">
                    <img
                      src={process.env.PUBLIC_URL + 'images/uniprot.png'}
                      alt='uniprot-logo'
                      height='75px'
                      className={classes.image}
                    />
                </Link>
                <Link
                  href="https://www.ensembl.org/index.html"
                  target="_blank"
                  rel="noopener noreferrer">
                    <img
                      src={process.env.PUBLIC_URL + 'images/ensembl.jpg'}
                      alt='ensembl-logo'
                      height='75px'
                      className={classes.image}
                    />
                </Link>
                <Link
                  href="https://www.ebi.ac.uk/pdbe/"
                  target="_blank"
                  rel="noopener noreferrer">
                    <img
                      src={process.env.PUBLIC_URL + 'images/pdbe_logo.png'}
                      alt='pdbe-logo'
                      height='75px'
                      className={classes.image}
                    />
                </Link>
                <Link
                  href="https://www.gisaid.org/"
                  target="_blank"
                  rel="noopener noreferrer">
                    <img
                      src={process.env.PUBLIC_URL + 'images/gisaid_logo.png'}
                      alt='gisaid-logo'
                      height='75px'
                      className={classes.image}
                    />
                </Link>
            </div>
            <br/>
            <Typography className={classes.text}>
                The variant alignment used to calculate frequencies is from the {config.vcf_version} release of <Link href="https://github.com/roblanf/sarscov2phylo" target="_blank" rel="noopener noreferrer">sarscov2phylo</Link>
            </Typography>
            <br/>
            <Typography className={classes.text}>
                Phosphorylation data was sourced from <Link href="https://europepmc.org/article/med/32645325" target="_blank" rel="noopener noreferrer"> Bouhaddou et al. (2020) </Link>
            </Typography>
            <Typography variant='h5' className={classes.heading}>
                Tools
            </Typography>
            <div className={classes.imageContainer}>
                <Link
                  href="https://sift.bii.a-star.edu.sg/sift4g/"
                  target="_blank"
                  rel="noopener noreferrer">
                    <img
                      src={process.env.PUBLIC_URL + 'images/sift.png'}
                      alt='sift-logo'
                      height='75px'
                      className={classes.image}
                    />
                </Link>
                <Link
                  href="http://foldxsuite.crg.eu/"
                  target="_blank"
                  rel="noopener noreferrer">
                    <img
                      src={process.env.PUBLIC_URL + 'images/foldx.png'}
                      alt='foldx-logo'
                      height='75px'
                      className={classes.image}
                    />
                </Link>
                <Link
                  href="https://www.ensembl.org/info/docs/tools/vep/index.html"
                  target="_blank"
                  rel="noopener noreferrer">
                    <img
                      src={process.env.PUBLIC_URL + 'images/vep.jpg'}
                      alt='vep-logo'
                      height='75px'
                      className={classes.image}
                    />
                </Link>
            </div>
            <Typography className={classes.content}>
                The pipeline is managed by <Link href="https://snakemake.readthedocs.io/en/stable/" target="_blank" rel="noopener noreferrer">Snakemake</Link>.
                See the projects <Link href="https://github.com/allydunham/covid19_mutfunc" target="_blank" rel="noopener noreferrer">Github repository</Link> for full technical details of the pipeline and the packages used.
                This website was primarily built with <Link href="https://reactjs.org/" target="_blank" rel="noopener noreferrer">Reactjs</Link> and <Link href="https://material-ui.com/" target="_blank" rel="noopener noreferrer">Material UI</Link>.
                &nbsp;<Link href="https://biasmv.github.io/pv/" target="_blank" rel="noopener noreferrer">PV - Protein Viewer</Link> is used for rendering PDB structures and <Link href="https://github.com/plotly/react-msa-viewer" target="_blank" rel="noopener noreferrer">React MSA Viewer</Link> for displaying multiple alignments.
                Full technical details of the site are again available in the repository.
            </Typography>
            <Typography variant='h5' className={classes.heading}>
                Contact
            </Typography>
            <Typography className={classes.content}>
                Issues can be submitted through the <Link href="https://github.com/allydunham/covid19_mutfunc/issues" target="_blank" rel="noopener noreferrer">Github repository</Link>.
                <br/>
                <b>Alistair Dunham</b> - <Button
                  className={classes.button}
                  href='https://twitter.com/Ally_Dunham'
                  target="_blank"
                  rel="noopener noreferrer"
                  startIcon={<TwitterIcon/>}>
                    @Ally_Dunham
                </Button>
                <Button
                  className={classes.button}
                  href='mailto:ally@ebi.ac.uk'
                  target="_blank"
                  rel="noopener noreferrer"
                  startIcon={<MailOutlineIcon/>}>
                    ally@ebi.ac.uk
                </Button>
            </Typography>
        </div>
    )
}

export default About