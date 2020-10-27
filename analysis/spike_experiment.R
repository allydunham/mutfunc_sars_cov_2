#!/usr/bin/env Rscript
# Compare predicted variant scores compared to experimental results
source('src/config.R')
source('src/analysis.R')

### Import Data ###
variants <- load_variants()

# Data from Starr et al. 2020 (media-3.csv from https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7310626/)
spike <- read_csv('data/starr_ace2_spike.csv') %>% 
  mutate(uniprot = 'P0DTC2', name = 's') %>%
  select(uniprot, name, position = site_SARS2, position_rbd = site_RBD, wt = wildtype, mut = mutant, binding=bind_avg, expression=expr_avg) %>%
  left_join(variants, by = c('uniprot', 'name', 'position', 'wt', 'mut'))

plots <- list()
### Analysis ###
plots$binding_cor <- ggplot(spike, aes(x = clamp(diff_interaction_energy, upper = 10), y = binding)) +
  geom_point() +
  geom_smooth(method = 'lm', formula = y ~ x) +
  labs(x = 'FoldX Interface ΔΔG (Clamped to <10 kj/mol)', y = 'Binding Fitness')
# filter(spike, !is.na(diff_interaction_energy)) %>% mutate(diff_interaction_energy = clamp(diff_interaction_energy, upper = 10)) %>% cor.test(formula = ~ diff_interaction_energy + binding, data = .)

plots$expression_cor <- ggplot(spike, aes(x = clamp(total_energy, upper = 10), y = expression)) +
  geom_point() +
  geom_smooth(method = 'lm', formula = y ~ x) +
  labs(x = 'FoldX ΔΔG (Clamped to <10 kj/mol)', y = 'Expression Fitness')
# filter(spike, !is.na(total_energy)) %>% mutate(total_energy = clamp(total_energy, upper = 10)) %>% cor.test(formula = ~ total_energy + binding, data = .)

plots$sift_score <- select(spike, binding, expression, sift_score) %>%
  pivot_longer(-sift_score, names_to = 'type', values_to = 'fitness') %>%
  mutate(category = ifelse(sift_score < 0.05, 'Deleterious', 'Neutral'),
         type = str_to_sentence(type)) %>%
  drop_na() %>%
  ggplot(aes(x = category, y = fitness, fill = category)) +
  facet_wrap(~type) +
  geom_boxplot(show.legend = FALSE) +
  stat_compare_means(comparisons = list(c('Deleterious', 'Neutral')), method = 't.test') +
  labs(x = 'SIFT4G Classification (Score < 0.05)', y = 'Deep Mutational Scanning Fitness') +
  scale_fill_brewer(type = 'qual', palette = 'Set1')

save_plotlist(plots, 'figures/ace2_dms')
