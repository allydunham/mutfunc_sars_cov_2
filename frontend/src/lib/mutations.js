export function makeMutKey(mut){
    return [mut['uniprot'], '_', mut['name'], '_',
            mut['position'], mut['wt'], mut['mut']].join('')
}
