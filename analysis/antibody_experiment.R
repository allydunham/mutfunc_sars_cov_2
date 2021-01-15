#!/usr/bin/env Rscript
# Analyse results of Antibody binding DMS
source('src/config.R')
source('src/analysis.R')

### Load Data ###
antibody <- read_csv('data/greaney_spike_antibody.csv') %>%
  tidyr::extract(condition, c('subject', 'day'), "subject ([A-Z]) \\(day ([0-9]*)\\)", convert=TRUE) %>%
  rename(position=site, wt=wildtype, mut=mutation)

antibody_averages <- group_by(antibody, position, wt, mut) %>%
  summarise(mut_escape_mean = mean(mut_escape, na.rm = TRUE),
            mut_escape_sd = sd(mut_escape, na.rm = TRUE),
            mut_escape_median = median(mut_escape, na.rm = TRUE),
            mut_escape_max = max(mut_escape, na.rm = TRUE),
            mut_escape_min = min(mut_escape, na.rm = TRUE),
            .groups = 'drop') %>%
  mutate(name='s')

surface_accessibility <- read_tsv('data/output/surface_accessibility.tsv') %>%
  select(uniprot, name, position, wt, side_chain_abs)

variants <- load_variants() %>%
  select(uniprot, name, position, wt, mut, freq, sift_score, total_energy, int_name, diff_interaction_energy) %>%
  left_join(antibody_averages, by = c('name', 'position', 'wt', 'mut')) %>%
  left_join(surface_accessibility, by = c('uniprot', 'name', 'position', 'wt')) %>%
  drop_na(mut_escape_mean) %>%
  mutate(sift_sig = ifelse(sift_score < 0.05, 'Deleterious', 'Neutral'),
         foldx_sig = ifelse(total_energy < 1, ifelse(total_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'),
         int_sig = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising')) %>%
  select(position, wt, mut, side_chain_abs, sift_sig, foldx_sig, int_name, int_sig, mut_escape_mean, mut_escape_median, mut_escape_max) %>%
  pivot_longer(starts_with('mut_escape'), names_to = 'metric', values_to = 'mut_escape', names_prefix='mut_escape_') %>%
  pivot_longer(c(sift_sig, foldx_sig, int_sig), names_to = 'tool', values_to = 'sig') %>%
  mutate(int_name = str_to_upper(int_name),
         tool = c(sift_sig='SIFT4G', foldx_sig='FoldX', int_sig='FoldX Interface')[tool],
         tool = ifelse(!is.na(int_name) & tool == 'FoldX Interface', str_c(tool, ' (', int_name, ')'), tool),
         surface_accessible = ifelse(side_chain_abs > 25, 'Surface Residue', 'Core Residue'),
         metric = str_to_title(metric)) %>%
  drop_na(sig) %>%
  select(-int_name)

### Analysis ###
plots <- list()
plots$sift_cat <- filter(variants, tool == 'SIFT4G') %>%
  ggplot(aes(x = sig, y = mut_escape)) +
  facet_grid(cols = vars(metric), rows = vars(surface_accessible)) +
  geom_boxplot(show.legend = FALSE, fill = '#e41a1c', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Deleterious', 'Neutral'))) +
  labs(x = 'SIFT4G Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

plots$foldx_cat <- filter(variants, tool == 'FoldX') %>%
  ggplot(aes(x = sig, y = mut_escape)) +
  facet_grid(cols = vars(metric), rows = vars(surface_accessible)) +
  geom_boxplot(show.legend = FALSE, fill = '#e41a1c', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral'), c('Destabilising', 'Stabilising'))) +
  labs(x = 'FoldX Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

plots$int_s_cat <- filter(variants, tool == 'FoldX Interface (S)') %>%
  ggplot(aes(x = sig, y = mut_escape)) +
  facet_grid(cols = vars(metric), rows = vars(surface_accessible)) +
  geom_boxplot(show.legend = FALSE, fill = '#e41a1c', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral'), c('Destabilising', 'Stabilising'))) +
  labs(x = 'FoldX Interface Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

plots$int_ace2_cat <- filter(variants, tool == 'FoldX Interface (ACE2)') %>%
  ggplot(aes(x = sig, y = mut_escape)) +
  facet_grid(cols = vars(metric), rows = vars(surface_accessible)) +
  geom_boxplot(show.legend = FALSE, fill = '#e41a1c', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral'), c('Destabilising', 'Stabilising'))) +
  labs(x = 'FoldX Interface Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

### Save plots ###
save_plotlist(plots, 'figures/antibody_escape', verbose = 2, overwrite = 'all')
