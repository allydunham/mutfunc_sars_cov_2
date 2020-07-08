// Utility functions for processing and working with mutation objects
import { sarsUniprot, sarsGenes} from './sars'

export function makeMutKey(mut){
    return [mut['name'], '_', mut['wt'], mut['position'], mut['mut']].join('')
}

// Supported search modes:
// Full ID - Gene X1Y
// Gene & Pos - Gene Pos
// Gene - Gene
// Uniprot - Uniprot ID
// Uniprot can also substitute for gene apart from multi-protein gene
function parseSearch(search){
    search = search.trim();

    // Search for an entire gene
    if (sarsGenes.includes(search.toLowerCase())){
        return {type: 'gene', content: search.toLowerCase()}
    }

    // Search for a Uniprot ID
    if (search in sarsUniprot) {
        return {type: 'uniprot', content: search}
    }

    search = search.split(/\s+/);
    // Transform UNIPROT IDs to gene names
    if (search[0] in sarsUniprot){
        if (search[0] in ['P0DTD1', 'P0DTC1']){
            return {type: 'uniprotError', content: search[0]}
        }
        search[0] = sarsUniprot[search[0]]
    }

    search[0] = search[0].toLowerCase()
    if (!sarsGenes.includes(search[0])){
        return {type: 'geneError', content: search[0]};
    }

    if (/^[0-9]+$/.test(search[1])){
        search[1] = Number(search[1]);
        return {type: 'position', content: search};
    }

    if (/^[ACDEFGHIKLMNPQRSTVWY][0-9]+[ACDEFGHIKLMNPQRSTVWY]$/.test(search[1])){
        return {type: 'id', content: search.join('_')};
    }

    return {type: 'unknownError', content: search.join(' ')};
}

function getMutIDs(search, muts){
    if (search['type'] === 'id'){
        return search['content']
    }
    return null
}

export function searchMutations(search, muts){
    return new Promise((resolve, reject) => {
        search = search.split(/[\n,;]+/).filter((i) => i !== "").map(parseSearch);
        console.log(search)
        search = search.map((i) => getMutIDs(i, muts)).filter((i) => !(i === null))
        resolve(search);
    })
}