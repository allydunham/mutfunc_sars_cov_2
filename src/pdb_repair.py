"""
Function to repair SWISS-Model PDB files for use with FoldX
"""
import string

LETTERS = string.ascii_uppercase + string.ascii_lowercase

def chains_to_letters(chains):
    """
    Make a dictionary converting chain non-letter symbols into letters (since only
    these are supported by FoldX)
    """
    chain_map = {i: i for i in chains if i in LETTERS + ' '}
    bad_chains = [i for i in chains if not i in LETTERS + ' ']
    remaining_letters = [i for i in LETTERS if not i in chain_map.keys()]

    if len(remaining_letters) < len(bad_chains):
        raise ValueError(('Exhausted the allowed chain IDs - more numerical '
                          'chains than remaining letters'))

    for i, chain in enumerate(bad_chains):
        chain_map[chain] = remaining_letters[i]

    return chain_map


