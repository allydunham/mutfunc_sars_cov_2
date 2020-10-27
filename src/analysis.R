#!/usr/bin/env Rscript
# Utility functions for analysis

load_variants <- function(){
  columns <- cols(
    uniprot = col_character(),
    name = col_character(),
    position = col_double(),
    wt = col_character(),
    mut = col_character(),
    sift_score = col_double(),
    template = col_character(),
    total_energy = col_double(),
    ptm = col_character(),
    int_uniprot = col_character(),
    int_name = col_character(),
    int_template = col_character(),
    interaction_energy = col_double(),
    diff_interaction_energy = col_double(),
    diff_interface_residues = col_integer(),
    freq = col_double()
  )
  read_tsv('data/output/summary.tsv', col_types = columns) %>%
    mutate(log10_sift = log10(sift_score + 1e-5),
           log10_freq = log10(freq + 1e-5))
}

get_protein_limits <- function(variants){
  group_by(variants, name) %>%
    filter(position == min(position) | position == max(position)) %>%
    ungroup() %>%
    select(name, position, wt) %>%
    distinct()
}

classify_freq <- function(x){
  out <- rep('> 0.01', length(x))
  out[x < 0.01] <- '< 0.01'
  out[x < 0.001] <- '< 0.001'
  out[x < 0.0001] <- '< 0.0001'
  out[is.na(x)] <- 'Not Observed'
  out <- factor(out, levels = c('Not Observed', '< 0.0001', '< 0.001', '< 0.01', '> 0.01'))
  return(out)
}

int_colour_scale <- c(None='black', ace2='#a6cee3', nsp10='#1f78b4', nsp12='#b2df8a', nsp14='#33a02c',
                      nsp16='#fb9a99', nsp7='#e31a1c', nsp8='#fdbf6f', nsp9='#ff7f00', `40S ribosomal protein S3`='#cab2d6',
                      `40S ribosomal protein S30`='#cab2d6', `18S ribosomal RNA`='#cab2d6', `40S ribosomal protein S2`='#cab2d6',
                      `40S ribosomal protein S9`='#cab2d6', s='#6a3d9a', orf3a='#ffff99', nc='#b15928', orf9b='#ffff33')
