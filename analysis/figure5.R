#!/usr/bin/env Rscript
# Generate figure 5 (Antibody Escape)
source('src/config.R')
source('src/analysis.R')

variants <- load_variants() %>%
  filter(name == 's') %>%
  mutate(sig_sift = ifelse(sift_score < 0.05, 'Deleterious', 'Neutral'),
         sig_foldx = ifelse(total_energy < 1, ifelse(total_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'),
         sig_int = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'))

### Panel 1 - Benchmark predictors
tool_cat_levels <- c('Deleterious SIFT4G', 'Neutral SIFT4G', 'b1',
                     'Destabilising FoldX', 'Neutral FoldX', 'Stabilising FoldX', 'b2',
                     'Destabilising ACE2 Interface', 'Neutral ACE2 Interface', 'Stabilising ACE2 Interface')
tool_cat_labels <- c('Deleterious', 'Neutral', '', 'Destabilising', 'Neutral', 'Stabilising', '', 'Destabilising', 'Neutral', 'Stabilising')

variants_long <- drop_na(variants, mut_escape_mean) %>%
  select(position, wt, mut, starts_with('sig_'), int_name, mut_escape_mean, mut_escape_max) %>%
  filter(is.na(int_name) | int_name == 'ace2') %>%
  pivot_longer(starts_with('sig_'), names_to = 'tool', values_to = 'sig', names_prefix = 'sig_') %>%
  drop_na(sig) %>%
  mutate(int_name = display_names[int_name],
         tool = c(sift='SIFT4G', foldx='FoldX', int='ACE2 Interface')[tool],
         x = factor(str_c(sig, ' ', tool), levels = tool_cat_levels),
         x_int = as.integer(x))

count_group <- function(x){
  data.frame(y = 0, label = length(x))
}

variants_long_signif <- compare_means(mut_escape_max ~ sig, group.by = 'tool', data = variants_long, method = 'wilcox') %>%
  mutate(g1 = str_c(group1, ' ', tool), g2 = str_c(group2, ' ', tool), 
         group1 = match(g1, tool_cat_levels), group2 = match(g2, tool_cat_levels),
         y.position = c(0.96, 0.96, 1.03, 1.11, 0.96, 1.03, 1.11
                        ))

text_size <- 2
p_pred_benchmark <- ggplot(variants_long, aes(x = x_int, group = x, fill = tool, y = mut_escape_max)) +
  geom_boxplot(outlier.shape = 20, outlier.size = 0.5, show.legend = FALSE) +
  annotate('text', x = c(1.5, 5, 9), y = -0.25, label = c('SIFT4G', 'FoldX', 'ACE2 Interface'), size = text_size) +
  coord_cartesian(clip = 'off', ylim = c(0, 1)) +  
  scale_y_continuous(breaks = seq(0, 1, 0.25), expand = expansion(add = 0.02)) + 
  scale_x_continuous(breaks = 1:length(tool_cat_levels), labels = tool_cat_labels) +
  scale_fill_manual(values = c(SIFT4G='#377eb8', FoldX='#e41a1c', `ACE2 Interface`='#984ea3')) +
  stat_summary(geom = 'text', fun.data = count_group, vjust=1.2, size = text_size) +
  stat_pvalue_manual(variants_long_signif, label = 'p.format', tip.length = 0.005, label.size = text_size) +
  labs(x = '', y = 'Max Antibody Escape') +
  theme(axis.ticks.x = element_blank())

### Panel 2 - Antibody interfaces

antibody_interfaces <- select(variants, name, position, wt, mut, mut_escape_max, mut_escape_mean, int_name, diff_interaction_energy, sig_int) %>%
  drop_na() %>%
  filter(str_detect(int_name, '(Heavy|Light) Chain')) %>%
  mutate(antibody = str_remove(int_name, '( Fab)? (Heavy|Light) Chain'))

p_interfaces <- ggplot(antibody_interfaces, aes(x = sig_int, y = mut_escape_max, fill = sig_int)) +
  facet_wrap(~antibody, nrow = 1, strip.position = 'bottom') +
  geom_boxplot(show.legend = FALSE, outlier.shape = 20, outlier.size = 0.5) +
  coord_cartesian(clip = 'off') +
  scale_fill_brewer(palette = 'Set1') +
  stat_compare_means(comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral'), c('Destabilising', 'Stabilising')), size = text_size) +
  stat_summary(geom = 'text', fun.data = count_group, vjust=1.2, size = text_size) +
  labs(x = '', y = 'Max Antibody Escape') +
  theme(axis.ticks.x = element_blank(),
        strip.placement = 'outside')

### Panel 3 - Most neutral experimental variants
interesting_variants <- filter(variants, mut_escape_max > 0.5) %>%
  distinct(position, wt, mut, mut_escape_max, total_energy)

p_experiment <- drop_na(variants, mut_escape_max) %>%
  ggplot(aes(x = clamp(total_energy, upper = 10), y = mut_escape_max, colour = sig_sift, label = str_c(wt, position, mut))) + 
  geom_vline(xintercept = c(-1, 1)) +
  geom_point(shape = 20, size = 0.5) +
  geom_point(data = filter(variants, int_name == 'ace2'), mapping = aes(shape = sig_int), size = 2) +
  geom_text_repel(data = interesting_variants, colour = 'black', show.legend = FALSE, size = text_size, force = 2) +
  geom_text_repel(data = filter(variants, position == 484, mut == 'K', int_name == 'ace2'), colour = 'black',
                  nudge_x = -2, nudge_y = 0.1, show.legend = FALSE, size = 2.5) +
  labs(x = expression(Delta*Delta*'G (Clamped to < 10)'), y = 'Max Escape Proportion') +
  scale_colour_manual(values = c(Deleterious = 'red', Neutral = 'black'), name = 'SIFT4G') +
  scale_shape_manual(values = c(Destabilising=8, Neutral=4, Stabilising=3), na.translate = FALSE,
                     name = 'ACE2 Interface') +
  theme(legend.position = 'bottom',
        legend.box = 'vertical',
        legend.margin = margin(-15,0,0,0))

### Panel 4 - Variants visualised on S

p_structure <- blank_plot('S Structure')

### Assemble figure
size <- theme(text = element_text(size = 8))
p1 <- p_pred_benchmark + labs(tag = 'A') + size
p2 <- p_interfaces + labs(tag = 'B') + size
p3 <- p_experiment + labs(tag = 'C') + size
p4 <- p_structure + labs(tag = 'D') + size

figure <- multi_panel_figure(width = c(90, 90), height = c(40, 40, 100), panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1:2) %>%
  fill_panel(p2, row = 2, column = 1:2) %>%
  fill_panel(p3, row = 3, column = 1) %>%
  fill_panel(p4, row = 3, column = 2)
ggsave('figures/figures/figure5.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/figure5.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')