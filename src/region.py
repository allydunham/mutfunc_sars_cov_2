"""
Class representing a region of a protein
"""

class ProteinRegion:
    """
    A protein region

    chain: string chain id
    positions: string representation of protein positions. Comma separated list of
    individual positions and X:Y (inclusive) ranges. If none all positions on the chain
    are accepted
    """
    def __init__(self, chain, positions=None, accept_hetero=False):
        self.chain = str(chain)
        self.accept_hetero = accept_hetero
        self.positions_str = positions

        if positions is None:
            self.positions = None

        else:
            self.positions = []
            for i in positions.split(','):
                if ':' in i:
                    i = i.split(':')
                    self.positions.extend(range(int(i[0]), int(i[1]) + 1))

                else:
                    self.positions.append(int(i))

    def __repr__(self):
        return (f'ProteinRegion({self.chain}, {self.positions_str}, '
                f'accept_hetero={self.accept_hetero})')

    def __str__(self):
        return self.__repr__()

    def __contains__(self, item):
        try:
            chain = item.full_id[2]
            position = item.id[1]
            hetero = not item.id[0] == ' '
        except AttributeError:
            warnings.warn((f'Tried to check membership of "{residue}".'
                           'Only biopython Residues can be in a ProteinRegion'))
            return False

        return (self.chain == chain and
                (self.positions is None or position in self.positions) and
                (not hetero or self.accept_hetero))
