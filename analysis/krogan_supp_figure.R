#!/usr/bin/env Rscript
# Generate supplementary figure for Krogan paper
source('src/config.R')
source('src/analysis.R')
library(png)

variants <- load_variants() %>%
  mutate(freq_cat = classify_freq(freq))

spike <- read_csv('data/starr_ace2_spike.csv') %>% 
  mutate(uniprot = 'P0DTC2', name = 's') %>%
  select(uniprot, name, position = site_SARS2, position_rbd = site_RBD, wt = wildtype, mut = mutant, binding=bind_avg, expression=expr_avg) %>%
  left_join(variants, by = c('uniprot', 'name', 'position', 'wt', 'mut'))

### Panel 1 - Freq vs SIFT ###
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
  geom_text(data = freq_cat_summary, mapping = aes(x = freq_cat, y = 1.1, label = n), size = 1.8) +
  geom_point(data = freq_cat_summary, mapping = aes(x = freq_cat, y = median_sift, colour = 'Median'), shape = 20) +
  geom_line(data = freq_cat_summary, mapping = aes(x = freq_cat, y = median_sift, colour = 'Median', group = 1)) +
  geom_point(data = freq_cat_summary, mapping = aes(x = freq_cat, y = mean_sift, colour = 'Mean'), shape = 20) +
  geom_line(data = freq_cat_summary, mapping = aes(x = freq_cat, y = mean_sift, colour = 'Mean', group = 1)) +
  labs(x = 'Variant Frequency (%)', y = 'SIFT4G Score') + 
  scale_y_continuous(breaks = seq(0, 1, 0.2)) +
  scale_colour_manual(name = '', values = c(Mean='darkblue', Median='#ff7f00')) +
  guides(colour = "none")

### Panel 2 - Freq vs FoldX ###
p_foldx_freq <- ggplot(variants, aes(x = freq_cat, y = clamp(total_energy, -10, 10))) + 
  geom_violin(fill = '#e41a1c', colour = '#e41a1c', scale = 'width') +
  geom_hline(yintercept = 1, linetype = 'dotted', colour = 'black') +
  geom_hline(yintercept = -1, linetype = 'dotted', colour = 'black') +
  geom_text(data = freq_cat_summary, mapping = aes(x = freq_cat, y = 10.5, label = n), size = 1.8) +
  geom_point(data = freq_cat_summary, mapping = aes(x = freq_cat, y = median_foldx, colour = 'Median'), shape = 20) +
  geom_line(data = freq_cat_summary, mapping = aes(x = freq_cat, y = median_foldx, colour = 'Median', group = 1)) +
  geom_point(data = freq_cat_summary, mapping = aes(x = freq_cat, y = mean_foldx, colour = 'Mean'), shape = 20) +
  geom_line(data = freq_cat_summary, mapping = aes(x = freq_cat, y = mean_foldx, colour = 'Mean', group = 1)) +
  labs(x = 'Variant Frequency (%)', y = expression('FoldX'~Delta*Delta*'G (kJ' %.% 'mol'^-1*')')) + 
  scale_colour_manual(name = '', values = c(Mean='darkblue', Median='#ff7f00')) +
  theme(legend.position = 'top',
        legend.box.margin = margin(0, 0, 0, 0),
        legend.margin = margin(0, 0, -18, 0))

### Panel 3 - Freq vs Interface ###
freq_int <- select(variants, diff_interaction_energy, freq) %>%
  mutate(freq_cat = classify_freq(freq)) %>%
  drop_na(diff_interaction_energy) %>%
  group_by(freq_cat) %>%
  summarise(mean = mean(diff_interaction_energy),
            median = median(diff_interaction_energy),
            n = n(), .groups='drop')

p_int_freq <- ggplot(variants, aes(x = freq_cat, y = clamp(diff_interaction_energy, -5, 5))) + 
  geom_violin(fill = '#984ea3', colour = '#984ea3', scale = 'width') +
  geom_hline(yintercept = c(-1, 1), linetype = 'dotted', colour = 'black') +
  geom_text(data = freq_int, mapping = aes(x = freq_cat, y = 5.5, label = n), size = 1.8) +
  geom_point(data = freq_int, mapping = aes(x = freq_cat, y = median, colour = 'Median'), shape = 20) +
  geom_line(data = freq_int, mapping = aes(x = freq_cat, y = median, colour = 'Median', group = 1)) +
  geom_point(data = freq_int, mapping = aes(x = freq_cat, y = mean, colour = 'Mean'), shape = 20) +
  geom_line(data = freq_int, mapping = aes(x = freq_cat, y = mean, colour = 'Mean', group = 1)) +
  labs(x = 'Variant Frequency (%)', y = 'Int. '~Delta*Delta*G~'(kJ'%.%'mol'^-1*')') + 
  scale_colour_manual(name = '', values = c(Mean='darkblue', Median='#ff7f00')) +
  guides(colour = "none") +
  lims(y = c(-5, 5))

### Panel 4 - DMS vs SIFT ###
p_sift_dms <- select(spike, name, position, wt, mut, expression, sift_score, sift_median) %>%
  distinct(.keep_all = TRUE) %>%
  mutate(sig = ifelse(sift_score < 0.05, 'Deleterious', 'Neutral')) %>%
  drop_na() %>%
  ggplot(aes(x = sig, y = expression)) +
  geom_boxplot(fill = '#377eb8', outlier.shape = 20) +
  stat_compare_means(comparisons = list(c('Deleterious', 'Neutral')), size = 2) +
  labs(x = 'SIFT4G Prediction', y = 'S Expression')

### Panel 5 - DMS vs FoldX ###
p_foldx_dms <- select(spike, name, position, wt, mut, expression, total_energy) %>%
  distinct(.keep_all = TRUE) %>%
  mutate(sig = ifelse(total_energy < 1, ifelse(total_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising')) %>%
  drop_na() %>%
  ggplot(aes(x = sig, y = expression)) +
  geom_boxplot(fill = '#e41a1c', outlier.shape = 20) +
  stat_compare_means(comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral')), size = 2) +
  labs(x = 'FoldX Prediction', y = 'S Expression')

### Panel 6 - DMS vs Interface ###
p_int_dms <- select(spike, position, wt, mut, binding, int_name, diff_interaction_energy) %>%
  filter(int_name == 'ace2') %>%
  mutate(sig = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising')) %>%
  ggplot(aes(x = sig, y = binding)) +
  geom_boxplot(fill = '#984ea3', outlier.shape = 20) +
  stat_compare_means(comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral')), method = 't.test', size = 2) +
  coord_cartesian(clip = 'off') +
  labs(x = 'FoldX Interface Prediction', y = 'ACE2 Binding Fitness')

### Panel 7 - Interface ROC ###
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
               sift_score='"SIFT4G Score',
               int_ddg='"ACE2 Interface"~Delta*Delta*"G')

dms_auc <- group_by(dms_models, tool, interface_only) %>%
  summarise(auc = integrate(approxfun(fpr, tpr), lower = 0, upper = 1, subdivisions = 1000)$value, .groups = 'drop') %>%
  arrange(interface_only, desc(auc)) %>%
  mutate(fpr = 1.05, tpr = c(0.12, 0.05, 0.19, 0.12, 0.05),
         lab = str_c(tool_labs[tool], ' (AUC = ', signif(auc, 2), ')"'))

p_int_roc <- ggplot(dms_models, aes(x = fpr, y = tpr, colour = tool)) +
  facet_wrap(~interface_only, labeller = as_labeller(c(`TRUE`='Interface Residues', `FALSE`='All Residues')), ncol = 2, nrow = 1) +
  coord_cartesian(clip = 'off') +
  geom_abline(slope = 1, linetype = 'dashed', colour = 'black') +
  geom_line(show.legend = FALSE) +
  geom_text(data = dms_auc, mapping = aes(label = lab), parse=TRUE, hjust = 1, size = 2, show.legend = FALSE) +
  labs(x = 'False Positive Rate', y = 'True Positive Rate') +
  scale_colour_brewer(type = 'qual', palette = 'Dark2', name = '')

### Panel 8 - Antibody Escape ###
s_variants <- filter(variants, name == 's') %>%
  mutate(sig_sift = ifelse(sift_score < 0.05, 'Deleterious', 'Neutral'),
         sig_foldx = ifelse(total_energy < 1, ifelse(total_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'),
         sig_int = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'))

interesting_s_variants <- filter(s_variants, mut_escape_max > 0.5) %>%
  distinct(position, wt, mut, mut_escape_max, total_energy)

p_escape <- drop_na(s_variants, mut_escape_max) %>%
  ggplot(aes(x = clamp(total_energy, upper = 10), y = mut_escape_max, colour = sig_sift, label = str_c(wt, position, mut))) + 
  geom_vline(xintercept = c(-1, 1)) +
  geom_point(shape = 20, size = 0.5) +
  geom_point(data = filter(s_variants, int_name == 'ace2'), mapping = aes(shape = sig_int), size = 1) +
  geom_text_repel(data = interesting_s_variants, colour = 'black', show.legend = FALSE, size = 2, force = 2) +
  geom_text_repel(data = filter(s_variants, position == 484, mut == 'K', int_name == 'ace2'), colour = 'black',
                  nudge_x = -2, nudge_y = 0.1, show.legend = FALSE, size = 2.5) +
  labs(x = expression(Delta*Delta*'G (Clamped to < 10)'), y = 'Max Escape Proportion') +
  scale_colour_manual(values = c(Deleterious = 'red', Neutral = 'black'), name = 'SIFT4G') +
  scale_shape_manual(values = c(Destabilising=8, Neutral=4, Stabilising=3), na.translate = FALSE,
                     name = 'ACE2 Interface') +
  theme(legend.position = 'bottom',
        legend.box = 'vertical',
        legend.margin = margin(-15,0,0,0))

### Panel 9 - Antibody Escape positions ###
label_text_size = 2.5
s_img <- readPNG('figures/figures/variants/s_antibody.png')
p_escape_structure <- ggplot() +
  coord_fixed(expand = FALSE, xlim = c(0, 1), ylim = c(0, 1), clip = 'off') +
  annotation_raster(s_img, xmin = 0.05, xmax = 0.95, ymin = 0.05, ymax = 0.95) +
  
  annotate('segment', x = 0.33, xend = 0.465, y = 0.57, yend = 0.53) +
  annotate('richtext', x = 0.32, y = 0.57, label = 'K417L/M/P/V', hjust = 1, vjust = 0.5, size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.5, xend = 0.56, y = 0.21, yend = 0.405) +
  annotate('richtext', x = 0.5, y = 0.2, label = 'V445!P/W/Y', hjust = 0.5, vjust = 1, size = label_text_size, # A/C/D/E/F/G/H/I/K/L/M/N/Q/R/S/T
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.41, xend = 0.49, y = 0.6, yend = 0.545, colour = 'red') +
  annotate('richtext', x = 0.4, y = 0.6, label = 'F456', hjust = 1, vjust = 0.5, size = label_text_size, 
           colour = 'red', fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.44, xend = 0.505, y = 0.63, yend = 0.55) +
  annotate('richtext', x = 0.43, y = 0.63, label = 'Y473L/M', hjust = 1, vjust = 0.5, size = label_text_size, 
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.69, xend = 0.575, y = 0.57, yend = 0.54) +
  annotate('richtext', x = 0.7, y = 0.57, label = 'E484!I/P/W', hjust = 0, vjust = 0.5, size = label_text_size, #A/C/D/F/G/H/K/L/M/N/Q/R/S/T/V/Y
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

### Assemble figure ###
size <- theme(text = element_text(size = 7))
p1 <- p_sift_freq + labs(tag = 'A') + size
p2 <- p_foldx_freq + labs(tag = 'B') + size
p3 <- p_int_freq + labs(tag = 'C') + size
p4 <- p_sift_dms + labs(tag = 'D') + size
p5 <- p_foldx_dms + labs(tag = 'E') + size
p6 <- p_int_dms + labs(tag = 'F') + size
p7 <- p_int_roc + labs(tag = 'G') + size
p8 <- p_escape  + labs(tag = 'H') + size
p9 <- p_escape_structure + labs(tag = 'I') + size

figure <- multi_panel_figure(width = c(30, 30, 30, 30, 30, 30), height = c(30, 30, 60, 100),
                             panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1:2) %>%
  fill_panel(p2, row = 1, column = 3:4) %>%
  fill_panel(p3, row = 1, column = 5:6) %>%
  fill_panel(p4, row = 2, column = 1:2) %>%
  fill_panel(p5, row = 2, column = 3:4) %>%
  fill_panel(p6, row = 2, column = 5:6) %>%
  fill_panel(p7, row = 3, column = 1:6) %>%
  fill_panel(p8, row = 4, column = 1:3) %>%
  fill_panel(p9, row = 4, column = 4:6)

ggsave('figures/figures/krogan_supp_figure.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm', device = cairo_pdf)
ggsave('figures/figures/krogan_supp_figure.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
