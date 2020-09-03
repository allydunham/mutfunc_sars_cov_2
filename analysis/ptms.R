#!/usr/bin/env Rscript
# Analyse PTM Positions
source('src/config.R')
source('src/analysis.R')

### Import Data ###
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
  mutate(log10_sift = log10(sift_score + 1e-5),
         log10_freq = log10(freq + 1e-5))

sift <- read_tsv('data/output/sift.tsv')
foldx <- read_tsv('data/output/foldx.tsv')

ev_name_map = c(envelope='e', membrane='m', nsp1='nsp1', nsp10='nsp10', nsp11='nsp11', Nsp12='nsp12', nsp13='nsp13', nsp14='nsp14',
                nsp15='nsp15', Nsp15='nsp15', nsp16='nsp16', nsp2='nsp2', nsp3='nsp3', nsp4='nsp4', nsp5='nsp5', nsp6='nsp6', Nsp7='nsp7',
                nsp8='nsp8', nsp9='nsp9', nucleocapsid='nc', spike='s')
evcouplings <- dir('data/evcouplings/') %>%
  set_names() %>%
  map(~suppressMessages(read_csv(str_c('data/evcouplings/', .)))) %>%
  bind_rows(.id = 'name') %>%
  mutate(name = ev_name_map[str_split(name, '[_-]', simplify = TRUE)[,1]]) %>%
  select(-segment, -mutant, position=pos, mut=subs)

protein_limits <- group_by(variants, name) %>%
  filter(position == min(position) | position == max(position)) %>%
  ungroup() %>%
  select(name, position, wt) %>%
  distinct()

### Analyse ###
plots <- list()

plots$vs_freq <- mutate(variants, ptm = ifelse(is.na(ptm), 'None', str_to_title(ptm))) %>%
  ggplot(aes(x = log10(freq), colour = ptm)) +
  geom_line(stat = 'density') +
  scale_colour_brewer(name = 'PTM', palette = 'Set1', type = 'qual') +
  labs(x = expression(log[10](Frequency)), y = 'Density')

## Observed phosphomutants
observed <- group_by(variants, name) %>%
  filter(!all(is.na(ptm) | is.na(freq))) %>%
  filter((position == 1 & mut == 'A') | (position == max(position, na.rm = TRUE) & mut == 'A') | (!is.na(ptm) & !is.na(freq))) %>%
  ungroup() %>%
  select(name, position, wt, mut, ptm, log10_freq) %>%
  mutate(mimic = mut %in% c('E', 'D'),
         lab = ifelse(mimic, str_c(wt, ' %->% ', mut), NA))

mn_pho <- floor(min(observed$log10_freq, na.rm = TRUE))
plots$observed_phos <- (ggplot(filter(observed, !is.na(ptm))) +
                          facet_wrap(~name, ncol = 1, scales = 'free_x') +
                          geom_point(data = observed, mapping = aes(x = position), y = 0, alpha = 0) +
                          geom_text_repel(aes(x = position, y = log10_freq, label = lab), parse=TRUE, nudge_x = 77, na.rm = TRUE) +
                          geom_point(aes(x = position, y = log10_freq, colour = wt)) +
                          geom_segment(aes(x = position, xend = position, yend = log10_freq, colour = wt), y = mn_pho) +
                          scale_colour_brewer(name = 'WT', type = 'qual', palette = 'Dark2') +
                          lims(y = c(mn_pho, 0)) +
                          labs(x = 'Position', y = expression(log[10]~Frequency))) %>%
  labeled_plot(units = 'cm', width = 25, height = 5 * n_distinct(observed$name))

### Save plots ###
save_plotlist(plots, 'figures/ptms', verbose = 2, overwrite = 'all')
