#!/usr/bin/env Rscript
# Generate figure 2 (Interface frequencies, Spike DMS, Human interface variant freqs?, In silico DMS?)
source('src/config.R')
source('src/analysis.R')

variants <- load_variants()
spike <- read_csv('data/starr_ace2_spike.csv') %>% 
  mutate(uniprot = 'P0DTC2', name = 's') %>%
  select(uniprot, name, position = site_SARS2, position_rbd = site_RBD, wt = wildtype, mut = mutant, binding=bind_avg, expression=expr_avg) %>%
  left_join(variants, by = c('uniprot', 'name', 'position', 'wt', 'mut'))

### Panel - Frequency
sig_vars <- select(variants, name, position, wt, mut, int_name, freq, diff_interaction_energy) %>% 
  drop_na(int_name, freq) %>%
  mutate(name = display_names[name],
         int_name = display_names[int_name],
         int = str_c(name, ' - ', int_name), 
         sig = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'))

p_freq <- ggplot(mapping = aes(x = freq, y = int)) +
  geom_point(data = filter(sig_vars, sig == 'Neutral'), mapping = aes(colour = 'Neutral'), shape = 20, size = 0.4, position = position_jitter(height = 0.2)) +
  geom_point(data = filter(sig_vars, sig == 'Stabilising'), mapping = aes(colour = 'Stabilising'), shape = 16, size = 0.8) +
  geom_point(data = filter(sig_vars, sig == 'Destabilising'), mapping = aes(colour = 'Destabilising'), shape = 16, size = 0.8) +
  scale_x_log10() +
  scale_colour_manual(name = '', values = c(Neutral='gray30', Stabilising='#377eb8', Destabilising='#e41a1c')) +
  labs(x = 'Variant Frequency') +
  theme(axis.title.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(linetype = 'dotted', colour = 'grey'),
        legend.position = 'top',
        legend.margin = margin(l = -5, b = -5, unit = 'mm'),
        legend.spacing.x = unit(-1, 'mm'))

### Panel - Stability
p_stability <- select(variants, name, position, wt, mut, int_name, diff_interaction_energy) %>% 
  mutate(name = display_names[name],
         int_name = display_names[int_name],
         int = str_c(name, ' - ', int_name)) %>%
  group_by(name) %>%
  mutate(pos_prop = position / max(position),
         width = 1 / max(position)) %>%
  filter(!all(is.na(int))) %>%
  group_by(int, position, pos_prop, width) %>%
  summarise(mean_ddg = mean(clamp(diff_interaction_energy, -5, 5)), .groups='drop') %>%
  drop_na() %>%
  ggplot(aes(x = pos_prop, y = int, fill = mean_ddg, width = width)) +
  geom_tile(height=0.5, show.legend = FALSE) + 
  scale_fill_gradientn(colours = c('#5e4fa2', '#3288bd', '#66c2a5', '#abdda4', '#e6f598', '#ffffbf',
                                   '#fee08b', '#fdae61', '#f46d43', '#d53e4f', '#9e0142'),
                       values = scales::rescale(-5:5, to=0:1), na.value = 'white',
                       limits = c(-5, 5), name="Mean interface &Delta;&Delta;G (kJ.mol<sup>-1</sup>)<br>Clamped to &plusmn;5") +
  labs(x = 'Proportional Position') +
  theme(legend.title = element_markdown(),
        axis.title.y = element_blank(), axis.ticks.y = element_blank(),
        panel.grid.major.y = element_line(linetype = 'solid', colour = 'grey'),
        panel.grid.major.x = element_line(linetype = 'dotted', colour = 'grey'))

### Panel - Spike DMS vs. FoldX
p_spike_dms <- select(spike, position, wt, mut, binding, int_name, diff_interaction_energy) %>%
  filter(int_name == 'ace2') %>%
  mutate(sig = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising')) %>%
  ggplot(aes(x = sig, y = binding)) +
  geom_boxplot(fill = '#984ea3') +
  stat_compare_means(comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral')), method = 't.test', size = 2) +
  coord_cartesian(clip = 'off') +
  labs(x = 'FoldX Interface Prediction', y = 'ACE2 Binding Fitness')

### Panel - Spike DMS model
dms_models <- select(spike, binding, ddg=total_energy, int_ddg = diff_interaction_energy, sift_score) %>%
  mutate(binding_sig = binding < log10(0.5)) %>% # Binding rate half wt
  pivot_longer(c(-binding, -binding_sig), names_to = 'tool', values_to = 'score') %>%
  group_by(tool) %>%
  group_modify(~calc_roc(., binding_sig, score, greater = .y$tool != 'sift_score'))

p_roc <- ggplot(dms_models, aes(x = fpr, y = tpr, colour = tool)) +
  geom_step(direction = 'hv') +
  geom_abline(slope = 1, linetype = 'dashed', colour = 'black') +
  labs(x = 'False Positive Rate', y = 'True Positive Rate') +
  scale_colour_brewer(type = 'qual', palette = 'Dark2', name = '',
                      labels = c(ddg=expression(Delta*Delta*G),
                                 int_ddg=expression('Interface'~Delta*Delta*G),
                                 sift_score='SIFT4G Score')) +
  # Interfaces
  annotate('segment', x = 0.5439189, y = 0.6075949, xend = 0.57, yend = 0.45) +
  annotate('text', x = 0.57, y = 0.44, label = 'Delta*Delta*"G Threshold"%~~%0', hjust = 0.1, vjust = 1, parse = TRUE, size = 2) +
  theme(legend.position = 'top',
        legend.margin = margin(l = -5, b = -5, unit = 'mm'),
        legend.spacing.x = unit(0, 'mm'))

p_pr <- ggplot(dms_models, aes(x = tpr, y = precision, colour = tool)) +
  geom_step(direction = 'hv') +
  geom_hline(yintercept = 0.5, linetype = 'dashed', colour = 'black') +
  labs(x = 'False Positive Rate', y = 'True Positive Rate') +
  scale_colour_brewer(type = 'qual', palette = 'Dark2', name = '',
                      labels = c(ddg=expression(Delta*Delta*G),
                                 int_ddg=expression('Interface'~Delta*Delta*G),
                                 sift_score='SIFT4G Score'))

### Panel - Orf3a in vitro DMS
is_dms <- select(variants, name, position, wt, mut, log10_freq, int_name, diff_interaction_energy) %>%
  filter(name == 'orf3a') %>%
  mutate(wt_int = factor(wt, levels = sort(Biostrings::AA_STANDARD)) %>% as.integer(),
         mut_int = factor(mut, levels = sort(Biostrings::AA_STANDARD)) %>% as.integer())

is_dms_summary <- group_by(is_dms, position, wt_int) %>%
  summarise(mean_ddg = mean(diff_interaction_energy))

orf3a_regions <- tibble(colour = c('#1b9e77', '#d95f02', '#7570b3', '#e7298a', '#66a61e', '#e6ab02', '#1f78b4'),
                        start = c(42, 80, 104, 141, 159, 184, 214), end = c(67, 97, 123, 146, 171, 191, 235))
# pmap(list(orf3a_regions$colour, orf3a_regions$start, orf3a_regions$end), ~str_c('color ', str_replace(..1, '#', '0x'), ', ', str_c(str_c('resi ', ..2:..3), collapse = ' or '))) %>% unlist() %>% cat(sep='\n')

p_is_dms <- ggplot() + 
  # Scale covers ddG heatmap, mean row and freq plot
  scale_y_continuous(limits = c(0, 275), breaks = seq(0, 275, 50), minor_breaks = seq(25, 275, 50), ) +
  scale_x_continuous(breaks = c(1:20, 22, 24:29), limits = c(0, 29),
                     labels = c(sort(Biostrings::AA_STANDARD), expression(bar(Delta*Delta*G)), -5:0)) +
  
  # ddG heatmap & means row
  geom_raster(data = is_dms, mapping = aes(x = mut_int, y = position, fill = clamp(diff_interaction_energy, lower = -5, upper = 5))) +
  geom_raster(data = is_dms_summary, mapping = aes(x = wt_int, y = position), fill = 'grey') +
  geom_raster(data = is_dms_summary, mapping = aes(x = 22, y = position, fill = mean_ddg)) +
  scale_fill_gradientn(colours = c('#5e4fa2', '#3288bd', '#66c2a5', '#abdda4', '#e6f598', '#ffffbf',
                                   '#fee08b', '#fdae61', '#f46d43', '#d53e4f', '#9e0142'),
                       values = scales::rescale(-5:5, to=0:1), na.value = 'white',
                       limits = c(-5, 5), name="<img src='figures/figures/parts/orf3a_regions.png' width='120' /><br><br><br>Interface &Delta;&Delta;G (kJ.mol<sup>-1</sup>)<br>Clamped to &plusmn;5") +
  # Add WT to legend
  geom_point(aes(colour = 'WT'), y = -100, x = -100, shape = 15, size = 5) +
  scale_colour_manual(name='', values = c(WT='grey')) +
  
  # Add regions
  annotate('segment', x = 23.75, xend = 23.75, size = 1.5, y = orf3a_regions$start, yend = orf3a_regions$end, colour = orf3a_regions$colour) +
  
  # Freq plot
  geom_vline(xintercept = 24:29, linetype = 'dotted', colour = 'grey') +
  geom_segment(data = filter(is_dms, int_name == 'orf3a'), mapping = aes(y=position, yend=position, x = 29 + log10_freq),
               xend = 24, colour = '#c070cc') +
  geom_point(data = filter(is_dms, int_name == 'orf3a'), mapping = aes(y=position, x = 29 + log10_freq), colour = '#984ea3', shape=20, size = 0.5) +
  annotation_custom(text_grob(expression('log'[10]~'Frequency'), size = 6.5), ymin = -14, ymax = -14, xmin = 26.5, xmax = 26.5) +

  # Misc
  labs(y = 'Orf3a Position') +
  coord_cartesian(clip = 'off', expand = FALSE) +
  theme(axis.title.x = element_blank(),
        axis.ticks.x = element_blank(),
        panel.grid.major.y = element_blank(),
        plot.margin = unit(c(2,2,5,2), 'mm'),
        legend.title = element_markdown())

### Assemble figure
size <- theme(text = element_text(size = 8))
p1 <- p_freq + labs(tag = 'A') + size
p2 <- p_spike_dms + labs(tag = 'B') + size
p3 <- p_roc + labs(tag = 'C') + size
p4 <- p_is_dms + labs(tag = 'D') + size

figure <- multi_panel_figure(width = c(60, 60, 60), height = c(50, 65, 65), panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1) %>%
  fill_panel(p2, row = 1, column = 2) %>%
  fill_panel(p3, row = 1, column = 3) %>%
  fill_panel(p4, row = 2:3, column = 2:3)
ggsave('figures/figures/figure2.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/figure2.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
