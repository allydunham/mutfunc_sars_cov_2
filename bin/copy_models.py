#!/usr/bin/env python3
"""
Copy PDB models from pipeline to frontend
"""
import argparse
import os
import shutil
from pathlib import Path

import pandas as pd
from ruamel.yaml import YAML

def process_swissmodel(input_dir, output_dir):
    """
    Identify swissmodel models in a directory and copy them to output_dir
    """
    proteins = [Path(i).stem for i in os.listdir(input_dir) if i.endswith('.models')]
    for protein in proteins:
        config = pd.read_csv(f'{input_dir}/{protein}.models', sep='\t', dtype={'model': str})

        if not len(config.index) > 0:
            continue
        
        Path(f'{output_dir}/{protein}').mkdir(exist_ok=True)
        for model, template in zip(config.model, config.template):
            shutil.copyfile(f'{input_dir}/{protein}/{model}/model.pdb',
                            f'{output_dir}/{protein}/{template}.pdb')

def process_complex(input_dir, output_dir):
    """
    Identify complex models in a directory and copy them to output_dir
    """
    yaml_reader = YAML(typ='safe')
    for model_dir in os.listdir(input_dir):
        if not os.path.isdir(f'{input_dir}/{model_dir}'):
            continue

        config = yaml_reader.load(Path(f'{input_dir}/{model_dir}/model.yaml'))
        model = config['model'].split('.')[0]

        shutil.copyfile(f'{input_dir}/{model_dir}/model.pdb', f'{output_dir}/{model}.pdb')

def main(args):
    """Main"""
    if args.type == 'swissmodel':
        process_swissmodel(args.input, args.output)
    elif args.type == 'complex':
        process_complex(args.input, args.output)
    else:
        # Should never be able to get here, assuming argparse is working
        raise ValueError('Unrecognised "type" argument')

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('type', metavar='T', choices=('swissmodel', 'complex'),
                        help="Input directory format")
    parser.add_argument('input', metavar='I', help="Input directory")
    parser.add_argument('output', metavar='O', help="Output directory")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())
