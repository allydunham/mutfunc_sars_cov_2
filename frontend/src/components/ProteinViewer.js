import React, { Component, createRef } from "react";
import pv from 'bio-pv';

class ProteinViewer extends Component {
    constructor(props) {
        super(props)
        this.element = createRef()
        this.renderProtein = this.renderProtein.bind(this)
    }

    renderProtein(){
        console.log('Rendering protein')
        const processPdb = (structure) => {
            console.log(structure)
            // asynchronously load the PDB file for the dengue methyl transferase
            // from the server and display it in the viewer.
            // display the protein as cartoon, coloring the secondary structure
            // elements in a rainbow gradient.
            this.viewer.cartoon('protein', structure, { color : pv.color.ssSuccession() });
            // there are two ligands in the structure, the co-factor S-adenosyl
            // homocysteine and the inhibitor ribavirin-5' triphosphate. They have
            // the three-letter codes SAH and RVP, respectively. Let's display them
            // with balls and sticks.
            const ligands = structure.select({ rnames : ['SAH', 'RVP'] });
            this.viewer.ballsAndSticks('ligands', ligands);
            this.viewer.centerOn(structure);
        }
        processPdb.bind(this)
        pv.io.fetchPdb(process.env.PUBLIC_URL + '/data/test.pdb', processPdb)
    }

    componentDidMount(){
        const options = {
            width: 500,
            height: 300,
            antialias: true,
            quality : 'medium'
        }
        this.viewer = pv.Viewer(this.element.current, options);
        this.renderProtein();
    }

    render(){
        return(
            <div id="pvViewer" className="pvViewer" ref={this.element}></div>
        )
    }
}

export default ProteinViewer