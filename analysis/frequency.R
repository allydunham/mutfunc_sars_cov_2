#!/usr/bin/env Rscript
# Analyse Observed Frequency
source('src/config.R')
source('src/analysis.R')

variants <- load_variants()
plots <- list()

### Analyse ###
# filter(variants, freq > 0.01) %>% arrange(desc(freq)) %>% View()

plots$freq_hist <- ggplot(variants, aes(x = log10_freq)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = 'Log<sub>10</sub>Frequency',
       y = 'Count') +
  theme(axis.title.x = element_markdown())

### Save plots ###
save_plotlist(plots, 'figures/', verbose = 2, overwrite = 'all')
