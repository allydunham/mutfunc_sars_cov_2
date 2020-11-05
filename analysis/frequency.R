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

plots$freq_change <- mutate_at(freqs, .vars = vars(-uniprot, -name, -position, -wt, -mut), .funs = ~log10(. + 0.00001)) %>%
  ggplot(aes(x = overall, y = last90days)) +
  geom_point(colour = 'cornflowerblue') +
  geom_abline(slope = 1) +
  geom_abline(slope = 1, intercept = 0.5, linetype = 'dashed') +
  geom_abline(slope = 1, intercept = -0.5, linetype = 'dashed') +
  geom_abline(slope = 1, intercept = 1, linetype = 'dotted') +
  geom_abline(slope = 1, intercept = -1, linetype = 'dotted') +
  labs(x = 'Overall frequency', y = 'Frequency in last 90 days')

plots$freq_per_region <- mutate_at(freqs, .vars = vars(-uniprot, -name, -position, -wt, -mut), .funs = ~log10(. + 0.00001)) %>%
  select(-last90days) %>%
  pivot_longer(NorthAfrica:Oceania, names_to = 'region', values_to = 'freq') %>%
  ggplot(aes(x = overall, y = freq, colour = region)) +
  facet_wrap(~region) +
  geom_point(show.legend = FALSE) +
  geom_abline(slope = 1) +
  geom_abline(slope = 1, intercept = 0.5, linetype = 'dashed') +
  geom_abline(slope = 1, intercept = -0.5, linetype = 'dashed') +
  geom_abline(slope = 1, intercept = 1, linetype = 'dotted') +
  geom_abline(slope = 1, intercept = -1, linetype = 'dotted') +
  labs(x = 'Overall frequency', y = 'Regional Frequency')

# Regional frequency changes
regional_freq_tests <- select(freqs, -last90days) %>%
  pivot_longer(NorthAfrica:Oceania, names_to='region', values_to='freq') %>%
  left_join(select(subsets, region=name, n), by='region') %>%
  mutate(count = round(n*freq),
         binom = pmap(list(overall, n, count), ~tidy(binom.test(..3, ..2, ..1)))) %>%
  unnest(cols = c(binom))

### Save plots ###
save_plotlist(plots, 'figures/', verbose = 2, overwrite = 'all')
