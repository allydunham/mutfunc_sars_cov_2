export function makeMutKey(mut){
    return [mut['name'], '_', mut['wt'], mut['position'], mut['mut']].join('')
}
