#!/usr/bin/env Rscript
# Analyse relationship to EVCouplings results
source('src/config.R')
source('src/analysis.R')

### Import Data ###
sift <- read_tsv('data/output/sift.tsv')

ev_name_map = c(envelope='e', membrane='m', nsp1='nsp1', nsp10='nsp10', nsp11='nsp11', Nsp12='nsp12', nsp13='nsp13', nsp14='nsp14',
                nsp15='nsp15', Nsp15='nsp15', nsp16='nsp16', nsp2='nsp2', nsp3='nsp3', nsp4='nsp4', nsp5='nsp5', nsp6='nsp6', Nsp7='nsp7',
                nsp8='nsp8', nsp9='nsp9', nucleocapsid='nc', spike='s')
evcouplings <- dir('data/evcouplings/') %>%
  set_names() %>%
  map(~suppressMessages(read_csv(str_c('data/evcouplings/', .)))) %>%
  bind_rows(.id = 'name') %>%
  mutate(name = ev_name_map[str_split(name, '[_-]', simplify = TRUE)[,1]]) %>%
  select(-segment, -mutant, position=pos, mut=subs)

ev <- left_join(evcouplings, sift, by = c('name', 'position', 'wt', 'mut')) %>%
  mutate(log10_sift = log10(sift_score + 0.00001))

### Analyse ###
plots <- list()

plots$sift <- select(ev, name, prediction_epistatic, prediction_independent, log10_sift) %>%
  pivot_longer(starts_with('prediction'), names_to = 'type', names_prefix='prediction_', values_to = 'ev') %>%
  mutate(type = str_to_title(type)) %>%
  drop_na() %>%
  ggplot(aes(x = log10_sift, y = ev, colour = type)) +
  facet_grid(rows = vars(type), cols = vars(name)) +
  geom_point(shape = 20, show.legend = FALSE) +
  geom_smooth(method = 'lm', formula = y ~ x, colour = 'black') +
  scale_colour_brewer(name = 'EV Score', type = 'qual', palette = 'Dark2') +
  labs(x = expression('log'[10]*'SIFT4G Score'), y = 'EVCouplings Score')
plots$sift <- labeled_plot(plots$sift, units = 'cm', width = 60, height = 20)

plots$sift_cor <- select(ev, name, prediction_epistatic, prediction_independent, log10_sift) %>%
  pivot_longer(starts_with('prediction'), names_to = 'type' , names_prefix='prediction_', values_to = 'ev') %>%
  mutate(type = str_to_title(type)) %>%
  drop_na() %>%
  group_by(name, type) %>%
  summarise(Pearson = cor(log10_sift, ev, method = 'pearson'),
            Spearman = cor(log10_sift, ev, method = 'spearman'),
            Kendall = cor(log10_sift, ev, method = 'kendall'),
            .groups = 'drop') %>%
  pivot_longer(c(-name, -type), names_to = 'metric', values_to = 'cor') %>%
  ggplot(aes(x = name, y = cor, fill = metric)) +
  facet_wrap(~type, ncol = 1) +
  geom_col(position = 'dodge') +
  scale_fill_brewer(name = 'Cefficient', type = 'qual', palette = 'Set1') +
  labs(y = 'Correlation') +
  theme(axis.title.x = element_blank(),
        axis.ticks.x = element_blank())
plots$sift_cor <- labeled_plot(plots$sift_cor, units = 'cm', width = 20, height = 30)

plots$sift_quality <- ggplot(ev, aes(x = log10_sift, y = prediction_epistatic, colour = sift_median)) +
  geom_point(shape = 20) +
  labs(x = expression('log'[10]*'SIFT4G Score'), y = 'Epistatic EVCouplings Score') +
  scale_colour_distiller(name = 'SIFT4G Median IC', type = 'seq', palette = 'YlGnBu')
plots$sift_quality <- labeled_plot(plots$sift_quality, units = 'cm', width = 15, height = 15)

plots$sift_quality_hex <- ggplot(ev, aes(x = log10_sift, y = prediction_epistatic, z = sift_median, fill = ..value..)) +
  stat_summary_hex(fun = mean) +
  labs(x = expression('log'[10]*'SIFT4G Score'), y = 'Epistatic EVCouplings Score') +
  scale_fill_distiller(name = 'SIFT4G Median IC', type = 'seq', palette = 'YlGnBu')
plots$sift_quality_hex <- labeled_plot(plots$sift_quality_hex, units = 'cm', width = 15, height = 15)

### Save plots ###
save_plotlist(plots, 'figures/evcouplings', verbose = 2, overwrite = 'all')
