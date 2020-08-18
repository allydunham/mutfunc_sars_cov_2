// Functions to check if mutations fulfil various conditions for deleteriousness
export const conservationText = "SIFT Score < 0.05"
export const conservation = (mut) => {
    return(mut['sift_score'] < 0.05)
}

export const structureText = "|FoldX \u0394\u0394G| > 1"
export const structure = (mut) => {
    return(Math.abs(mut['total_energy']) > 1)
}

export const ptmText = "PTM Site"
export const ptm = (mut) => {
    return(mut['ptm'] !== '')
}

export const interfacesText = "Protein Interface Site"
export const interfaces = (mut) => {
    return(mut['int_name'] !== '')
}

export const frequencyText = "Observed Frequency > 0.01"
export const frequency = (mut) => {
    return(mut['freq'] > 0.01)
}

export const any = (mut) => {
    return(conservation(mut) || structure(mut) || ptm(mut) || interfaces(mut) || frequency(mut))
}

