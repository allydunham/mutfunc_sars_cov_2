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
  select(uniprot, name, position, wt, mut, freq, ptm, sift_score, total_energy, int_name,
         diff_interaction_energy, all_atom_rel=relative_surface_accessibility) %>%
  left_join(antibody_averages, by = c('name', 'position', 'wt', 'mut')) %>%
  drop_na(mut_escape_mean) %>%
  mutate(sift_sig = ifelse(sift_score < 0.05, 'Deleterious', 'Neutral'),
         foldx_sig = ifelse(total_energy < 1, ifelse(total_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'),
         int_sig = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'))

variants_long <- select(variants, position, wt, mut, all_atom_rel, sift_sig, foldx_sig, int_name, int_sig, mut_escape_mean, mut_escape_median, mut_escape_max) %>%
  pivot_longer(starts_with('mut_escape'), names_to = 'metric', values_to = 'mut_escape', names_prefix='mut_escape_') %>%
  pivot_longer(c(sift_sig, foldx_sig, int_sig), names_to = 'tool', values_to = 'sig') %>%
  mutate(int_name = display_names[int_name],
         tool = c(sift_sig='SIFT4G', foldx_sig='FoldX', int_sig='FoldX Interface')[tool],
         tool = ifelse(!is.na(int_name) & tool == 'FoldX Interface', str_c(tool, ' (', int_name, ')'), tool),
         surface_accessible = ifelse(all_atom_rel > 30, 'Surface Residue', 'Core Residue'),
         metric = str_to_title(metric)) %>%
  drop_na(sig) %>%
  select(-int_name)

### Analysis ###
plots <- list()
plots$escape_points <- (ggplot(antibody, aes(x = position, y = mut_escape)) + 
                          geom_point(shape = 20, size = 0.5) +
                          geom_line(data = antibody_averages, mapping = aes(y = mut_escape_mean, colour = 'Mean'), size = 0.5) +
                          geom_line(data = antibody_averages, mapping = aes(y = mut_escape_median, colour = 'Median'), size = 0.5) +
                          facet_wrap(~mut, ncol = 5) +
                          scale_color_brewer(type = 'qual', palette = 'Dark2', name = '') +
                          labs(x = 'Spike Position', y = 'Escape Proportion')) %>%
  labeled_plot(units = 'cm', height = 24, width = 30)

plots$sift_cat <- filter(variants_long, tool == 'SIFT4G') %>%
  ggplot(aes(x = sig, y = mut_escape)) +
  facet_grid(cols = vars(metric), rows = vars(surface_accessible)) +
  geom_boxplot(show.legend = FALSE, fill = '#e41a1c', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Deleterious', 'Neutral'))) +
  labs(x = 'SIFT4G Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

plots$foldx_cat <- filter(variants_long, tool == 'FoldX') %>%
  ggplot(aes(x = sig, y = mut_escape)) +
  facet_grid(cols = vars(metric), rows = vars(surface_accessible)) +
  geom_boxplot(show.legend = FALSE, fill = '#e41a1c', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral'), c('Destabilising', 'Stabilising'))) +
  labs(x = 'FoldX Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

plots$int_s_cat <- filter(variants_long, tool == 'FoldX Interface (S)') %>%
  ggplot(aes(x = sig, y = mut_escape)) +
  facet_grid(cols = vars(metric), rows = vars(surface_accessible)) +
  geom_boxplot(show.legend = FALSE, fill = '#e41a1c', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral'), c('Destabilising', 'Stabilising'))) +
  labs(x = 'FoldX Interface Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

plots$int_ace2_cat <- filter(variants_long, tool == 'FoldX Interface (ACE2)') %>%
  ggplot(aes(x = sig, y = mut_escape)) +
  facet_grid(cols = vars(metric), rows = vars(surface_accessible)) +
  geom_boxplot(show.legend = FALSE, fill = '#e41a1c', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral'), c('Destabilising', 'Stabilising'))) +
  labs(x = 'FoldX Interface Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

plots$int_antibody_cat <- filter(variants_long, str_detect(tool, 'Chain')) %>%
  ggplot(aes(x = sig, y = mut_escape)) +
  facet_grid(cols = vars(metric), rows = vars(surface_accessible)) +
  geom_boxplot(show.legend = FALSE, fill = '#e41a1c', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral'), c('Destabilising', 'Stabilising'))) +
  labs(x = 'FoldX Interface Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))

plots$sift_foldx_cat <- select(variants, position, wt, mut, all_atom_rel, sift_score, total_energy, mut_escape_mean, mut_escape_max) %>%
  pivot_longer(starts_with('mut_escape'), names_to = 'metric', values_to = 'mut_escape', names_prefix='mut_escape_') %>%
  mutate(sig = ifelse(sift_score > 0.05 & total_energy > 1, 'Destabilising & Neutral', 'Not'),
         surface_accessible = ifelse(all_atom_rel > 30, 'Surface Residue', 'Core Residue'),
         metric = str_to_title(metric)) %>%
  ggplot(aes(x = sig, y = mut_escape)) +
  facet_grid(cols = vars(metric), rows = vars(surface_accessible)) +
  geom_boxplot(show.legend = FALSE, fill = '#e41a1c', outlier.shape = 20, outlier.size = 0.5, size = 0.2) +
  stat_compare_means(method = 't.test', size = 2, comparisons = list(c('Destabilising & Neutral', 'Not'))) +
  labs(x = 'Prediction', y = 'Antibody Escape Proportion') + 
  coord_cartesian(clip = 'off') +
  theme(text = element_text(size = 9))


### High escape variants
plots$high_mean_escape <- (ggplot(variants, aes(x = clamp(total_energy, upper = 10), y = mut_escape_mean,
                     colour = sift_sig, label = str_c(wt, position, mut))) + 
  geom_vline(xintercept = c(-1, 1)) +
  geom_point(shape = 20) +
  geom_point(mapping = aes(shape = int_sig), size = 2) +
  geom_text_repel(data = filter(variants, mut_escape_mean > 0.1), colour = 'black', show.legend = FALSE) +
  labs(x = expression(Delta*Delta*'G (Clamped to < 10)'), y = 'Mean Escape Proportion') +
  scale_colour_manual(values = c(Deleterious = 'red', Neutral = 'black'), name = 'SIFT4G Prediction') +
  scale_shape_manual(values = c(Destabilising=8, Neutral=4, Stabilising=3), na.translate = FALSE,
                     name = 'FoldX Interface Prediction')) %>%
  labeled_plot(units = 'cm', height = 20, width = 25)

plots$high_max_escape <- (ggplot(variants, aes(x = clamp(total_energy, upper = 10), y = mut_escape_max,
                                               colour = sift_sig, label = str_c(wt, position, mut))) + 
                             geom_vline(xintercept = c(-1, 1)) +
                             geom_point(shape = 20) +
                             geom_point(mapping = aes(shape = int_sig), size = 2) +
                             geom_text_repel(data = filter(variants, mut_escape_max > 0.4), colour = 'black', show.legend = FALSE) +
                             labs(x = expression(Delta*Delta*'G (Clamped to < 10)'), y = 'Max Escape Proportion') +
                             scale_colour_manual(values = c(Deleterious = 'red', Neutral = 'black'), name = 'SIFT4G Prediction') +
                             scale_shape_manual(values = c(Destabilising=8, Neutral=4, Stabilising=3), na.translate = FALSE,
                                                name = 'FoldX Interface Prediction')) %>%
  labeled_plot(units = 'cm', height = 20, width = 25)

### Experiment vs FoldX predictions
plots$foldx_vs_experiment <- filter(variants, str_detect(int_name, 'chain')) %>%
  ggplot(aes(x = mut_escape_max, y = diff_interaction_energy, colour = int_name)) +
  geom_point()

plots$foldx_vs_experiment_cat <- filter(variants, str_detect(int_name, 'chain')) %>%
  mutate(exp_cat = ifelse(mut_escape_max > 0.1, 'Mean Escape > 0.1', 'Mean Escape ≤ 0.1')) %>%
  ggplot(aes(x = exp_cat, y = diff_interaction_energy)) +
  geom_boxplot(fill = 'red') +
  stat_compare_means(comparisons = list(c('Mean Escape > 0.1', 'Mean Escape ≤ 0.1')))

### Save plots ###
save_plotlist(plots, 'figures/antibody_escape', verbose = 2)
