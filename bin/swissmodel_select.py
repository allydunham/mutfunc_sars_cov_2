#!/usr/bin/env python3
"""
Select the best set of models for a gene
"""
import argparse
import json
import os
import re
from dataclasses import dataclass
from region import ProteinRegion

@dataclass
class Model:
    template: str
    chain: str
    region: ProteinRegion
    offset: int
    method: str
    coverage: float
    qmean6: float
    qmean6_z: float
    date: str

    @staticmethod
    def from_directory(path):
        """
        Create a Model from the JSON data from a SWISS-MODEL model dir.
        """
        with open(f'{path}/info.json') as json_file:
            info = json.load(json_file)

        with open(f'{path}/report.json') as json_file:
            report = json.load(json_file)

        report = report['modelling']
        chain = report['chain']
        region = ProteinRegion(chain, ','.join([f"{i['residue_from']}:{i['residue_to']}" for i in
                                                info['residue_range']]))
        return Model(report['pdb_id'], chain, region, int(report['offset']),
                     report['short_method'], float(report['coverage']),
                     report['QMean']['global_scores']['qmean6_norm_score'],
                     report['QMean']['global_scores']['qmean6_z_score'],
                     info['creation_date'])

def main(args):
    """
    Main
    """
    # Identify available models and import
    models = [i for i in os.listdir(args.swissmodel) if re.match('^[0-9]{2}$', i)]
    model_info = []
    for model in models:
        model_info.append(Model.from_directory(f'{args.swissmodel}/{model}'))

    print(model_info)

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('swissmodel', metavar='S',
                        help="Directory containing downloaded SWISS-MODEL (homology) models")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())