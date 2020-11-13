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
p_freqs_per_int <- select(variants, name, position, wt, mut, int_name, freq, diff_interaction_energy) %>% 
  drop_na(int_name) %>%
  mutate(int_name = ifelse(str_detect(int_name, 'ribosomal'), '40s', int_name)) %>%
  group_by(name, int_name) %>%
  summarise(positions = n_distinct(position),
            muts_per_pos = sum(freq, na.rm = TRUE) / positions,
            mean_ddg = mean(diff_interaction_energy * freq, na.rm = TRUE),
            .groups = 'drop') %>%
  mutate(mean_ddg = ifelse(is.na(mean_ddg), 0, mean_ddg),
         name = display_names[name],
         int_name = display_names[int_name],
         int = str_c(name, ' - ', int_name)) %>%
  ggplot(aes(x = muts_per_pos, y = mean_ddg)) +
  geom_point(aes(size = positions), colour = '#984ea3') +
  geom_text_repel(aes(label = int)) +
  scale_x_log10() +
  scale_y_log10() +
  scale_size_area(name = 'Interface\nPositions') +
  coord_cartesian(clip = 'off') +
  labs(x = 'Variants per position per strain', y = expression('Frequency weighted mean interface'~Delta*Delta*G~'(kJ'%.%'mol'^-1*')'))

### Panel - Frequency vs FoldX
p_freq <- select(variants, position, wt, mut, freq, int_name, diff_interaction_energy) %>%
  drop_na(int_name) %>%
  mutate(freq_cat = classify_freq(freq)) %>%
  ggplot() +
  geom_boxplot(mapping = aes(x = freq_cat, y = diff_interaction_energy), fill = '#984ea3') +
  geom_hline(yintercept = 1, linetype = 'dotted', colour = 'black') +
  geom_hline(yintercept = -1, linetype = 'dotted', colour = 'black') +
  labs(x = 'Variant Frequency (%)', y = expression('FoldX Interface'~Delta*Delta*G~'(kJ'%.%'mol'^-1*')'))

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
p3 <- p_is_dms + labs(tag = 'C') + size

figure <- multi_panel_figure(width = c(60, 60, 60), height = c(50, 65, 65), panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1) %>%
  fill_panel(p2, row = 3, column = 1) %>%
  fill_panel(p3, row = 2:3, column = 2:3)
ggsave('figures/figures/figure2.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/figure2.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
