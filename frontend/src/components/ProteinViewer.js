import React, { Component, createRef } from "react";
import pv from 'bio-pv';

// Colour molecules as we want - one chain one colour, interface another, mutated residue a third
function colourMol(position, chain1, chain2){
    let pos_col = [0.9, 0.1, 0.05, 1.0]
    let chain1_col = [0.55, 0.7, 0.95, 0.9]
    let chain2_col = [0.98, 0.55, 0.9, 0.9]
    let other_col = [0.95, 0.95, 0.95, 0.6]
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
        } else {
            out[index+0] = other_col[0];
            out[index+1] = other_col[1];
            out[index+2] = other_col[2];
            out[index+3] = other_col[3];
        }
    });
}

class ProteinViewer extends Component {
    constructor(props) {
        super(props)
        this.element = createRef()
        this.processPdb = this.processPdb.bind(this)
    }

    processPdb(structure){
        let colourer = colourMol(this.props.position,
                                 this.props.chain,
                                 this.props.int_chain)
        this.viewer.cartoon('protein', structure, { color: colourer });
        this.viewer.autoZoom();
    }

    componentDidMount(){
        const options = {
            width: this.props.width,
            height: this.props.height,
            antialias: true,
            quality : 'medium'
        }
        this.viewer = pv.Viewer(this.element.current, options);
        if (this.props.pdb_path !== ''){
            console.log('Rendering protein: ', this.props.pdb_path)
            pv.io.fetchPdb(this.props.pdb_path, this.processPdb)
        }
    }

    componentDidUpdate(prevProps){
        if (this.props.pdb_path !== prevProps.pdb_path ||
            this.props.position !== prevProps.position ||
            this.props.chain !== prevProps.chain ||
            this.props.int_chain !== prevProps.int_chain){
            this.viewer.rm('protein')
            if (this.props.pdb_path !== ''){
                console.log('Rendering protein: ', this.props.pdb_path)
                pv.io.fetchPdb(this.props.pdb_path, this.processPdb)
            }
        }
    }

    render(){
        return(
            <div
            hidden={this.props.hidden}
            className="pvViewer"
            ref={this.element}
            style={{borderColor: 'black',
                    borderStyle: 'solid',
                    borderWidth: 2,
                    marginLeft: 'auto',
                    marginRight: 'auto',
                    width: this.props.width,
                    height: this.props.height}}>
            </div>
        )
    }
}

ProteinViewer.defaultProps = {
    pdb_path: '',
    hidden: false,
    position: 10000,
    chain: '__NONE',
    int_chain: '__NONE',
    width: 500,
    height: 300
}

export default ProteinViewer