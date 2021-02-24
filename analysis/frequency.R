#!/usr/bin/env Rscript
# Analyse Observed Frequency
source('src/config.R')
source('src/analysis.R')

variants <- load_variants()
freqs <- read_tsv('data/output/frequency.tsv')
subsets <- read_tsv('data/frequency/subsets/summary.tsv')
plots <- list()

### Analyse ###
# filter(variants, freq > 0.01) %>% arrange(desc(freq)) %>% View()

plots$freq_hist <- ggplot(variants, aes(x = log10_freq)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = 'Log<sub>10</sub>Frequency',
       y = 'Count') +
  theme(axis.title.x = element_markdown())

# Plot most frequent variants
overall_top_freq_plot <- function(variants){
  frequent_variants <- drop_na(variants, freq) %>%
    filter(((sift_score < 0.05 & sift_median < 3.5 & sift_median > 2.75) | abs(total_energy) > 1 | !is.na(ptm) | !is.na(int_name))) %>%
    filter(freq > 0.001, !(freq < 0.01 & is.na(ptm) & is.na(int_name))) %>%
    arrange(desc(freq)) %>%
    mutate(str = str_c(name, ' ', wt, position, mut, ' (', signif(freq, 2), ')'),
           sift_sig = ifelse(sift_score < 0.05 & sift_median < 3.5 & sift_median > 2.75, 'Significant SIFT4G Score', 'Insignificant SIFT4G Score')) %>%
    group_by(name, position, wt, mut) %>%
    mutate(complex=str_c(unique(int_name), collapse = ', ')) %>%
    ungroup() %>%
    distinct(name, position, wt, mut, .keep_all = TRUE)
  
  p_freq <- ggplot(frequent_variants, mapping = aes(y = reorder(str, freq), x = freq, colour=sift_sig)) +
    geom_point(shape = 19) +
    lims(x = c(0, 1)) +
    labs(x = 'Overall Frequency') +
    scale_colour_manual(name = '', values = c(`Insignificant SIFT4G Score`='black', `Significant SIFT4G Score`='red')) +
    theme(panel.grid.major.x = element_line(linetype='dotted', colour = 'black'), axis.title.y = element_blank(), axis.ticks.y = element_blank())
  
  p_foldx <- ggplot(frequent_variants, mapping = aes(y = reorder(str, freq), x = total_energy, colour = abs(total_energy) > 1)) +
    geom_point(shape = 19, show.legend = FALSE) +
    scale_colour_manual(values = c(`TRUE`='blue', `FALSE`='black')) +
    geom_vline(xintercept = 1) +
    geom_vline(xintercept = -1) +
    labs(x = expression('FoldX'~Delta*Delta*G)) +
    theme(axis.ticks.y = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank())
  
  p_ptm <- ggplot(frequent_variants, aes(y = reorder(str, freq))) +
    geom_point(x = 0, colour = NA) +
    geom_point(data = filter(frequent_variants, !is.na(ptm)), x = 0, shape = 15, colour = 'green', size = 3) +
    labs(x = 'PTM') +
    lims(x = c(-0.1, 0.1)) +
    theme(axis.ticks = element_blank(), axis.text = element_blank(),
          axis.title.y = element_blank())
  
  p_complex <- ggplot(frequent_variants, aes(y = reorder(str, freq), x = diff_interaction_energy)) +
    geom_point(mapping = aes(colour = abs(diff_interaction_energy) > 1), show.legend = FALSE) +
    geom_text_repel(mapping = aes(label=complex), direction = 'x') +
    geom_vline(xintercept = 1) +
    geom_vline(xintercept = -1) +
    scale_colour_manual(values = c(`TRUE`='blue', `FALSE`='black')) +
    labs(x = 'Interfaces') +
    theme(axis.ticks.y = element_blank(), axis.text.y = element_blank(),
          axis.title.y = element_blank())
  
  ggarrange(p_freq, p_foldx, p_ptm, p_complex, common.legend = TRUE, legend = 'bottom', nrow = 1, widths = c(5,4,1,4), align = 'h')
}
plots$most_frequent_variants <- labeled_plot(overall_top_freq_plot(variants), units='cm', width=25, height=15)

# Frequency change
plots$freq_change <- mutate_at(freqs, .vars = vars(-uniprot, -name, -position, -wt, -mut), .funs = ~log10(. + 0.00001)) %>%
  ggplot(aes(x = overall, y = last90days)) +
  geom_point(colour = 'cornflowerblue') +
  geom_abline(slope = 1) +
  geom_abline(slope = 1, intercept = 0.5, linetype = 'dashed') +
  geom_abline(slope = 1, intercept = -0.5, linetype = 'dashed') +
  geom_abline(slope = 1, intercept = 1, linetype = 'dotted') +
  geom_abline(slope = 1, intercept = -1, linetype = 'dotted') +
  labs(x = 'Overall frequency', y = 'Frequency in last 90 days')

changing_top_freq_plot <- function(variants, freqs){
  frequent_variants <- select(freqs, name, position, wt, mut, overall, last90days) %>%
    mutate(diff = last90days - overall) %>%
    left_join(select(variants, -freq), by=c('name', 'position', 'wt', 'mut')) %>%
    filter((sift_score < 0.05 & sift_median < 3.5 & sift_median > 2.75) | abs(total_energy) > 1 | !is.na(ptm) | !is.na(int_name), abs(diff) > 0.01) %>%
    arrange(desc(diff)) %>%
    mutate(str = str_c(name, ' ', wt, position, mut, ' (', ifelse(diff > 0, '+', ''), signif(diff, 2), ')'),
           sift_sig = sift_score < 0.05 & sift_median < 3.5 & sift_median > 2.75) %>%
    group_by(name, position, wt, mut) %>%
    mutate(complex=str_c(unique(int_name), collapse = ', ')) %>%
    ungroup() %>%
    distinct(name, position, wt, mut, .keep_all = TRUE)
  
  p_freq <- ggplot(frequent_variants, mapping = aes(y = reorder(str, diff))) +
    geom_segment(mapping = aes(yend = reorder(str, diff), x = overall, xend = last90days),
                 arrow = arrow(angle = 20, type = 'closed', length = unit(0.2, 'cm'))) +
    geom_point(mapping = aes(x = overall), shape = 19, colour = 'black') +
    geom_point(mapping = aes(x = last90days), shape = 19, colour = 'firebrick2') +
    lims(x = c(0, 1)) +
    labs(x = 'Overall Frequency') +
    theme(panel.grid.major.x = element_line(linetype='dotted', colour = 'black'), axis.title.y = element_blank(), axis.ticks.y = element_blank())
  
  p_sift <- ggplot(frequent_variants, aes(y = reorder(str, diff))) +
    geom_point(x = 0, colour = NA) +
    geom_point(data = filter(frequent_variants, sift_sig), x = 0, shape = 15, colour = 'red', size = 3) +
    labs(x = 'SIFT4G') +
    lims(x = c(-0.1, 0.1)) +
    theme(axis.ticks = element_blank(), axis.text = element_blank(),
          axis.title.y = element_blank())
  
  p_foldx <- ggplot(frequent_variants, mapping = aes(y = reorder(str, diff), x = total_energy, colour = abs(total_energy) > 1)) +
    geom_point(shape = 19, show.legend = FALSE) +
    scale_colour_manual(values = c(`TRUE`='blue', `FALSE`='black')) +
    geom_vline(xintercept = 1) +
    geom_vline(xintercept = -1) +
    labs(x = expression('FoldX'~Delta*Delta*G)) +
    theme(axis.ticks.y = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank())
  
  p_ptm <- ggplot(frequent_variants, aes(y = reorder(str, diff))) +
    geom_point(x = 0, colour = NA) +
    geom_point(data = filter(frequent_variants, !is.na(ptm)), x = 0, shape = 15, colour = 'green', size = 3) +
    labs(x = 'PTM') +
    lims(x = c(-0.1, 0.1)) +
    theme(axis.ticks = element_blank(), axis.text = element_blank(),
          axis.title.y = element_blank())
  
  p_complex <- ggplot(frequent_variants, aes(y = reorder(str, diff), x = diff_interaction_energy)) +
    geom_point(mapping = aes(colour = abs(diff_interaction_energy) > 1), show.legend = FALSE) +
    geom_text_repel(mapping = aes(label=complex), direction = 'x') +
    geom_vline(xintercept = 1) +
    geom_vline(xintercept = -1) +
    scale_colour_manual(values = c(`TRUE`='blue', `FALSE`='black')) +
    labs(x = 'Interfaces') +
    theme(axis.ticks.y = element_blank(), axis.text.y = element_blank(),
          axis.title.y = element_blank())
  
  ggarrange(p_freq, p_sift, p_foldx, p_ptm, p_complex, common.legend = TRUE, legend = 'bottom', nrow = 1, widths = c(5,1,4,1,4), align = 'h')
}
plots$changing_frequency_variants <- labeled_plot(changing_top_freq_plot(variants, freqs), units='cm', width=25, height=15)

# Regional frequency changes
plots$freq_per_region <- mutate_at(freqs, .vars = vars(-uniprot, -name, -position, -wt, -mut), .funs = ~log10(. + 0.00001)) %>%
  select(-last90days) %>%
  pivot_longer(Caribbean:WestAsia, names_to = 'region', values_to = 'freq') %>%
  ggplot(aes(x = overall, y = freq, colour = region)) +
  facet_wrap(~region) +
  geom_point(show.legend = FALSE) +
  geom_abline(slope = 1) +
  geom_abline(slope = 1, intercept = 0.5, linetype = 'dashed') +
  geom_abline(slope = 1, intercept = -0.5, linetype = 'dashed') +
  geom_abline(slope = 1, intercept = 1, linetype = 'dotted') +
  geom_abline(slope = 1, intercept = -1, linetype = 'dotted') +
  labs(x = 'Overall frequency', y = 'Regional Frequency')

# Warning - this step takes a while (30+ mins on macbook pro 2015)
regional_freq_tests <- select(freqs, -last90days, -last180days) %>%
  pivot_longer(Caribbean:WestAsia, names_to='region', values_to='freq') %>%
  left_join(select(subsets, region=name, n), by='region') %>%
  mutate(count = round(n*freq),
         binom = pmap(list(overall, n, count), ~tidy(binom.test(..3, ..2, ..1)))) %>%
  unnest(cols = c(binom)) %>%
  mutate(padj = p.adjust(p.value, method = 'fdr'))

regional_top_freq_plot <- function(regional_freq_tests){
  frequent_variants <- filter(regional_freq_tests, padj < 0.01) %>%
    left_join(select(variants, -freq), by = c('uniprot', 'name', 'position', 'wt', 'mut')) %>%
    select(padj, region, overall_freq=overall, regional_freq=freq, everything()) %>%
    filter((sift_score < 0.05 & sift_median < 3.5 & sift_median > 2.75) | abs(total_energy) > 1 | !is.na(ptm) | !is.na(int_name),
           overall_freq > 0.05 | regional_freq > 0.05) %>%
    arrange(desc(overall_freq)) %>%
    group_by(region, name, position, wt, mut) %>%
    mutate(complex=str_c(unique(int_name), collapse = ', ')) %>%
    ungroup() %>%
    distinct(region, name, position, wt, mut, .keep_all = TRUE) %>%
    select(region, overall_freq, regional_freq, name, position, wt, mut, sift_score,
           sift_median, total_energy, ptm, complex, diff_interaction_energy) %>%
    mutate(str = str_c(name, ' ', wt, position, mut), sift_sig = sift_score < 0.05 & sift_median < 3.5 & sift_median > 2.75)
  frequent_variants_unique <- distinct(frequent_variants, name, position, wt, mut, .keep_all = TRUE)
  
  region_cols <- c(Caribbean='firebrick2', CentralAmerica='#e31a1c', CentralAsia='cyan', EastAsia='#a6cee3', Europe='#6a3d9a', 
                   NorthAfrica='#33a02c', NorthAmerica='#fb9a99', Oceania='#ffff99', SouthAmerica='#ff7f00', SouthAsia='#1f78b4', 
                   SouthEastAsia='#fdbf6f', SubSaharanAfrica='#b2df8a', UnitedKingdom='#f781bf', WestAsia='#cab2d6')
  p_freq <- ggplot(frequent_variants, mapping = aes(y = reorder(str, overall_freq))) +
    geom_point(mapping = aes(x = overall_freq), shape = 15, colour = 'black', size = 2) +
    geom_point(mapping = aes(x = regional_freq, fill = region), shape = 21) +
    scale_fill_manual(values = region_cols, name = '') +
    lims(x = c(0, 1)) +
    labs(x = 'Frequency') +
    theme(panel.grid.major.x = element_line(linetype='dotted', colour = 'black'), axis.title.y = element_blank(), axis.ticks.y = element_blank())
  
  p_sift <- ggplot(frequent_variants_unique, aes(y = reorder(str, overall_freq))) +
    geom_point(x = 0, colour = NA) +
    geom_point(data = filter(frequent_variants, sift_sig), x = 0, shape = 15, colour = 'red', size = 3) +
    labs(x = 'SIFT4G') +
    lims(x = c(-0.1, 0.1)) +
    theme(axis.ticks = element_blank(), axis.text = element_blank(),
          axis.title.y = element_blank())
  
  p_foldx <- ggplot(frequent_variants_unique, mapping = aes(y = reorder(str, overall_freq), x = total_energy, colour = abs(total_energy) > 1)) +
    geom_point(shape = 19, show.legend = FALSE) +
    scale_colour_manual(values = c(`TRUE`='blue', `FALSE`='black')) +
    geom_vline(xintercept = 1) +
    geom_vline(xintercept = -1) +
    labs(x = expression('FoldX'~Delta*Delta*G)) +
    theme(axis.ticks.y = element_blank(), axis.text.y = element_blank(), axis.title.y = element_blank())
  
  p_ptm <- ggplot(frequent_variants_unique, aes(y = reorder(str, overall_freq))) +
    geom_point(x = 0, colour = NA) +
    geom_point(data = filter(frequent_variants, !is.na(ptm)), x = 0, shape = 15, colour = 'green', size = 3) +
    labs(x = 'PTM') +
    lims(x = c(-0.1, 0.1)) +
    theme(axis.ticks = element_blank(), axis.text = element_blank(),
          axis.title.y = element_blank())
  
  p_complex <- ggplot(frequent_variants_unique, aes(y = reorder(str, overall_freq), x = diff_interaction_energy)) +
    geom_point(mapping = aes(colour = abs(diff_interaction_energy) > 1), show.legend = FALSE) +
    geom_text_repel(mapping = aes(label=complex), direction = 'x') +
    geom_vline(xintercept = 1) +
    geom_vline(xintercept = -1) +
    scale_colour_manual(values = c(`TRUE`='blue', `FALSE`='black')) +
    labs(x = 'Interfaces') +
    theme(axis.ticks.y = element_blank(), axis.text.y = element_blank(),
          axis.title.y = element_blank())
  
  ggarrange(p_freq, p_sift, p_foldx, p_ptm, p_complex, common.legend = TRUE, legend = 'bottom', nrow = 1, widths = c(5,1,4,1,4), align = 'h')
}
plots$regional_frequency_variants <- labeled_plot(regional_top_freq_plot(regional_freq_tests), units='cm', width=25, height=15)

### Save plots ###
save_plotlist(plots, 'figures/frequency', verbose = 2, overwrite = 'all')
