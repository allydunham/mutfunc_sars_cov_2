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
  ggplot() +
  geom_boxplot(mapping = aes(x = freq_cat, y = diff_interaction_energy), fill = '#984ea3') +
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

### Panel - Orf3a in vitro DMS
is_dms <- select(variants, name, position, wt, mut, log10_freq, int_name, diff_interaction_energy) %>%
  filter(name == 'orf3a') %>%
  mutate(wt_int = factor(wt, levels = sort(Biostrings::AA_STANDARD)) %>% as.integer(),
         mut_int = factor(mut, levels = sort(Biostrings::AA_STANDARD)) %>% as.integer())

is_dms_summary <- group_by(is_dms, position, wt_int) %>%
  summarise(mean_ddg = mean(diff_interaction_energy))

orf3a_regions <- tibble(colour = c('#1b9e77', '#d95f02', '#7570b3', '#e7298a', '#66a61e', '#e6ab02', '#a6761d'),
                        start = c(43, 81, 105, 142, 160, 185, 215), end = c(66, 96, 122, 145, 170, 190, 234))
  
p_is_dms <- ggplot() + 
  # Scale covers ddG heatmap, mean row and freq plot
  scale_x_continuous(limits = c(0, 275), breaks = seq(0, 275, 50), minor_breaks = seq(25, 275, 50)) +
  scale_y_continuous(breaks = c(1:20, 21.5, 23:28), limits = c(0, 28),
                     labels = c(sort(Biostrings::AA_STANDARD), expression(bar(Delta*Delta*G)), -5:0)) +
  
  # ddG heatmap & means row
  geom_raster(data = is_dms, mapping = aes(x = position, y = mut_int, fill = clamp(diff_interaction_energy, lower = -5, upper = 5))) +
  geom_raster(data = is_dms_summary, mapping = aes(x = position, y = wt_int), fill = 'grey') +
  geom_raster(data = is_dms_summary, mapping = aes(x = position, y = 21.5, fill = mean_ddg)) +
  scale_fill_gradientn(colours = c('#5e4fa2', '#3288bd', '#66c2a5', '#abdda4', '#e6f598', '#ffffbf',
                                   '#fee08b', '#fdae61', '#f46d43', '#d53e4f', '#9e0142'),
                       values = scales::rescale(-5:5, to=0:1), na.value = 'white',
                       limits = c(-5, 5), name=expression('Interface'~Delta*Delta*G~'(kj'%.%'mol'^-1*', clamped to'%+-%5*')')) +
  # Add WT to legend
  geom_point(aes(colour = 'WT'), x = -100, y = 30, shape = 15, size = 3) +
  scale_colour_manual(name='', values = c(WT='grey')) +
  
  # Add regions
  annotate('segment', y = 22.5, yend = 22.5, size = 1.5, x = orf3a_regions$start, xend = orf3a_regions$end, colour = orf3a_regions$colour) +
  annotate('richtext', label = "<img src='figures/figures/parts/orf3a_regions.png' width='110' />", x = 275, y = 24, fill = NA, label.color = NA) +
  
  # Freq plot
  geom_hline(yintercept = 23:28, linetype = 'dotted', colour = 'grey') +
  geom_segment(data = filter(is_dms, int_name == 'orf3a'), mapping = aes(x=position, xend=position, y = 28 + log10_freq),
               yend = 23, colour = '#c070cc') +
  geom_point(data = filter(is_dms, int_name == 'orf3a'), mapping = aes(x=position, y = 28 + log10_freq), colour = '#984ea3', shape=20) +
  annotation_custom(text_grob(expression('log'[10]~'Frequency'), rot = 90, size = 5), xmin = -9, xmax = -9, ymin = 25.5, ymax = 25.5) +

  # Misc
  labs(x = 'Orf3a Position') +
  coord_cartesian(clip = 'off', expand = FALSE) +
  theme(axis.title.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_blank(),
        plot.margin = unit(c(10,20,2,5), 'mm'),
        legend.position = 'bottom',
        legend.title = element_text(vjust = 0.9))

### Assemble figure
size <- theme(text = element_text(size = 8))
p1 <- p_freq + labs(tag = 'A') + size
p2 <- p_spike_dms + labs(tag = 'B') + size
p3 <- p_is_dms + labs(tag = 'C') + size

figure <- multi_panel_figure(width = 183, height = c(50, 50, 90), columns = 3,
                              panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1) %>%
  fill_panel(p2, row = 2, column = 3) %>%
  fill_panel(p3, row = 3, column = 1:3)
ggsave('figures/figures/figure2.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/figure2.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
