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

int_colour_scale <- c(None='black', ace2='#1b9e77', nsp10='#d95f02', nsp12='#7570b3', nsp14='#e7298a',
                      nsp16='#66a61e', nsp7='#e6ab02', nsp8='#a6761d', nsp9='#666666')
