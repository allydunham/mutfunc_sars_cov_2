#!/usr/bin/env Rscript
# Generate figure 2 (Interface frequencies, Spike DMS, Human interface variant freqs?, In silico DMS?)
source('src/config.R')
source('src/analysis.R')

variants <- load_variants()
spike <- read_csv('data/starr_ace2_spike.csv') %>% 
  mutate(uniprot = 'P0DTC2', name = 's') %>%
  select(uniprot, name, position = site_SARS2, position_rbd = site_RBD, wt = wildtype, mut = mutant, binding=bind_avg, expression=expr_avg) %>%
  left_join(variants, by = c('uniprot', 'name', 'position', 'wt', 'mut'))

### Panel - Frequency vs FoldX
p_freq <- select(variants, position, wt, mut, freq, int_name, diff_interaction_energy) %>%
  drop_na(int_name) %>%
  mutate(freq_cat = classify_freq(freq)) %>%
  group_by(freq_cat) %>%
  summarise(mean = mean(diff_interaction_energy),
            sd = sd(diff_interaction_energy)) %>%
  ggplot() +
  geom_segment(mapping = aes(x = freq_cat, xend = freq_cat, y = mean - sd, yend = mean + sd), colour = '#984ea3', size = 0.5) +
  geom_point(mapping = aes(x = freq_cat, y = mean), colour = '#984ea3') +
  geom_hline(yintercept = 1, linetype = 'dotted', colour = 'black') +
  geom_hline(yintercept = -1, linetype = 'dotted', colour = 'black') +
  labs(x = 'Variant Frequency (%)', y = expression('FoldX Interface'~Delta*Delta*G~'(kj'%.%'mol'^-1*')'))

### Panel - Spike DMS vs. FoldX
p_spike_dms <- select(spike, position, wt, mut, binding, int_name, diff_interaction_energy) %>%
  filter(int_name == 'ace2') %>%
  mutate(sig = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising')) %>%
  ggplot(aes(x = sig, y = binding)) +
  geom_boxplot(fill = '#984ea3') +
  stat_compare_means(comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral')), method = 't.test', size = 2) +
  labs(x = 'FoldX Interface Prediction', y = 'Spike DMS ACE2 Binding Fitness')

### Assemble figure
size <- theme(text = element_text(size = 8))
p1 <- p_freq + labs(tag = 'A') + size
p2 <- p_spike_dms + labs(tag = 'B') + size

figure <- multi_panel_figure(width = 183, height = 183, columns = 3, rows = 3,
                              panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1) %>%
  fill_panel(p2, row = 1, column = 2)
ggsave('figures/figures/figure2.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/figure2.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
