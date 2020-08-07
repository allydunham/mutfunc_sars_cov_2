#!/usr/bin/env Rscript
# Analyse combined dataset - both for sanity checks and for discovery
source('src/config.R')

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
variants <- read_tsv('data/output/summary.tsv', col_types = columns) %>%
  mutate(log10_sift = log10(sift_score + 1e-5))

plots <- list()

### Histograms ###
plots$freq_hist <- ggplot(variants, aes(x = log10(freq))) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = 'Log<sub>10</sub>Frequency',
       y = 'Count') +
  theme(axis.title.x = element_markdown())

plots$sift_hist <- ggplot(variants, aes(x = log10_sift)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = 'Log<sub>10</sub>SIFT4G Score',
       y = 'Count') +
  theme(axis.title.x = element_markdown())

plots$foldx_hist <- ggplot(variants, aes(x = total_energy)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = expression('FoldX'~Delta*Delta*'G'),
       y = 'Count')

plots$int_hist <- ggplot(variants, aes(x = diff_interaction_energy)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = expression('FoldX Interface'~Delta*Delta*'G'),
       y = 'Count')

plots$int_residues_hist <- ggplot(variants, aes(x = diff_interface_residues)) +
  geom_bar(fill = 'cornflowerblue') +
  scale_x_continuous(breaks = min(variants$diff_interface_residues, na.rm = TRUE):max(variants$diff_interface_residues, na.rm = TRUE)) +
  labs(x = 'Change in FoldX Interface Residue Count',
       y = 'Count') +
  theme(axis.title.x = element_markdown())

### Factors against each other ###

### Save plots ###
save_plotlist(plots, 'figures/', verbose = 2, overwrite = 'all')

