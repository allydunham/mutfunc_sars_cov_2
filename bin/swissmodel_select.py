#!/usr/bin/env python3
"""
Select the best set of models for a gene
"""
import json
import os
import re

class Model:
    def __init__(self, )

    def from_directory(path):
        """
        Create a Model from the JSON data from a SWISS-MODEL model dir.
        """
        with open(f'{path}/info.json') as json_file:
            info = json.load(json_file)

        with open(f'{path}/report.json') as json_file:
            report = json.load(json_file)


def main(args):
    """
    Main
    """
    # Identify available models and import
    models = [i for i in os.listdir(args.swissmodel) if re.match('^[0-9]{2}$', i)]
    model_info = {}
    for model in models:
        model_info[model] = {}
        with open(f'{args.swissmodel}/{model}/info.json') as json_file:
            model_info.append(json.load(json_file))

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('swissmodel', metavar='S',
                        help="Directory containing downloaded SWISS-MODEL (homology) models")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())