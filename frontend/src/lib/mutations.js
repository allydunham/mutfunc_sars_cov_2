// Utility functions for processing and working with mutation objects
import { sarsUniprot, sarsGenes, parseSarsSynonym} from './sars'

export function makeMutKey(mut){
    return [mut['name'], '_', mut['wt'], mut['position'], mut['mut']].join('')
}

export function compareMutIds(mut1, mut2){
    let [gene1, pos1] = mut1.split('_')
    mut1 = pos1.slice(-1)
    pos1 = Number(pos1.slice(1, -1))
    let [gene2, pos2] = mut2.split('_')
    mut2 = pos2.slice(-1)
    pos2 = Number(pos2.slice(1, -1))

    // Sort  by gene first
    if (gene1 !== gene2){
        if (sarsGenes.indexOf(gene1) > sarsGenes.indexOf(gene2)){
            return 1
        }
        if (sarsGenes.indexOf(gene1) < sarsGenes.indexOf(gene2)) {
            return -1
        }
    }

    // Then by position
    if (pos1 > pos2){
        return 1
    } else if (pos1 < pos2){
        return -1
    }

    // Finally by variant
    if (mut1 > mut2){
        return 1
    } else if (mut1 < mut2){
        return -1
    }

    return 0
}

// Supported search modes:
// Full ID - Gene X1Y
// Gene & Pos - Gene Pos
// Gene - Gene
// Uniprot - Uniprot ID
// Uniprot can also substitute for gene apart from multi-protein gene
const otherSearches = ['gene', 'uniprot', 'position', 'wtPosition', 'mutPosition']
const errorSearches = ['idError', 'geneError', 'uniprotError', 'unknownError']
function parseSearch(search, muts){
    search = search.trim().split(/\s+/);

    // Process Uniprot IDs
    if (search[0].toUpperCase() in sarsUniprot){
        // Search for a Uniprot ID if only that is provides
        if (search.length === 1){
            return {type: 'uniprot', content: search[0].toUpperCase()}
        }

        // Otherwise convert to a gene name
        if (['P0DTD1', 'P0DTC1'].includes(search[0])){
            let str = 'Bad Uniprot ID: ' + search[0] + ' matches multiple proteins'
            return {type: 'uniprotError', content: str}
        }
        search[0] = sarsUniprot[search[0]]
    }

    // Parse synonymn gene names (and convert to lower case internally)
    search[0] = parseSarsSynonym(search[0]);

    // Search for an entire gene
    if (sarsGenes.includes(search[0]) && search.length === 1){
        return {type: 'gene', content: search[0]}
    }

    if (!sarsGenes.includes(search[0])){
        return {type: 'geneError', content: 'Unknown gene: ' + search[0]};
    }

    if (/^[0-9]+$/.test(search[1])){
        search[1] = Number(search[1]);
        return {type: 'position', content: search};
    }

    if (/^[ACDEFGHIKLMNPQRSTVWY][0-9]+$/.test(search[1])){
        search[2] = Number(search[1].slice(1));
        search[1] = search[1].slice(0, 1)
        return {type: 'wtPosition', content: search};
    }

    if (/^[0-9]+[ACDEFGHIKLMNPQRSTVWY]$/.test(search[1])){
        search[2] = search[1].slice(-1)
        search[1] = Number(search[1].slice(0, -1));
        return {type: 'mutPosition', content: search};
    }

    if (/^[ACDEFGHIKLMNPQRSTVWY][0-9]+[ACDEFGHIKLMNPQRSTVWY]$/.test(search[1])){
        let id = search.join('_')
        if (id in muts){
            return {type: 'id', content: id};
        } else {
            let str = 'Unmatched MutID: ' + search.join(' ')
            return {type: 'idError', content: str};
        }
    }

    return {type: 'unknownError', content: 'Unknown format: ' + search.join(' ')};
}

function checkMutAgainstSearch(mut, searches){
    for (const search of searches){
        if (search['type'] === 'position' &&
            mut[1]['name'] === search['content'][0] &&
            mut[1]['position'] === search['content'][1]){
                return mut[0]
        }
        if (search['type'] === 'wtPosition' &&
            mut[1]['name'] === search['content'][0] &&
            mut[1]['wt'] === search['content'][1] &&
            mut[1]['position'] === search['content'][2]){
                return mut[0]
        }
        if (search['type'] === 'mutPosition' &&
            mut[1]['name'] === search['content'][0] &&
            mut[1]['position'] === search['content'][1] &&
            mut[1]['mut'] === search['content'][2]){
                return mut[0]
        }
        if (search['type'] === 'gene' &&
            mut[1]['name'] === search['content']){
                return mut[0]
        }
        if (search['type'] === 'uniprot' &&
             mut[1]['uniprot'] === search['content']){
                return mut[0]
        }
    }
    return null
}

export function searchMutations(search, muts){
    return new Promise((resolve, reject) => {
        search = search.split(/[\n,;]+/).filter((i) => i !== "").map((i) => parseSearch(i, muts));
        console.log('Searching for:', search)

        // Split searches
        let errors = search.filter((s) => errorSearches.includes(s['type']))
        errors = [...new Set(errors.map((s) => s['content']))]
        let others = search.filter((s) => otherSearches.includes(s['type']))

        // Return directly matched IDs
        let mutIDs = search.filter((s) => s['type'] === 'id').map((s) => s['content'])

        // Search for other terms
        if (others.length > 0){
            mutIDs = Object.entries(muts)
                      .map((m) => checkMutAgainstSearch(m, others))
                      .filter((i) => i !== null)
                      .concat(mutIDs)
                      .sort(compareMutIds)
        }

        console.log('Serach Complete')
        resolve({results: [...new Set(mutIDs)], errors: errors});
    })
}