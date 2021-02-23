#!/usr/bin/env python3
"""
Extract subsets from vcf sample headers
"""
import argparse
import os
import sys
from dataclasses import dataclass
from datetime import date, timedelta

NAME_REGIONS = {
    "Caribbean": ["Anguilla", "AntiguaandBarbuda", "Aruba", "Bahamas", "Barbados",
                  "Bonaire, SintEustatiusandSaba", "CaymanIslands", "Cuba", "Curaçao",
                  "Dominica", "DominicanRepublic", "Grenada", "Guadeloupe", "Haiti", "Jamaica",
                  "Martinique", "Montserrat", "PuertoRico", "SaintBarthélemy",
                  "SaintKittsandNevis", "SaintLucia", "SaintMartin(Frenchpart)",
                  "SaintVincentandtheGrenadines", "SintMaarten(Dutchpart)",
                  "TrinidadandTobago", "TurksandCaicosIslands", "VirginIslands(British)",
                  "VirginIslands(U.S.)"],

    "CentralAmerica": ["Belize", "CostaRica", "ElSalvador", "Guatemala", "Honduras", "Mexico",
                       "Nicaragua", "Panama"],

    "CentralAsia": ["Kazakhstan", "Kyrgyzstan", "Tajikistan", "Turkmenistan", "Uzbekistan"],

    "EastAsia": ["China", "HongKong", "Japan", "Korea", "Macao", "Mongolia", "Taiwan"],

    "Europe": ["ÅlandIslands", "Albania", "Andorra", "Austria", "Belarus", "Belgium",
               "BosniaandHerzegovina", "Bulgaria", "Croatia", "Czechia", "Denmark", "Estonia",
               "FaroeIslands", "Finland", "France", "Germany", "Gibraltar", "Greece", "Guernsey",
               "HolySee", "Hungary", "Iceland", "Ireland", "IsleofMan", "Italy", "Jersey",
               "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Malta", "Moldova",
               "Monaco", "Montenegro", "Netherlands", "NorthMacedonia", "Norway", "Poland",
               "Portugal", "Romania", "RussianFederation", "SanMarino", "Serbia", "Slovakia",
               "Slovenia", "Spain", "SvalbardandJanMayen", "Sweden", "Switzerland", "Ukraine"],

    "NorthAfrica": ["Algeria", "Egypt", "Libya", "Morocco", "Sudan", "Tunisia", "WesternSahara"],

    "NorthAmerica": ["Bermuda", "Canada", "Greenland", "SaintPierreandMiquelon", "USA"],

    "Oceania": ["AmericanSamoa", "Australia", "ChristmasIsland", "Cocos(Keeling)Islands",
                "CookIslands", "Fiji", "FrenchPolynesia", "Guam", "HeardIslandandMcDonaldIslands",
                "Kiribati", "MarshallIslands", "Micronesia", "Nauru", "NewCaledonia", "NewZealand",
                "Niue", "NorfolkIsland", "NorthernMarianaIslands", "Palau", "PapuaNewGuinea",
                "Pitcairn", "Samoa", "SolomonIslands", "Tokelau", "Tonga", "Tuvalu",
                "Vanuatu", "WallisandFutuna"],

    "SouthAmerica": ["Argentina", "Bolivia", "BouvetIsland", "Brazil", "Chile", "Colombia",
                     "Ecuador", "FalklandIslands", "FrenchGuiana", "Guyana", "Paraguay", "Peru",
                     "SouthGeorgiaandtheSouthSandwichIslands", "Suriname", "Uruguay", "Venezuela"],

    "SouthAsia": ["Afghanistan", "Bangladesh", "Bhutan", "India", "Iran",
                  "Maldives", "Nepal", "Pakistan", "SriLanka"],

    "SouthEastAsia": ["BruneiDarussalam", "Cambodia", "Indonesia", "LaoPeople'sDemocraticRepublic",
                      "Malaysia", "Myanmar", "Philippines", "Singapore", "Thailand", "Timor-Leste",
                      "Vietnam"],

    "SubSaharanAfrica": ["Angola", "Benin", "Botswana", "BritishIndianOceanTerritory",
                         "BurkinaFaso", "Burundi", "CaboVerde", "Cameroon",
                         "CentralAfricanRepublic", "Chad", "Comoros", "Congo", "CongoDemocraticRepublicofthe", "Côted'Ivoire", "Djibouti",
                         "EquatorialGuinea", "Eritrea", "Eswatini", "Ethiopia",
                         "FrenchSouthernTerritories", "Gabon", "Gambia", "Ghana", "Guinea",
                         "Guinea-Bissau", "Kenya", "Lesotho", "Liberia", "Madagascar", "Malawi",
                         "Mali", "Mauritania", "Mauritius", "Mayotte", "Mozambique", "Namibia",
                         "Niger", "Nigeria", "Réunion", "Rwanda",
                         "SaintHelena,AscensionandTristandaCunha", "SaoTomeandPrincipe",
                         "Senegal", "Seychelles", "SierraLeone", "Somalia", "SouthAfrica",
                         "SouthSudan", "Tanzania,UnitedRepublicof", "Togo", "Uganda", "Zambia",
                         "Zimbabwe"],

    "UnitedKingdom": ["England", "Wales", "Scotland", "NorthernIreland", "UnitedKingdom"],

    "WestAsia": ["Armenia", "Azerbaijan", "Bahrain", "Cyprus", "Georgia", "Iraq", "Israel",
                 "Jordan", "Kuwait", "Lebanon", "Oman", "Palestine,Stateof", "Qatar",
                 "SaudiArabia", "SyrianArabRepublic", "Turkey", "UnitedArabEmirates", "Yemen"]
}
NAME_TO_REGION = {i: k for k, v in NAME_REGIONS.items() for i in v}

ALPHA_REGIONS = {
    "Caribbean": ["AIA", "ATG", "ABW", "BHS", "BRB", "BES", "CYM", "CUB", "CUW", "DMA", "DOM",
                  "GRD", "GLP", "HTI", "JAM", "MTQ", "MSR", "PRI", "BLM", "KNA", "LCA", "MAF",
                  "VCT", "SXM", "TTO", "TCA", "VGB", "VIR"],

    "CentralAmerica": ["BLZ", "CRI", "SLV", "GTM", "HND", "MEX", "NIC", "PAN"],

    "CentralAsia": ["KAZ", "KGZ", "TJK", "TKM", "UZB"],

    "EastAsia": ["CHN", "HKG", "JPN", "PRK", "KOR", "MAC", "MNG", "TWN"],

    "Europe": ["ALA", "ALB", "AND", "AUT", "BLR", "BEL", "BIH", "BGR", "HRV", "CZE", "DNK", "EST",
               "FRO", "FIN", "FRA", "DEU", "GIB", "GRC", "GGY", "VAT", "HUN", "ISL", "IRL", "IMN",
               "ITA", "JEY", "LVA", "LIE", "LTU", "LUX", "MLT", "MDA", "MCO", "MNE", "NLD", "MKD",
               "NOR", "POL", "PRT", "ROU", "RUS", "SMR", "SRB", "SVK", "SVN", "ESP", "SJM", "SWE",
               "CHE", "UKR"],

    "NorthAfrica": ["DZA", "EGY", "LBY", "MAR", "SDN", "TUN", "ESH"],

    "NorthAmerica": ["BMU", "CAN", "GRL", "SPM", "USA"],

    "Oceania": ["ASM", "AUS", "CXR", "CCK", "COK", "FJI", "PYF", "GUM", "HMD", "KIR", "MHL", "FSM",
                "NRU", "NCL", "NZL", "NIU", "NFK", "MNP", "PLW", "PNG", "PCN", "WSM", "SLB", "TKL",
                "TON", "TUV", "UMI", "VUT", "WLF"],

    "SouthAmerica": ["ARG", "BOL", "BVT", "BRA", "CHL", "COL", "ECU", "FLK", "GUF", "GUY", "PRY",
                     "PER", "SGS", "SUR", "URY", "VEN"],

    "SouthAsia": ["AFG", "BGD", "BTN", "IND", "IRN", "MDV", "NPL", "PAK", "LKA"],

    "SouthEastAsia": ["BRN", "KHM", "IDN", "LAO", "MYS", "MMR", "PHL", "SGP", "THA", "TLS", "VNM"],

    "SubSaharanAfrica": ["AGO", "BEN", "BWA", "IOT", "BFA", "BDI", "CPV", "CMR", "CAF", "TCD",
                         "COM", "COG", "COD", "CIV", "DJI", "GNQ", "ERI", "SWZ", "ETH", "ATF",
                         "GAB", "GMB", "GHA", "GIN", "GNB", "KEN", "LSO", "LBR", "MDG", "MWI",
                         "MLI", "MRT", "MUS", "MYT", "MOZ", "NAM", "NER", "NGA", "REU", "RWA",
                         "SHN", "STP", "SEN", "SYC", "SLE", "SOM", "ZAF", "SSD", "TZA", "TGO",
                         "UGA", "ZMB", "ZWE"],

    "UnitedKingdom": ['GBR'],

    "WestAsia": ["ARM", "AZE", "BHR", "CYP", "GEO", "IRQ", "ISR", "JOR", "KWT", "LBN", "OMN",
                 "PSE", "QAT", "SAU", "SYR", "TUR", "ARE", "YEM"]
}
ALPHA_TO_REGION = {i: k for k, v in ALPHA_REGIONS.items() for i in v}

@dataclass
class Sample:
    region: str
    date: date
    string: str

    @staticmethod
    def from_string(string):
        """
        Get Sample from an ID string. Often in the format country/sample_id/year|year-month-day.
        Year is given as two digits only in the date string. Sometimes day and or month are missing
        in which case the date is assumed to be 1st January 2020 or 1st December 2019, depending on
        the year. Regions are assigned assuming the first field is the country, in cases where this
        isn't true no region is given.
        """
        try:
            sections = string.replace('/', '|').split('|')

            country = sections[0] # Can also be other keys in some cases, discard those
            region = ''
            if country in NAME_TO_REGION:
                region = NAME_TO_REGION[country]
            elif country in ALPHA_TO_REGION:
                region = ALPHA_TO_REGION[country]

            sample_date = Sample.parse_sample_date(sections[-1])

            return Sample(region, sample_date, string)

        except Exception as e:
            print(string)
            raise e

    @staticmethod
    def parse_sample_date(string):
        """
        Parse sample date. If month is missing it defaults to January 2020.
        If day is missing it defaults to 1.
        """
        sample_date = string.split('-')
        try:
            if len(sample_date[0]) == 4:
                year = int(sample_date[0])
            else:
                year = 2000 + int(sample_date[0])
        except:
            year = 2020

        try:
            month = int(sample_date[1])
            month = month if month > 0 else 1
        except IndexError:
            month = 12 if year == 2019 else 1

        try:
            day = int(sample_date[2])
            day = day if day > 0 else 1
        except IndexError:
            # Some dates don't have days
            day = 1
        except ValueError:
            # Day is sometimes XX or similar
            day = 1

        return date(year, month, day)

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
            print('string', 'region', 'year', 'month', 'day',
                  sep='\t', file=tsv_file)
            for s in samples:
                print(s.string, s.region, s.date.year,
                      s.date.month, s.date.day,
                      sep='\t', file=tsv_file)

    if not os.path.isdir(args.dir):
        os.mkdir(args.dir)

    # Filter all samples here?

    # Identify Subsets
    subsets = {region: [] for region in NAME_REGIONS}
    subsets['overall'] = [i.string for i in samples]

    # Date based periods
    today = date.today()
    month_period = timedelta(days=30)
    three_month_period = timedelta(days=90)
    six_month_period = timedelta(days=180)

    subsets['last30days'] = [i.string for i in samples if (today - i.date) < month_period]
    subsets['last90days'] = [i.string for i in samples if (today - i.date) < three_month_period]
    subsets['last180days'] = [i.string for i in samples if (today - i.date) < six_month_period]

    for sample in samples:
        if sample.region in NAME_REGIONS:
            subsets[sample.region].append(sample.string)

    if args.summary:
        with open(args.summary, 'w') as summary_file:
            print('name', 'n', 'desc', sep='\t', file=summary_file)
            for name, subset in subsets.items():
                if name == 'overall':
                    desc = 'All samples'
                elif name == 'last30days':
                    desc = f'Samples taken in up to 30 days before {today}'
                elif name == 'last90days':
                    desc = f'Samples taken in up to 90 days before {today}'
                elif name == 'last180days':
                    desc = f'Samples taken in up to 180 days before {today}'
                else:
                    desc = ', '.join(NAME_REGIONS[name])
                print(name, len(subset), desc, sep='\t', file=summary_file)

    # Print Subsets
    for name, subset in subsets.items():
        with open(f'{args.dir}/{name}.samples', 'w') as subset_file:
            print(*subset, sep='\n', file=subset_file)



def parse_args():
    """Process input arguments"""
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('vcf', metavar='V', help="VCF file")

    parser.add_argument('--tsv', '-t', default='',
                        help="Output a TSV file of samples to the specified path")

    parser.add_argument('--summary', '-s', default='',
                        help="Output a summary table of the subsets")

    parser.add_argument('--dir', '-d', default='.',
                        help="Directory to output sample subset lists")

    return parser.parse_args()

if __name__ == "__main__":
    main(parse_args())
