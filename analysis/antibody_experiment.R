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

variants <- load_variants() %>%
  select(uniprot, name, position, wt, mut, freq, sift_score, total_energy, int_name, diff_interaction_energy) %>%
  left_join(antibody_averages, by = c('name', 'position', 'wt', 'mut')) %>%
  drop_na(mut_escape_mean) %>%
  mutate(sift_sig = ifelse(sift_score < 0.05, 'Deleterious', 'Neutral'),
         foldx_sig = ifelse(total_energy < 1, ifelse(total_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'),
         int_sig = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'))

### Analysis ###
plots <- list()
plots$sift_cat <- select(variants, sift_sig, mut_escape_mean, mut_escape_median, mut_escape_max) %>%
  pivot_longer(-sift_sig, names_to = 'metric', values_to = 'mut_escape', names_prefix='mut_escape_') %>%
  ggplot(aes(x = sift_sig, y = mut_escape)) +
  facet_wrap(~metric) +
  geom_boxplot(show.legend = FALSE, fill = '#e41a1c', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Deleterious', 'Neutral'))) +
  labs(x = 'SIFT4G Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

plots$foldx_cat <- select(variants, foldx_sig, mut_escape_mean, mut_escape_median, mut_escape_max) %>%
  pivot_longer(-foldx_sig, names_to = 'metric', values_to = 'mut_escape', names_prefix='mut_escape_') %>%
  ggplot(aes(x = foldx_sig, y = mut_escape)) +
  facet_wrap(~metric) +
  geom_boxplot(show.legend = FALSE, fill = '#377eb8', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral'), c('Destabilising', 'Stabilising'))) +
  labs(x = 'FoldX Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

plots$int_cat <- select(variants, int_name, int_sig, mut_escape_mean, mut_escape_median, mut_escape_max) %>%
  drop_na(int_sig) %>%
  pivot_longer(mut_escape_mean:mut_escape_max, names_to = 'metric', values_to = 'mut_escape', names_prefix='mut_escape_') %>%
  ggplot(aes(x = int_sig, y = mut_escape)) +
  facet_grid(rows = vars(int_name), cols = vars(metric)) +
  geom_boxplot(show.legend = FALSE, fill = '#4daf4a', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral'), c('Destabilising', 'Stabilising'))) +
  labs(x = 'FoldX Interface Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

### Save plots ###
save_plotlist(plots, 'figures/antibody_escape', verbose = 2, overwrite = 'all')
