import React, { Component, createRef } from "react";
import pv from 'bio-pv';

// Colour molecules as we want - one chain one colour, interface another, mutated residue a third
function colourMol(position, chain1, chain2){
    let pos_col = [0.9, 0.1, 0.05, 1.0]
    let chain1_col = [0.55, 0.7, 0.95, 0.9]
    let chain2_col = [0.98, 0.55, 0.9, 0.9]
    return new pv.color.ColorOp(function(atom, out, index) {
        let residue = atom.residue()
        if (residue.chain().name() === chain1) {
            if (residue.num() === position){
                out[index+0] = pos_col[0];
                out[index+1] = pos_col[1];
                out[index+2] = pos_col[2];
                out[index+3] = pos_col[3];
            } else {
                out[index+0] = chain1_col[0];
                out[index+1] = chain1_col[1];
                out[index+2] = chain1_col[2];
                out[index+3] = chain1_col[3];
            }
        } else if (residue.chain().name() === chain2) {
            out[index+0] = chain2_col[0];
            out[index+1] = chain2_col[1];
            out[index+2] = chain2_col[2];
            out[index+3] = chain2_col[3];
        }
    });
}

class ProteinViewer extends Component {
    constructor(props) {
        super(props)
        this.element = createRef()
        this.renderProtein = this.renderProtein.bind(this)
    }

    renderProtein(){
        console.log('Rendering protein...')
        const processPdb = (structure) => {
            let colourer = colourMol(this.props.position,
                                     this.props.chain,
                                     this.props.int_chain)
            this.viewer.cartoon('protein', structure, { color: colourer });
            this.viewer.autoZoom();
        }
        processPdb.bind(this)
        pv.io.fetchPdb(this.props.pdb_path, processPdb)
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
            <div
             id="pvViewer"
             hidden={this.props.hidden}
             className="pvViewer"
             ref={this.element}
             style={{borderColor: 'black',
                     borderStyle: 'solid',
                     height: 300,
                     width: 500}}>
            </div>
        )
    }
}

ProteinViewer.defaultProps = {
    positin: 10000,
    chain: '__NONE',
    int_chain: '__NONE'
}

export default ProteinViewer