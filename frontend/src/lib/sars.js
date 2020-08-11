// Constants for SARS-CoV2

export const sarsUniprot = {
    'P0DTD1': 'rep1ab', 'P0DTC1': 'rep1a', 'P0DTC2': 's',
    'P0DTC3': 'orf3a', 'P0DTC4': 'e', 'P0DTC5': 'm',
    'P0DTC6': 'orf6', 'P0DTC7': 'orf7a', 'P0DTD8': 'orf7b',
    'P0DTC8': 'orf8', 'P0DTC9': 'nc', 'A0A663DJA2': 'orf10',
    'P0DTD2': 'orf9b', 'P0DTD3': 'orf14'
}

export const sarsGenes = ['nsp1', 'nsp2', 'nsp3','nsp4', 'nsp5',
                          'nsp6','nsp7', 'nsp8', 'nsp9', 'nsp10',
                          'nsp11', 'nsp12', 'nsp13', 'nsp14',
                          'nsp15', 'nsp16', 's', 'orf3a', 'e',
                          'm', 'orf6','orf7a', 'orf7b', 'orf8',
                          'nc', 'orf10', 'orf9b','orf14']
// TODO - Map for common versions of gene names

// Genomic coordinates for each gene
export const sarsGenePositions = {
    'orf1a': [266, 13483],
    'orf1ab': [266, 21555],
    'nsp1': [266, 805],
    'nsp2': [806, 2719],
    'nsp3': [2720, 8554],
    'nsp4': [8555, 10054],
    'nsp5': [10055, 10972],
    'nsp6': [10973, 11842],
    'nsp7': [11843, 12091],
    'nsp8': [12092, 12685],
    'nsp9': [12686, 13024],
    'nsp10': [13025, 13441],
    'nsp11': [13442, 13480],
    'nsp12': [13442, 16237],
    'nsp13': [16238, 18040],
    'nsp14': [18041, 19621],
    'nsp15': [19622, 20659],
    'nsp16': [20660, 21553],
    's': [21563, 25384],
    'orf3a': [25393, 26220],
    'e': [26245, 26472],
    'm': [26523, 27191],
    'orf6': [27202, 27387],
    'orf7a': [27394, 27759],
    'orf7b': [27756, 27887],
    'orf8': [27894, 28259],
    'nc': [28274, 29533],
    'orf10': [29558, 29674],
    'orf9b': [28130, 28426]
}