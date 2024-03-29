#!/usr/bin/env Rscript
# Analyse variants found in Kemp et al. 2020 (https://www.medrxiv.org/content/10.1101/2020.12.05.20241927v2.full.pdf)
source('src/config.R')
source('src/analysis.R')

variants <- load_variants()

# Remdesivir at day 41, 54 & 83
# Covalenscent Plasma at day 66 (x2) and 83
# Death at day 102
# Initial stain is lineage B, carrying S D614G

# Day 45: orf7a T39I reaches 77%
# SIFT4G significant but low quality
view_variants(variants, c('orf7a T39I'))

# Day 53: S N501Y at 33%
# Destabilising of structure and ACE2 interface
view_variants(variants, c('s N501Y'))

# Day 66: nsp2 I513T / RdRp V157L reach ~100%, outcompeting S N501Y
# RdRp variant destabilises structure and has a significant SIFT4G prediction
view_variants(variants, c('nsp2 I513T', 'nsp12 F157L')) # nsp12 has F at 157 in our dataset?

# Day 66 - 82: S D796H and H69/V70 deletions rise to majority then fall to 10%
# D796H has a significant SIFT4G score, position 69 contributes significantly to structure (2.35 mean total energy)
view_variants(variants, c('s D796H'))
filter(variants, name == 's', position %in% 69:70)

# Day 86 - 89: S Y200H, S T240I, nsp2 I513T, RdRp V157L & nsp15 N177S rise to prominence then start to drop off
# S Y200H destabilises the S complex, S 240 is a phosphosite and destabilises the structure, nsp12 variant is destabilising
view_variants(variants, c('s Y200H', 's T240I', 'nsp2 I513T', 'nsp12 F157L', 'nsp15 N177S'))

# Day 93: S P330S, S W64G rise and S Y200H/T240I and the double deletion fall to <2%
# Both very destabilising (>3 kJ/mol)
view_variants(variants, c('s P330S', 's W64G'))

# Day 95 (after 3rd CP): S D796H and double deletion re-emerges
# Significant SIFT4G score for s D796H and 69 has strong structural effect
view_variants(variants, c('s D796H'))
