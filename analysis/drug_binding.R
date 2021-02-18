#!/usr/bin/env Rscript
# Explore Drug interactions
source('src/config.R')
source('src/analysis.R')

drug_sites <- read_tsv('data/drug_interactions.tsv') %>%
  rename(name = gene, wt = aminoacid, drug_pdb = pdb)

variants <- load_variants() %>%
  left_join(drug_sites, by = c('name', 'position', 'wt'))

plots <- list()
plots$conservation <- group_by(variants, name) %>%
  filter(any(!is.na(ligand))) %>%
  ungroup() %>%
  ggplot(aes(x = ifelse(is.na(ligand), 'No Binding Site', 'Binding Site'), y = -log10_sift)) +
  geom_boxplot(fill = 'cornflowerblue', outlier.shape = 20) +
  geom_hline(yintercept = -log10(0.05), linetype = 'dotted') +
  stat_compare_means(comparisons = list(c('No Binding Site', 'Binding Site'))) +
  stat_summary(geom = 'text', fun.data = function(x){data.frame(label = str_c('n = ', length(x)), y = -0.2)}) +
  coord_cartesian(clip = 'off') +
  scale_y_continuous(breaks = 0:5, limits = c(-0.2, 5.5)) +
  labs(x = '', y = expression(-log[10]*'SIFT4G Score'),
       subtitle = 'Conservation of binding site positions compared to other positions in the same proteins')

save_plotlist(plots, 'figures/drug_binding', overwrite = 'all')
