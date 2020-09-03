#!/usr/bin/env Rscript
# Analyse SIFT Scores
source('src/config.R')
source('src/analysis.R')

variants <- load_variants()
sift <- read_tsv('data/output/sift.tsv')
protein_limits <- get_protein_limits(variants)
plots <- list()

### Analyse ###
plots$hist <- ggplot(variants, aes(x = log10_sift)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = 'Log<sub>10</sub>SIFT4G Score',
       y = 'Count') +
  theme(axis.title.x = element_markdown())

plots$vs_freq <- mutate(variants, freq_cat = classify_freq(freq)) %>%
  ggplot(aes(x = freq_cat, y = log10_sift)) +
  geom_violin(fill = 'cornflowerblue', colour = 'cornflowerblue') +
  labs(x = 'Frequency', y = expression('log'[10]*'SIFT4G Score'))

## Along proteins
summary <- group_by(variants, name, position, wt) %>%
  summarise(mean_sift = -mean(log10_sift),
            ptm = ptm[1],
            interface = int_name[1],
            .groups = 'drop') %>%
  mutate(interface = replace_na(interface, 'None'))

plot_sift_pos <- function(tbl, key){
  (ggplot() +
     geom_segment(data = tbl, mapping = aes(x = position, xend = position, yend = mean_sift, colour = interface), y = 0,
                  show.legend = n_distinct(tbl$interface) > 1) +
     geom_point(data = filter(tbl, !is.na(ptm)), mapping = aes(x = position, y = mean_sift, fill = ptm), shape = 21) +
     scale_colour_manual(name = 'Interface', values = int_colour_scale) +
     scale_fill_manual(values = c(phosphosite='red')) +
     labs(x = 'Position', y = expression("Mean -log"[10]*"(SIFT4G Score)"), title = key) +
     lims(y = c(0, 5))) %>%
    labeled_plot(units = 'cm', width = max(0.05 * max(tbl$position), 15), height = 10)
}

plots$per_position <- drop_na(summary, mean_sift) %>%
  group_by(name)
plots$per_position <- group_map(plots$per_position, plot_sift_pos) %>%
  set_names(group_keys(plots$per_position)$name)

## Matrices
plot_mat <- function(tbl, key){
  tiles <- ggplot(tbl, aes(x = position, y = mut, fill = log10_score)) +
     geom_tile(data = select(tbl, position, wt) %>% distinct(), mapping = aes(x = position, y = wt), fill = 'black') +
     geom_raster() +
     labs(x = 'Position', y = '') +
     scale_fill_distiller(name = 'log<sub>10</sub> SIFT4G Score', type = 'seq', palette = 'OrRd') +
     theme(axis.line = element_blank(),
           axis.ticks = element_blank(),
           panel.grid.major.y = element_blank(),
           legend.title = element_markdown())
  
  bars <- ggplot(tbl, aes(x = position, y = sift_median)) +
    geom_line() +
    lims(y = c(2, 4.325)) +
    labs(y = 'Median IC') +
    theme(axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank())
  
  ggarrange(bars, tiles, ncol = 1, align = 'v', common.legend = TRUE, legend = 'right', heights = c(1, 5)) %>%
    labeled_plot(units = 'cm', height = 15, width = max(20, 0.05 * max(tbl$position))) %>%
    return()
}

plots$matrices <- mutate(sift, log10_score = log10(sift_score + 0.00001)) %>%
  group_by(name) %>%
  group_map(plot_mat) %>%
  set_names(group_keys(group_by(sift, name))$name)

## Quality ##
plots$quality_hist <- (pivot_longer(sift, sift_median:num_seq, names_to = 'metric', values_to = 'value') %>%
                              mutate(metric = c(sift_median='Median IC', num_aa='# AA', num_seq='# Seq')[metric]) %>%
                              ggplot(aes(x=value, fill = metric)) +
                              geom_histogram(bins = 30, show.legend = FALSE) +
                              facet_wrap(~metric, nrow = 1, scales = 'free', strip.position = 'bottom') +
                              labs(x = '', y = 'Count') +
                              scale_fill_brewer(type = 'qual', palette = 'Set2') +
                              theme(strip.placement = 'outside')) %>%
  labeled_plot(units = 'cm', width = 40, height = 10)

plots$median_ic <- left_join(sift, select(variants, uniprot, name, position, wt, mut, freq), by = c('uniprot', 'name', 'position', 'wt', 'mut')) %>%
  drop_na() %>%
  mutate(log10_freq = log10(freq), log10_sift = log10(sift_score + 0.00001)) %>% 
  ggplot(aes(x = log10_freq, y = log10_sift, colour = sift_median)) +
  geom_point() +
  scale_colour_distiller(name = 'Median IC', type = 'seq', palette = 'YlOrRd', direction = -1) +
  labs(x = expression('log'[10]*'Frequency'), y = expression('log'[10]*'SIFT4G Score'))

plots$n_aa <- left_join(sift, select(variants, uniprot, name, position, wt, mut, freq), by = c('uniprot', 'name', 'position', 'wt', 'mut')) %>%
  drop_na() %>%
  mutate(log10_freq = log10(freq), log10_sift = log10(sift_score + 0.00001)) %>% 
  ggplot(aes(x = log10_freq, y = log10_sift, colour = clamp(num_aa, upper = 50))) +
  geom_point() +
  scale_colour_distiller(name = '# AA', type = 'seq', palette = 'YlOrRd', direction = -1) +
  labs(x = expression('log'[10]*'Frequency'), y = expression('log'[10]*'SIFT4G Score'))

plots$n_seq <- left_join(sift, select(variants, uniprot, name, position, wt, mut, freq), by = c('uniprot', 'name', 'position', 'wt', 'mut')) %>%
  drop_na() %>%
  mutate(log10_freq = log10(freq), log10_sift = log10(sift_score + 0.00001)) %>% 
  ggplot(aes(x = log10_freq, y = log10_sift, colour = clamp(num_seq, upper = 50))) +
  geom_point() +
  scale_colour_distiller(name = '# Seq', type = 'seq', palette = 'YlOrRd', direction = -1) +
  labs(x = expression('log'[10]*'Frequency'), y = expression('log'[10]*'SIFT4G Score'))

### Save plots ###
save_plotlist(plots, 'figures/sift', verbose = 2, overwrite = 'all')
