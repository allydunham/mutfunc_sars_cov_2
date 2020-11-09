#!/usr/bin/env Rscript
# Generate figure 1 (Summary of the data sources/pipeline, stats of results/coverage, benchmark against frequency)
source('src/config.R')
source('src/analysis.R')

variants <- load_variants()

### Panel 1 - Schematic
p_schematic <- blank_plot(text = 'Schematic')

### Panel 2 - Coverage of data
p_coverage <- select(variants, name, position, sift_score, total_energy) %>%
  mutate(name = display_names[name]) %>%
  group_by(name, position) %>%
  summarise(foldx = any(!is.na(total_energy)), .groups = 'drop_last') %>%
  summarise(prop = sum(foldx) / n() * 100, .groups = 'drop') %>%
  pivot_longer(-name, names_to = 'tool', values_to = 'prop') %>%
  mutate(name = factor(name, levels = display_names)) %>%
  ggplot(aes(x = name, y = prop)) +
  geom_col(fill = '#e41a1c', width = 0.5) +
  lims(y = c(0, 100)) +
  labs(x = '', y = 'Structural Coverage (%)') +
  coord_flip(expand = FALSE) +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(linetype = 'dotted', colour = 'grey'),
        axis.ticks.y = element_blank())
  

### Panel 3 - Benchmarks against frequency
classify_freq <- function(x){
  out <- rep('> 10', length(x))
  out[x < 0.1] <- '1-10'
  out[x < 0.01] <- '0.1-1'
  out[x < 0.001] <- '0.01-0.1'
  out[x < 0.0001] <- '< 0.01'
  out[is.na(x)] <- 'Not Observed'
  out <- factor(out, levels = c('Not Observed', '< 0.01', '0.01-0.1', '0.1-1', '1-10', '> 10'))
  return(out)
}

p_sift_freq <- select(variants, sift_score, freq) %>%
  mutate(freq_cat = classify_freq(freq)) %>%
  drop_na(sift_score) %>%
  group_by(freq_cat) %>%
  summarise(mean = mean(sift_score), sd = sd(sift_score), .groups='drop') %>%
  ggplot() + 
  geom_segment(mapping = aes(x = freq_cat, xend = freq_cat, y = clamp(mean - sd, 0), yend = mean + sd), colour = 'cornflowerblue', size = 0.5) +
  geom_point(mapping = aes(x = freq_cat, y = mean), colour = '#377eb8') +
  geom_hline(yintercept = 0.05, linetype = 'dashed', colour = 'darkgrey') +
  labs(x = 'Variant Frequency (%)', y = 'SIFT4G Score')

p_foldx_freq <- select(variants, total_energy, freq) %>%
  mutate(freq_cat = classify_freq(freq)) %>%
  drop_na(total_energy) %>%
  group_by(freq_cat) %>%
  summarise(mean = mean(total_energy), sd = sd(total_energy), .groups='drop') %>%
  ggplot() + 
  geom_segment(mapping = aes(x = freq_cat, xend = freq_cat, y = mean - sd, yend = mean + sd), colour = '#e41a1c', size = 0.5) +
  geom_point(mapping = aes(x = freq_cat, y = mean), colour = '#e41a1c') +
  geom_hline(yintercept = 1, linetype = 'dashed', colour = 'darkgrey') +
  geom_hline(yintercept = -1, linetype = 'dashed', colour = 'darkgrey') +
  labs(x = 'Variant Frequency (%)', y = expression('FoldX'~Delta*Delta*G))

### Assemble figure
size <- theme(text = element_text(size = 8))
p1 <- p_schematic + labs(tag = 'A') + size
p2 <- p_coverage + labs(tag = 'B') + size
p3 <- p_sift_freq + labs(tag = 'C') + size
p4 <- p_foldx_freq + labs(tag = 'D') + size

figure1 <- multi_panel_figure(width = 183, height = 183, columns = 3, rows = 3,
                              panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1:3) %>%
  fill_panel(p2, row = 2:3, column = 1) %>%
  fill_panel(p3, row = 2, column = 2) %>%
  fill_panel(p4, row = 3, column = 2)
ggsave('figures/figures/figure1.pdf', figure1, width = figure_width(figure1), height = figure_height(figure1), units = 'mm')
ggsave('figures/figures/figure1.png', figure1, width = figure_width(figure1), height = figure_height(figure1), units = 'mm')