#!/usr/bin/env Rscript
# Generate overall summary figure (Used in thesis)
source('src/config.R')
source('src/analysis.R')
library(png)

variants <- load_variants() %>%
  mutate(freq_cat = classify_freq(freq))

spike <- read_csv('data/starr_ace2_spike.csv') %>% 
  mutate(uniprot = 'P0DTC2', name = 's') %>%
  select(uniprot, name, position = site_SARS2, position_rbd = site_RBD, wt = wildtype, mut = mutant, binding=bind_avg, expression=expr_avg) %>%
  left_join(variants, by = c('uniprot', 'name', 'position', 'wt', 'mut'))

### Panel - Schematic
ensembl_img <- readPNG('figures/figures/misc_parts/ensembl_logo.png')
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
panel_colour <- '#e4edff'
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
  annotation_raster(ensembl_img, xmin = 0.35, xmax = 0.65, ymin = 0.05, ymax = 0.15) +
  
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
  annotate('text', label='Sequence Alignments', x = 1.49, y = 0.1, vjust = 0.5, hjust = 0, size = main_size) +
  
  # Output
  annotation_raster(sift_img, xmin = 2.25, xmax = 2.45, ymin = 0.75, ymax = 0.95) +
  annotate('text', label='Conservation\nSIFT4G Score', x = 2.5, y = 0.865, vjust = 0.5, hjust = 0, size = main_size) +
  annotation_raster(foldx_img, xmin = 2.2, xmax = 2.45, ymin = 0.568, ymax = 0.682) +
  annotate('richtext', label='Folding &Delta;&Delta;G', x = 2.5, y = 0.675, vjust = 0.5, hjust = 0, fill = NA,
           label.color = NA, size = main_size) +
  annotate('richtext', label='Binding &Delta;&Delta;G', x = 2.5, y = 0.575, vjust = 0.5, hjust = 0, fill = NA,
           label.color = NA, size = main_size) +
  annotate('text', label='PTM Locations', x = 2.5, y = 0.3, vjust = 0, hjust = 0.5, size = main_size) +
  annotate('text', label='Variant Frequency', x = 2.5, y = 0.1, vjust = 0, hjust = 0.5, size = main_size) +
  
  # Theme
  theme(axis.title = element_blank(), axis.text.y = element_blank(),
        axis.ticks = element_blank(), panel.grid.major.y = element_blank(),
        axis.text.x = element_text(size = 10))

### Panel - SIFT vs Freq
freq_cat_summary <- distinct(variants, uniprot, name, position, wt, mut, .keep_all = TRUE) %>%
  group_by(freq_cat) %>%
  summarise(n = n(), 
            mean_sift = mean(sift_score, na.rm = TRUE),
            median_sift = median(sift_score, na.rm = TRUE),
            mean_foldx = mean(total_energy, na.rm = TRUE),
            median_foldx = median(total_energy, na.rm = TRUE),
            .groups = 'drop')

p_sift_freq <- ggplot(variants, aes(x = freq_cat, y = sift_score)) + 
  geom_violin(fill = '#377eb8', colour = '#377eb8', scale = 'width') +
  geom_hline(yintercept = 0.05, linetype = 'dotted', colour = 'black') +
  geom_text(data = freq_cat_summary, mapping = aes(x = freq_cat, y = 1.075, label = n), size = 2.5) +
  geom_point(data = freq_cat_summary, mapping = aes(x = freq_cat, y = median_sift, colour = 'Median'), shape = 20) +
  geom_line(data = freq_cat_summary, mapping = aes(x = freq_cat, y = median_sift, colour = 'Median', group = 1)) +
  geom_point(data = freq_cat_summary, mapping = aes(x = freq_cat, y = mean_sift, colour = 'Mean'), shape = 20) +
  geom_line(data = freq_cat_summary, mapping = aes(x = freq_cat, y = mean_sift, colour = 'Mean', group = 1)) +
  labs(x = 'Variant Frequency (%)', y = 'SIFT4G Score') + 
  scale_y_continuous(breaks = seq(0, 1, 0.2)) +
  scale_colour_manual(name = '', values = c(Mean='darkblue', Median='#ff7f00')) +
  theme(legend.position = 'top', legend.box.margin = margin(0, 0, 0, 0), legend.margin = margin(0, 0, -15, 0))

### Panel - FoldX vs DMS
p_foldx_dms <- select(spike, name, position, wt, mut, expression, total_energy) %>%
  distinct(.keep_all = TRUE) %>%
  mutate(sig = ifelse(total_energy < 1, ifelse(total_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising')) %>%
  drop_na() %>%
  ggplot(aes(x = sig, y = expression)) +
  geom_boxplot(fill = '#e41a1c', outlier.shape = 20) +
  coord_cartesian(clip = "off") +
  stat_compare_means(comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral')), size = 3) +
  labs(x = 'FoldX Prediction', y = 'S Expression\nFitness')

### Panel - Interface vs DMS
p_int_dms <- select(spike, position, wt, mut, binding, int_name, diff_interaction_energy) %>%
  filter(int_name == 'ace2') %>%
  mutate(sig = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising')) %>%
  ggplot(aes(x = sig, y = binding)) +
  geom_boxplot(fill = '#984ea3', outlier.shape = 20) +
  stat_compare_means(comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral')), method = 't.test', size = 3) +
  coord_cartesian(clip = 'off') +
  labs(x = 'FoldX Interface Prediction', y = 'ACE2 Binding\nFitness')

### Panel - Tool ROC Curves
dms_models <- select(spike, position, wt, mut, binding, ddg=total_energy, int_name, int_ddg = diff_interaction_energy, sift_score) %>%
  filter(int_name == 'ace2' | is.na(int_name)) %>%
  distinct(position, wt, mut, .keep_all = TRUE) %>%
  mutate(binding_sig = binding < log10(0.1), # Binding rate 1/10th wt and where tail begins on hist
         ddg_int_only = ifelse(is.na(int_ddg), NA, ddg), # Versions of other scores for interface residues only
         sift_score_int_only = ifelse(is.na(int_ddg), NA, sift_score)) %>%
  select(binding, binding_sig, sift_score, ddg, int_ddg, ddg_int_only, sift_score_int_only) %>%
  pivot_longer(c(-binding, -binding_sig), names_to = 'tool', values_to = 'score') %>%
  mutate(interface_only = ifelse(tool %in% c('ddg', 'sift_score'), FALSE, TRUE),
         tool = str_remove(tool, '_int_only')) %>%
  drop_na(score) %>%
  group_by(tool, interface_only) %>%
  group_modify(~calc_roc(., binding_sig, score, greater = .y$tool != 'sift_score')) %>%
  ungroup()

tool_labs <- c(ddg='Delta*Delta*"G',
               sift_score='"SIFT4G',
               int_ddg='"ACE2 Int."~Delta*Delta*"G')

dms_auc <- group_by(dms_models, tool, interface_only) %>%
  summarise(auc = integrate(approxfun(fpr, tpr), lower = 0, upper = 1, subdivisions = 1000)$value, .groups = 'drop') %>%
  arrange(interface_only, auc) %>%
  mutate(fpr = 1.1, tpr = c(0.16, 0.05, 0.27, 0.16, 0.05),
         lab = str_c(tool_labs[tool], ' (AUC = ', signif(auc, 2), ')"'))

p_roc <- ggplot(dms_models, aes(x = fpr, y = tpr, colour = tool)) +
  facet_wrap(~interface_only, labeller = as_labeller(c(`TRUE`='Interface Residues', `FALSE`='All Residues')), ncol = 2, nrow = 1) +
  coord_cartesian(clip = 'off') +
  geom_abline(slope = 1, linetype = 'dashed', colour = 'black') +
  geom_line(show.legend = FALSE) +
  geom_text(data = dms_auc, mapping = aes(label = lab), parse=TRUE, hjust = 1, size = 2, show.legend = FALSE) +
  labs(x = 'False Positive Rate', y = 'True Positive Rate') +
  scale_colour_brewer(type = 'qual', palette = 'Dark2', name = '')

### Panel - Antibody Escape
s_variants <- filter(variants, name == 's') %>%
  mutate(sig_sift = ifelse(sift_score < 0.05, 'Deleterious', 'Neutral'),
         sig_foldx = ifelse(total_energy < 1, ifelse(total_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'),
         sig_int = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'))

interesting_variants <- filter(s_variants, mut_escape_max > 0.5) %>%
  distinct(position, wt, mut, mut_escape_max, total_energy)

p_experiment <- drop_na(s_variants, mut_escape_max) %>%
  ggplot(aes(x = clamp(total_energy, upper = 10), y = mut_escape_max, colour = sig_sift, label = str_c(wt, position, mut))) + 
  geom_point(shape = 20, size = 0.5) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", colour = "grey") +
  geom_point(data = filter(s_variants, int_name == 'ace2'), mapping = aes(shape = sig_int), size = 2) +
  geom_text_repel(data = interesting_variants, colour = 'black', show.legend = FALSE, size = 2.5, force = 4, max.overlaps = Inf) +
  geom_text_repel(data = filter(s_variants, position == 484, mut == 'K', int_name == 'ace2'), colour = 'black',
                  nudge_x = -2, nudge_y = 0.1, show.legend = FALSE, size = 2.7) +
  labs(x = expression(Delta*Delta*'G (Clamped to < 10)'), y = 'Max Escape Proportion') +
  scale_colour_manual(values = c(Deleterious = 'red', Neutral = 'black'), name = 'SIFT4G') +
  scale_shape_manual(values = c(Destabilising=8, Neutral=4, Stabilising=3), na.translate = FALSE,
                     name = 'ACE2 Interface') +
  guides(shape = guide_legend(nrow = 2, title.position = "top"),
         colour = guide_legend(nrow = 2, title.position = "top")) +
  theme(legend.position = 'bottom',
        legend.box = 'horizontal',
        legend.margin = margin(-10,0,0,0),
        legend.key.size = unit(2.5, "mm"))

### Panel - Variants visualised on S
label_text_size = 3
s_img <- readPNG('figures/figures/variants/s_antibody.png')
p_structure <- ggplot() +
  coord_fixed(expand = FALSE, xlim = c(0, 1), ylim = c(0, 1), clip = 'off') +
  annotation_raster(s_img, xmin = 0.05, xmax = 0.95, ymin = 0.05, ymax = 0.95) +
  
  annotate('segment', x = 0.33, xend = 0.465, y = 0.57, yend = 0.53) +
  annotate('richtext', x = 0.32, y = 0.57, label = 'K417L/M/P/V', hjust = 1, vjust = 0.5, size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.5, xend = 0.56, y = 0.21, yend = 0.405) +
  annotate('richtext', x = 0.5, y = 0.2, label = 'V445<span style="color:magenta">!</span>P/W/Y', hjust = 0.5, vjust = 1,
           size = label_text_size, # A/C/D/E/F/G/H/I/K/L/M/N/Q/R/S/T
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.41, xend = 0.49, y = 0.6, yend = 0.545, colour = 'red') +
  annotate('richtext', x = 0.4, y = 0.6, label = 'F456', hjust = 1, vjust = 0.5, size = label_text_size, 
           colour = 'red', fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.44, xend = 0.505, y = 0.63, yend = 0.55) +
  annotate('richtext', x = 0.43, y = 0.63, label = 'Y473L/M', hjust = 1, vjust = 0.5, size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.69, xend = 0.575, y = 0.57, yend = 0.54) +
  annotate('richtext', x = 0.7, y = 0.57, label = 'E484<span style="color:magenta">!</span>I/P/W', hjust = 0, vjust = 0.5,
           size = label_text_size, #A/C/D/F/G/H/K/L/M/N/Q/R/S/T/V/Y
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.74, xend = 0.575, y = 0.65, yend = 0.585) +
  annotate('richtext', x = 0.75, y = 0.65, label = 'F486M', hjust = 0, vjust = 0, size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.5, xend = 0.545, y = 0.79, yend = 0.585) +
  annotate('richtext', x = 0.5, y = 0.8, label = 'N487L', hjust = 0.5, vjust =0 , size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.44, xend = 0.53, y = 0.72, yend = 0.555) +
  annotate('richtext', x = 0.44, y = 0.73, label = 'Y489L/M', hjust = 0.5, vjust = 0.5, size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.69, xend = 0.55, y = 0.53, yend = 0.525) +
  annotate('richtext', x = 0.7, y = 0.53, label = 'F490K/L/M/P', hjust = 0, vjust = 0.5, size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.64, xend = 0.545, y = 0.5, yend = 0.5) +
  annotate('richtext', x = 0.65, y = 0.5, label = 'Q493D/T', hjust = 0, vjust = 0.5, size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.74, xend = 0.575, y = 0.42, yend = 0.455) +
  annotate('richtext', x = 0.75, y = 0.42, label = 'Q498A/E/K/R', hjust = 0, vjust = 0.5, size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.77, xend = 0.565, y = 0.38, yend = 0.445) +
  annotate('richtext', x = 0.78, y = 0.38, label = 'T500D/E', hjust = 0, vjust = 0.5, size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.69, xend = 0.565, y = 0.47, yend = 0.475) +
  annotate('richtext', x = 0.7, y = 0.47, label = 'N501L', hjust = 0, vjust = 0.5, size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  geom_point(aes(colour = c('Neutral', 'Deleterious')), x = -100, y = -100) +
  scale_colour_manual(name='', values = c(Neutral='black', Deleterious='red')) +
  
  theme(axis.title = element_blank(), axis.text = element_blank(),
        axis.ticks = element_blank(), panel.grid.major.y = element_blank(),
        legend.position = c(0.5, 0), legend.direction = 'horizontal',
        legend.background = element_blank())

### Assemble figure
size <- theme(text = element_text(size = 11))
p1 <- p_sift_freq + labs(tag = 'A') + size
p2 <- p_foldx_dms + labs(tag = 'B') + size
p3 <- p_int_dms + labs(tag = 'C') + size
p4 <- p_roc + labs(tag = 'D') + size
p5 <- p_experiment + labs(tag = 'E') + size
p6 <- p_structure + labs(tag = 'F') + size

figure <- multi_panel_figure(width = 180, height = c(45, 45, 90), columns = 2, unit = "mm",
                             panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1) %>%
  fill_panel(p2, row = 1, column = 2) %>%
  fill_panel(p3, row = 2, column = 1) %>%
  fill_panel(p4, row = 2, column = 2) %>%
  fill_panel(p5, row = 3, column = 1) %>%
  fill_panel(p6, row = 3, column = 2)

ggsave('figures/figures/summary_figure.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm',
       device = cairo_pdf)
ggsave('figures/figures/summary_figure.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/mutfunc_schematic.pdf', p_schematic, width = 165, height = 80, units = 'mm', device = cairo_pdf)
