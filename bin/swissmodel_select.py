#!/usr/bin/env python3
"""
Select the best set of models for a gene
"""
import argparse
import json
import re
import os
from pathlib import Path
from dataclasses import dataclass
from region import ProteinRegion

@dataclass
class Model:
    number: str
    template: str
    chain: str
    region: ProteinRegion
    offset: int
    method: str
    coverage: float
    seq_id: float
    qmean6: float
    qmean6_z: float
    date: str

    @staticmethod
    def from_directory(path):
        """
        Create a Model from the JSON data from a SWISS-MODEL model dir.
        """
        number = Path(path).stem
        with open(f'{path}/info.json') as json_file:
            info = json.load(json_file)

        with open(f'{path}/report.json') as json_file:
            report = json.load(json_file)

        report = report['modelling']
        chain = report['chain']
        region = [f"{i['residue_from']}:{i['residue_to']}" for i in
                 info['residue_range'] if i['chain_name'] == chain]
        region = ProteinRegion(chain, ','.join(region))
        return Model(number, report['pdb_id'], chain, region, int(report['offset']),
                     report['short_method'], float(report['coverage']), float(report['seq_id']),
                     report['QMean']['global_scores']['qmean6_norm_score'],
                     report['QMean']['global_scores']['qmean6_z_score'],
                     info['creation_date'])

def main(args):
    """
    Main
    """
    # Identify available models and import
    models = [Model.from_directory(f'{args.swissmodel}/{i}') for
              i in os.listdir(args.swissmodel) if re.match('^[0-9]{2}$', i)]

    # Filter out models not meeting criteria
    models = [m for m in models if m.coverage > args.coverage and
              m.seq_id > args.seq_id and m.qmean6_z > args.qmean_z]

    # Consider direct models of the protein first, then homology models
    # Sorting by qmean within groups
    models.sort(key=lambda x: x.qmean6_z, reverse=True)
    direct_models = [m for m in models if m.seq_id == 100]
    homology_models = [m for m in models if m.seq_id < 100]
    models = direct_models + homology_models

    selected_models = []
    if models:
        selected_models.append((models[0], set(models[0].region.positions)))
        for model in models[1:]:
            covered_region = set().union(*[m[1] for m in selected_models])
            new_region = set(model.region.positions) - covered_region
            if new_region:
                selected_models.append((model, new_region))

    print('model', 'template', 'chain', 'offset', 'seq_id', 'coverage',
          'qmean6_z', 'date', 'positions', sep='\t')
    for model, region in selected_models:
        print(model.number, model.template, model.chain, model.offset, model.seq_id,
              model.coverage, model.qmean6_z, model.date,
              ','.join(str(r) for r in region), sep='\t')

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('swissmodel', metavar='S',
                        help="Directory containing downloaded SWISS-MODEL (homology) models")

    select = parser.add_argument_group('Selection Criteria')
    select.add_argument('--seq_id', '-s', default=0, type=float, help="Minimum sequence identify")
    select.add_argument('--coverage', '-c', default=0, type=float, help="Minimum coverage")
    select.add_argument('--qmean_z', '-q', default=-4, type=float, help="Minimum QMEAN Z-score")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())