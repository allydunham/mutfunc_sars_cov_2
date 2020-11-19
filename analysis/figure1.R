#!/usr/bin/env Rscript
# Generate figure 1 (Summary of the data sources/pipeline, stats of results/coverage, benchmark against frequency)
source('src/config.R')
source('src/analysis.R')
library(png)

variants <- load_variants()
spike <- read_csv('data/starr_ace2_spike.csv') %>% 
  mutate(uniprot = 'P0DTC2', name = 's') %>%
  select(uniprot, name, position = site_SARS2, position_rbd = site_RBD, wt = wildtype, mut = mutant, binding=bind_avg, expression=expr_avg) %>%
  left_join(variants, by = c('uniprot', 'name', 'position', 'wt', 'mut'))

### Panel 1 - Schematic
ensembl_img <- readPNG('figures/figures/misc_parts/ensembl_logo.png')
gisaid_img <- readPNG('figures/figures/misc_parts/gisaid_logo.png')
pdbe_img <- readPNG('figures/figures/misc_parts/pdbe_logo.png')
swissmodel_img <- readPNG('figures/figures/misc_parts/swissmodel.png')
uniprot_img <- readPNG('figures/figures/misc_parts/uniprot.png')

protein_img <- readPNG('figures/figures/misc_parts/protein.png')
interface_img <- readPNG('figures/figures/misc_parts/interface.png')
alignment_img <- readPNG('figures/figures/misc_parts/alignment.png')
sequence_img <- readPNG('figures/figures/misc_parts/sequence.png')

sift_img <- readPNG('figures/figures/misc_parts/sift_logo.png')
foldx_img <- readPNG('figures/figures/misc_parts/foldx_logo.png')

title_size = 3.5
main_size = 2.5
panel_colour <- '#faebff'
p_schematic <- ggplot() +
  coord_fixed(expand = FALSE, xlim = c(0, 3), ylim = c(0, 1), clip = 'off') +
  scale_x_continuous(breaks = c(0.5, 1.5, 2.5), labels = c('Sources', 'Data', 'Predictions'), position = 'top') +
  
  # Boxes and arrows
  annotate('TextBox', x = 0.5, y = 1, label = '', width = unit(0.28, 'native'), height = unit(1, 'native'),
           hjust = 0.5, vjust = 1, fill = panel_colour, colour = NA) +
  annotate('segment', x = 1, y = 0.5, xend = 1.01, yend = 0.5, arrow = arrow(length = unit(0.05, 'native'), type = 'closed')) +
  annotate('TextBox', x = 1.5, y = 1, label = '', width = unit(0.3, 'native'), height = unit(1, 'native'),
           hjust = 0.5, vjust = 1, fill = panel_colour, colour = NA) +
  annotate('segment', x = 2.02, y = 0.5, xend = 2.03, yend = 0.5, arrow = arrow(length = unit(0.05, 'native'), type = 'closed')) +
  annotate('TextBox', x = 2.5, y = 1, label = '', width = unit(0.28, 'native'), height = unit(1, 'native'),
           hjust = 0.5, vjust = 1, fill = panel_colour, colour = NA) +
  
  # Sources
  annotation_raster(uniprot_img, xmin = 0.33, xmax = 0.67, ymin = 0.81, ymax = 0.97) +
  annotation_raster(swissmodel_img, xmin = 0.4, xmax = 0.6, ymin = 0.615, ymax = 0.765) +
  annotation_raster(pdbe_img, xmin = 0.3, xmax = 0.7, ymin = 0.43, ymax = 0.55) +
  annotate('text', x = 0.5, y = 0.3, label = 'Bouhaddou et al. (2020)', size = main_size) +
  annotation_raster(ensembl_img, xmin = 0.2, xmax = 0.45, ymin = 0.05, ymax = 0.133) +
  annotation_raster(gisaid_img, xmin = 0.575, xmax = 0.875, ymin = 0.05, ymax = 0.1625) +
  
  # Input Data
  annotation_raster(sequence_img, xmin = 1.07, xmax = 1.47, ymin = 0.9, ymax = 0.93) +
  annotate('text', label='Protein Sequences', x = 1.5, y = 0.915, vjust = 0.5, hjust = 0, size = main_size) +
  annotation_raster(protein_img, xmin = 1.1, xmax = 1.4, ymin = 0.575, ymax = 0.875) +
  annotate('text', label='Protein Structures', x = 1.5, y = 0.75, vjust = 0.5, hjust = 0, size = main_size) +
  annotation_raster(interface_img, xmin = 1.1, xmax = 1.4, ymin = 0.35, ymax = 0.65) +
  annotate('text', label='Complex Structures', x = 1.5, y = 0.5, vjust = 0.5, hjust = 0, size = main_size) +
  annotate('segment', x = c(1.15, 1.25), xend = c(1.35, 1.25), y = c(0.3, 0.3), yend = c(0.3, 0.32)) + 
  annotate('point', x = 1.25, y = 0.33, shape = 19, colour = 'red') + 
  annotate('text', label='Phosphosites', x = 1.5, y = 0.3, vjust = 0.5, hjust = 0, size = main_size) +
  annotation_raster(alignment_img, xmin = 1.07, xmax = 1.47, ymin = 0.05, ymax = 0.137) +
  annotate('text', label='Sequence Alignments', x = 1.5, y = 0.1, vjust = 0.5, hjust = 0, size = main_size) +
  
  # Output
  annotation_raster(sift_img, xmin = 2.25, xmax = 2.45, ymin = 0.75, ymax = 0.95) +
  annotate('text', label='Conservation\nSIFT4G Score', x = 2.5, y = 0.865, vjust = 0.5, hjust = 0, size = main_size) +
  annotation_raster(foldx_img, xmin = 2.2, xmax = 2.45, ymin = 0.568, ymax = 0.682) +
  annotate('richtext', label='Protein stability &Delta;&Delta;G', x = 2.5, y = 0.675, vjust = 0.5, hjust = 0, fill = NA, label.color = NA, size = main_size) +
  annotate('richtext', label='Interface stability &Delta;&Delta;G', x = 2.5, y = 0.575, vjust = 0.5, hjust = 0, fill = NA, label.color = NA, size = main_size) +
  annotate('text', label='PTM Locations', x = 2.5, y = 0.3, vjust = 0, hjust = 0.5, size = main_size) +
  annotate('text', label='Variant Frequency', x = 2.5, y = 0.1, vjust = 0, hjust = 0.5, size = main_size) +

  # Theme
  theme(axis.title = element_blank(), axis.text.y = element_blank(),
        axis.ticks = element_blank(), panel.grid.major.y = element_blank())

### Panel 2 - Structural Coverage
p_coverage <- select(variants, name, position, sift_score, total_energy) %>%
  mutate(name = display_names[name]) %>%
  group_by(name, position) %>%
  summarise(foldx = any(!is.na(total_energy)), .groups = 'drop_last') %>%
  summarise(prop = sum(foldx) / n() * 100, .groups = 'drop') %>%
  pivot_longer(-name, names_to = 'tool', values_to = 'prop') %>%
  mutate(name = factor(name, levels = unique(display_names))) %>%
  ggplot(aes(x = name, y = prop)) +
  geom_col(fill = '#4daf4a', width = 0.5) +
  lims(y = c(0, 100)) +
  labs(x = '', y = 'Structural Coverage (%)') +
  coord_flip(expand = FALSE) +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(linetype = 'dotted', colour = 'grey'),
        axis.ticks.y = element_blank())
  
### Panel 3 - Complexes
pdb_ints <- c(`2ahm`='nsp7_nsp8', `5c8s`='nsp10_nsp14', `6m0j`='ace2_s', `6w4b`='nsp9_nsp9', `6w75`='nsp10_nsp16', `6x29`='s_s',
              `6xdc`='orf3a_orf3a', `6zoj`='nsp1_40s', `7btf`='nsp7_nsp8_pol', `7c22`='nc_nc', `7kdt`='orf9b_tom70')
pdb_names <- c(`2ahm`='nsp7 - nsp8', `5c8s`='nsp10 - ExoN', `6m0j`='S - ACE2', `6w4b`='nsp9 - nsp9', `6w75`='nsp10 - nsp16', `6x29`='S - S',
               `6xdc`='orf3a - orf3a', `6zoj`='nsp1 - 40S Ribosome', `7btf`='nsp7 - nsp8 - RdRp', `7c22`='N - N', `7kdt`='orf9b - TOM70')

complexes <- select(variants, int_template, name, int_name, position) %>%
  drop_na() %>%
  distinct() %>%
  mutate(int_template = str_split_fixed(int_template, '\\.', n = 3)[,1],
         int_name = ifelse(str_detect(int_name, 'ribosomal'), '40s', int_name)) %>%
  count(int_template, name, int_name) %>%
  group_by(int_template) %>%
  summarise(n = sum(n), .groups='drop') %>%
  mutate(int = pdb_ints[int_template],
         int_name = pdb_names[int_template],
         img = str_c("<img src='figures/figures/complexes/", int, ".png", "' width='53' />"),
         n = str_c(n, ' positions'))

p_complexes <- ggplot(complexes, aes(x = n, label = img)) +
  geom_richtext(y = 0.5, fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  facet_wrap(~int_name, nrow = 2, scales = 'free') +
  theme(panel.grid.major.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank())

### Panel 4 - SIFT4G against frequency
p_sift_freq <- select(variants, sift_score, freq) %>%
  mutate(freq_cat = classify_freq(freq)) %>%
  drop_na(sift_score) %>%
  group_by(freq_cat) %>%
  summarise(mean = mean(sift_score), sd = sd(sift_score), .groups='drop') %>%
  ggplot() + 
  geom_segment(mapping = aes(x = freq_cat, xend = freq_cat, y = clamp(mean - sd, 0), yend = mean + sd), colour = '#377eb8', size = 0.5) +
  geom_point(mapping = aes(x = freq_cat, y = mean), colour = '#377eb8') +
  geom_hline(yintercept = 0.05, linetype = 'dotted', colour = 'black') +
  labs(x = 'Variant Frequency (%)', y = 'SIFT4G Score')

### Panel 5 - SIFT4G against Spike DMS Expression Fitness
p_sift_dms <- select(spike, expression, sift_score, sift_median) %>%
  mutate(sig = ifelse(sift_score < 0.05, 'Deleterious', 'Neutral')) %>%
  drop_na() %>%
  ggplot(aes(x = sig, y = expression)) +
  geom_boxplot(fill = '#377eb8') +
  stat_compare_means(comparisons = list(c('Deleterious', 'Neutral')), method = 't.test', size = 2) +
  labs(x = 'SIFT4G Prediction', y = 'Spike DMS Expression Fitness')

### Panel 6 - FoldX against frequency
p_foldx_freq <- select(variants, total_energy, freq) %>%
  mutate(freq_cat = classify_freq(freq)) %>%
  drop_na(total_energy) %>%
  group_by(freq_cat) %>%
  summarise(mean = mean(total_energy), sd = sd(total_energy), .groups='drop') %>%
  ggplot() + 
  geom_segment(mapping = aes(x = freq_cat, xend = freq_cat, y = mean - sd, yend = mean + sd), colour = '#e41a1c', size = 0.5) +
  geom_point(mapping = aes(x = freq_cat, y = mean), colour = '#e41a1c') +
  geom_hline(yintercept = 1, linetype = 'dotted', colour = 'black') +
  geom_hline(yintercept = -1, linetype = 'dotted', colour = 'black') +
  labs(x = 'Variant Frequency (%)', y = expression('FoldX'~Delta*Delta*G~'(kJ'%.%'mol'^-1*')'))

### Panel 7 FoldX against Spike DMS Expression Fitness
p_foldx_dms <- select(spike, expression, total_energy) %>%
  mutate(sig = ifelse(total_energy < 1, ifelse(total_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising')) %>%
  drop_na() %>%
  ggplot(aes(x = sig, y = expression)) +
  geom_boxplot(fill = '#e41a1c') +
  stat_compare_means(comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral')),
                     method = 't.test', size = 2) +
  labs(x = 'FoldX Prediction', y = 'Spike DMS Expression Fitness')

### Assemble figure
size <- theme(text = element_text(size = 8))
p1 <- p_schematic + labs(tag = 'A') + size
p2 <- p_coverage + labs(tag = 'B') + size
p3 <- p_complexes + labs(tag = 'C') + size
p4 <- p_sift_freq + labs(tag = 'D') + size
p5 <- p_sift_dms  + labs(tag = 'E') + size
p6 <- p_foldx_freq + labs(tag = 'F') + size
p7 <- p_foldx_dms  + labs(tag = 'G') + size

figure <- multi_panel_figure(width = 183, height = 183, columns = 4, rows = 3,
                              panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1:4) %>%
  fill_panel(p2, row = 2, column = 1) %>%
  fill_panel(p3, row = 2, column = 2:4) %>%
  fill_panel(p4, row = 3, column = 1) %>%
  fill_panel(p5, row = 3, column = 2) %>%
  fill_panel(p6, row = 3, column = 3) %>%
  fill_panel(p7, row = 3, column = 4)
ggsave('figures/figures/figure1.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/figure1.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
