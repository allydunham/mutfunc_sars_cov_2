#!/usr/bin/env python3
"""
Extract subsets from vcf sample headers
"""
import argparse
import os
from dataclasses import dataclass
from datetime import date, timedelta

REGIONS = {
    'Britain': ['England', 'Scotland', 'Wales'],
    'Ireland': ['NorthernIreland', 'Ireland'],
    'Iberia': ['Portugal', 'Spain'],
    'USA': ['USA'],
    'Canada': ['Canada']

}

def parse_sample_date(string):
    """
    Parse sample date. If month is missing it defaults to January 2020.
    If day is missing it defaults to 1.
    """
    sample_date = string.split('-')
    year = 2000 + int(sample_date[0])

    try:
        month = int(sample_date[1])
    except IndexError:
        month = 12 if year == 2019 else 1

    try:
        day = int(sample_date[2])
    except IndexError:
        # Some dates don't have days
        day = 1
    except ValueError:
        # Day is sometimes XX or similar
        day = 1

    return date(year, month, day)

@dataclass
class Sample:
    region: str
    sample_id: str
    year: int
    gisaid_id: str
    date: date
    species: str
    string: str

    @staticmethod
    def from_string(string):
        """
        Get Sample from an ID string of the format region/sample_id/year|GISAID_ID|year-month-day.
        Year is given as two digits only in the date string. Sometimes day and or month are missing
        in which case the date is assumed to be 1st January 2020 or 1st December 2019, depending on
        the year.
        """
        try:
            sections = string.replace('/', '|').split('|')

            species = 'human'
            if len(sections) == 6:
                species = sections[0]
                sections = sections[1:]

            sample_date = parse_sample_date(sections[4])

            return Sample(sections[0], sections[1], int(sections[2]),
                          sections[3], sample_date, species, string)
        except Exception as e:
            print(string)
            raise e


def get_vcf_samples(path):
    """
    Fetch sample names from a VCF file
    """
    with open(path, 'r') as vcf_file:
        for line in vcf_file:
            if line.startswith('##'):
                continue

            if line.startswith('#'):
                return line.strip().split('\t')[9:]

            raise ValueError(('Reached a line not starting with # before '
                              'finding the header line, which should start with '
                              'a single #'))

def main(args):
    """
    Select subsets of VCF headers
    """
    samples = [Sample.from_string(x) for x in get_vcf_samples(args.vcf)]

    if args.tsv:
        with open(args.tsv, 'w') as tsv_file:
            print('string', 'region', 'year', 'month', 'day', 'species',
                  sep='\t', file=tsv_file)
            for s in samples:
                print(s.string, s.region, s.date.year,
                      s.date.month, s.date.day, s.species,
                      sep='\t', file=tsv_file)

    if not os.path.isdir(args.dir):
        os.mkdir(args.dir)

    # Print list of recent samples
    today = date.today()
    period = timedelta(days=90)
    recent_samples = [i.string for i in samples if (today - i.date) < period]
    with open(f'{args.dir}/last90days.samples'):
        print(*recent_samples, sep='\n')

def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('vcf', metavar='V', help="VCF file")

    parser.add_argument('--tsv', '-t', default='',
                        help="Output a TSV file of samples to the specified path")

    parser.add_argument('--dir', '-d', default='.',
                        help="Directory to output sample subset lists")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())