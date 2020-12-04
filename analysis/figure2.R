#!/usr/bin/env Rscript
# Generate figure 2 (Interface frequencies, Spike DMS, Human interface variant freqs?, In silico DMS?)
source('src/config.R')
source('src/analysis.R')

variants <- load_variants()
spike <- read_csv('data/starr_ace2_spike.csv') %>% 
  mutate(uniprot = 'P0DTC2', name = 's') %>%
  select(uniprot, name, position = site_SARS2, position_rbd = site_RBD, wt = wildtype, mut = mutant, binding=bind_avg, expression=expr_avg) %>%
  left_join(variants, by = c('uniprot', 'name', 'position', 'wt', 'mut'))

### Panel 1 - Interfaces freq
sig_vars <- select(variants, name, position, wt, mut, int_name, freq, diff_interaction_energy) %>%
  drop_na(int_name, freq) %>%
  mutate(name = display_names[name],
         int_name = display_names[int_name],
         int = str_c(name, ' - ', int_name),
         sig = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising'))

p_freq <- ggplot(mapping = aes(x = freq, y = int)) +
  geom_boxplot(data = sig_vars, outlier.shape = 20, outlier.size = 0.5) +
  geom_point(data = filter(sig_vars, sig == 'Stabilising'), mapping = aes(colour = 'Stabilising'),
             shape = 16, size = 0.8, position = position_jitter(width = 0, height = 0.2)) +
  geom_point(data = filter(sig_vars, sig == 'Destabilising'), mapping = aes(colour = 'Destabilising'),
             shape = 16, size = 0.8, position = position_jitter(width = 0, height = 0.2)) +
  scale_x_log10() +
  scale_colour_manual(name = '', values = c(Neutral='gray30', Stabilising='#377eb8', Destabilising='#e41a1c')) +
  labs(x = 'Variant Frequency') +
  theme(axis.title.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(linetype = 'dotted', colour = 'grey'),
        legend.position = 'top',
        legend.margin = margin(l = -5, b = -5, unit = 'mm'),
        legend.spacing.x = unit(-1, 'mm'))

### Panel 2 - Frequency vs ddG
p_freq_ddg <- select(variants, diff_interaction_energy, freq) %>%
  mutate(freq_cat = classify_freq(freq)) %>%
  drop_na(diff_interaction_energy) %>%
  group_by(freq_cat) %>%
  summarise(mean = mean(diff_interaction_energy), sd = sd(diff_interaction_energy), .groups='drop') %>%
  ggplot() + 
  geom_hline(yintercept = 2:-2, linetype = 'dotted', colour = c('grey', 'black', 'grey', 'black', 'grey')) +
  geom_segment(mapping = aes(x = freq_cat, xend = freq_cat, y = mean - sd, yend = mean + sd), colour = '#984ea3', size = 0.5) +
  geom_point(mapping = aes(x = freq_cat, y = mean), colour = '#984ea3') +
  labs(x = 'Variant Frequency (%)', y = expression('FoldX Interface'~Delta*Delta*G~'(kJ'%.%'mol'^-1*')')) +
  theme(panel.grid.major.y = element_blank())

### Panel 2 - Spike DMS vs. FoldX
p_spike_dms <- select(spike, position, wt, mut, binding, int_name, diff_interaction_energy) %>%
  filter(int_name == 'ace2') %>%
  mutate(sig = ifelse(diff_interaction_energy < 1, ifelse(diff_interaction_energy < -1, 'Stabilising', 'Neutral'), 'Destabilising')) %>%
  ggplot(aes(x = sig, y = binding)) +
  geom_boxplot(fill = '#984ea3', outlier.shape = 20) +
  stat_compare_means(comparisons = list(c('Destabilising', 'Neutral'), c('Stabilising', 'Neutral')), method = 't.test', size = 2) +
  coord_cartesian(clip = 'off') +
  labs(x = 'FoldX Interface Prediction', y = 'ACE2 Binding Fitness')

### Panel 3 - Spike DMS model
dms_models <- select(spike, binding, ddg=total_energy, int_ddg = diff_interaction_energy, sift_score) %>%
  mutate(binding_sig = binding < log10(0.1), # Binding rate 1/10th wt and where tail begins on hist
         ddg_int_only = ifelse(is.na(int_ddg), NA, ddg), # Versions of other scores for interface residues only
         sift_score_int_only = ifelse(is.na(int_ddg), NA, sift_score)) %>%
  pivot_longer(c(-binding, -binding_sig), names_to = 'tool', values_to = 'score') %>%
  mutate(interface_only = ifelse(tool %in% c('ddg', 'sift_score'), FALSE, TRUE),
         tool = str_remove(tool, '_int_only')) %>%
  drop_na(score) %>%
  group_by(tool, interface_only) %>%
  group_modify(~calc_roc(., binding_sig, score, greater = .y$tool != 'sift_score')) %>%
  ungroup()

tool_labs <- c(ddg='Delta*Delta*"G',
               sift_score='"SIFT4G Score',
               int_ddg='"Interface"~Delta*Delta*"G')

dms_auc <- group_by(dms_models, tool, interface_only) %>%
  summarise(auc = integrate(approxfun(fpr, tpr), lower = 0, upper = 1, subdivisions = 1000)$value, .groups = 'drop') %>%
  arrange(desc(auc)) %>%
  mutate(fpr = 1.05, tpr = c(0.12, 0.19, 0.05, 0.12, 0.05),
         lab = str_c(tool_labs[tool], ' (AUC = ', signif(auc, 2), ')"'))
        
p_roc <- ggplot(dms_models, aes(x = fpr, y = tpr, colour = tool)) +
  facet_wrap(~interface_only, labeller = as_labeller(c(`TRUE`='Interface Residues', `FALSE`='All Residues')), ncol = 1, nrow = 2) +
  coord_cartesian(clip = 'off') +
  geom_abline(slope = 1, linetype = 'dashed', colour = 'black') +
  geom_line(show.legend = FALSE) +
  geom_text(data = dms_auc, mapping = aes(label = lab), parse=TRUE, hjust = 1, size = 2, show.legend = FALSE) +
  labs(x = 'False Positive Rate', y = 'True Positive Rate') +
  scale_colour_brewer(type = 'qual', palette = 'Dark2', name = '') +
  geom_segment(data = tibble(x = 0.5362135, y = 0.700, xend = 0.25, yend = 0.8, interface_only=TRUE),
               mapping = aes(x=x, y=y, xend=xend, yend=yend), inherit.aes = FALSE) +
  geom_text(data = tibble(x = 0.25, y = 0.8, interface_only=TRUE), mapping = aes(x=x, y=y),
            label = 'Delta*Delta*"G Threshold"%~~%0',
            hjust = 0.5, vjust = -0.25, parse = TRUE, size = 2, inherit.aes = FALSE)

### Panel 5 - N in silico DMS
is_dms_nc <- select(variants, name, position, wt, mut, log10_freq, int_name, diff_interaction_energy) %>%
  filter(name == 'nc', position <= 400, position >= 250) %>%
  mutate(wt_int = factor(wt, levels = sort(Biostrings::AA_STANDARD)) %>% as.integer(),
         mut_int = factor(mut, levels = sort(Biostrings::AA_STANDARD)) %>% as.integer())

is_dms_nc_summary <- group_by(is_dms_nc, position, wt_int) %>%
  summarise(mean_ddg = mean(diff_interaction_energy))

nc_regions <- tibble(colour = c('#1b9e77', '#d95f02', '#7570b3', '#e7298a'),
                     start = c(257, 303, 326, 345), end = c(287, 323, 342, 361))
# pmap(list(nc_regions$colour, nc_regions$start, nc_regions$end), ~str_c('color ', str_replace(..1, '#', '0x'), ', ', str_c(str_c('resi ', ..2:..3), collapse = ' or '))) %>% unlist() %>% cat(sep='\n')

p_is_dms <- ggplot() + 
  # Scale covers ddG heatmap, mean row and freq plot
  scale_y_continuous(limits = c(250, 400), breaks = seq(250, 400, 50), minor_breaks = seq(275, 375, 50)) +
  scale_x_continuous(breaks = c(1:20, 22, 24:29), limits = c(0, 29),
                     labels = c(sort(Biostrings::AA_STANDARD), expression(bar(Delta*Delta*G)), -5:0)) +
  
  # ddG heatmap & means row
  geom_raster(data = is_dms_nc, mapping = aes(x = mut_int, y = position, fill = clamp(diff_interaction_energy, lower = -5, upper = 5))) +
  geom_raster(data = is_dms_nc_summary, mapping = aes(x = wt_int, y = position), fill = 'grey', show.legend = FALSE) +
  geom_raster(data = is_dms_nc_summary, mapping = aes(x = 22, y = position, fill = clamp(mean_ddg, lower = -5, upper = 5)), show.legend = FALSE) +
  scale_fill_gradientn(colours = c('#5e4fa2', '#3288bd', '#66c2a5', '#abdda4', '#e6f598', '#ffffbf',
                                   '#fee08b', '#fdae61', '#f46d43', '#d53e4f', '#9e0142'),
                       values = scales::rescale(-5:5, to=0:1), na.value = 'white', limits = c(-5, 5),
                       name="<img src='figures/figures/misc_parts/nc_regions.png' width='120' /><br><br><br>Interface &Delta;&Delta;G (kJ.mol<sup>-1</sup>)<br>Clamped to &plusmn;5") +
  # Add WT to legend
  geom_point(aes(colour = 'WT'), y = -100, x = -100, shape = 15, size = 5, show.legend = FALSE) +
  scale_colour_manual(name='', values = c(WT='grey')) +
  
  # Freq plot
  annotate('segment', x = 24:29, xend = 24:29, y = 250, yend = 400, linetype = 'dotted', colour = 'grey') +
  geom_segment(data = filter(is_dms_nc, int_name == 'nc'), mapping = aes(y=position, yend=position, x = 29 + log10_freq),
               xend = 24, colour = '#c070cc') +
  geom_point(data = filter(is_dms_nc, int_name == 'nc'), mapping = aes(y=position, x = 29 + log10_freq), colour = '#984ea3', shape=20, size = 0.5) +
  annotation_custom(text_grob(expression('log'[10]~'Frequency'), size = 6.5), ymin = 240, ymax = 240, xmin = 26.5, xmax = 26.5) +
  
  # Add regions
  annotate('segment', x = 23.75, xend = 23.75, size = 1, y = nc_regions$start, yend = nc_regions$end, colour = nc_regions$colour) +

    # Misc
  labs(y = 'N Position') +
  coord_cartesian(clip = 'off', expand = FALSE) +
  theme(axis.title.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.y = element_text(hjust = 0.35),
        panel.grid.major.y = element_blank(),
        plot.margin = unit(c(2,2,5,2), 'mm'),
        legend.title = element_markdown())

### Panel 6 - N interface variants?

### Assemble figure
size <- theme(text = element_text(size = 7))
p1 <- p_freq + labs(tag = 'A') + size
p2 <- p_freq_ddg + labs(tag = 'B') + size
p3 <- p_spike_dms + labs(tag = 'C') + size
p4 <- p_roc + labs(tag = 'D') + size
p5 <- p_is_dms + labs(tag = 'E') + size

figure <- multi_panel_figure(width = c(60, 60, 60), height = c(45, 45, 45, 45), panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1:2, column = 1) %>%
  fill_panel(p2, row = 1, column = 2) %>%
  fill_panel(p3, row = 1, column = 3) %>%
  fill_panel(p4, row = 3:4, column = 1) %>%
  fill_panel(p5, row = 2:4, column = 2:3)
ggsave('figures/figures/figure2.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/figure2.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
