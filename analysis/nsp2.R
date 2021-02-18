#!/usr/bin/env Rscript
# Explore variants specifically in Nsp2
source('src/config.R')
source('src/analysis.R')

foldx <- read_tsv('data/nsp2_foldx/average.fxout') %>%
  select(-chain)

variants <- load_variants() %>% filter(name == 'nsp2') %>%
  select(uniprot, name, position, wt, mut, freq, log10_freq, ptm, sift_score, log10_sift, sift_median) %>%
  left_join(select(foldx, position, wt, mut, total_energy), by = c('position', 'wt', 'mut')) %>%
  mutate(freq_cat = classify_freq(freq),
         sift_sig = ifelse(sift_score < 0.05, 'Deleterious', 'Neutral'))

plots <- list()
plots$sift_dist <- select(variants, sift_score, freq) %>%
  mutate(freq_cat = classify_freq(freq)) %>%
  drop_na(sift_score) %>%
  group_by(freq_cat) %>%
  summarise(mean = mean(sift_score), sd = sd(sift_score), .groups='drop') %>%
  ggplot() + 
  geom_hline(yintercept = 0.05, linetype = 'dotted', colour = 'black') +
  geom_segment(mapping = aes(x = freq_cat, xend = freq_cat, y = clamp(mean - sd, 0), yend = mean + sd), colour = '#377eb8', size = 0.5) +
  geom_point(mapping = aes(x = freq_cat, y = mean), colour = '#377eb8') +
  geom_text_repel(data = filter(variants, freq_cat %in% c('1-10', '> 10') | (freq_cat == '0.1-1' & sift_score < 0.05)),
                  mapping = aes(x = freq_cat, y = sift_score, label = str_c(wt, position, mut)), nudge_x = 0.3, force = 4) +
  labs(x = 'Variant Frequency (%)', y = 'SIFT4G Score')

plots$sift_dist_viol <- ggplot(variants, aes(x = freq_cat, y = sift_score)) + 
  geom_violin(fill = '#377eb8', colour = NA, size = 0.5) +
  geom_hline(yintercept = 0.05, linetype = 'dotted', colour = 'black') +
  geom_point(data = filter(variants, freq_cat %in% c('0.1-1', '1-10', '> 10'))) +
  geom_text_repel(data = filter(variants, freq_cat %in% c('1-10', '> 10') | (freq_cat == '0.1-1' & sift_score < 0.05)),
                  mapping = aes(label = str_c(wt, position, mut)), nudge_x = c(0.4, -0.4), force = 4) +
  labs(x = 'Variant Frequency (%)', y = 'SIFT4G Score')

plots$sift_log10_dist_viol <- ggplot(variants, aes(x = freq_cat, y = -log10_sift)) + 
  geom_violin(fill = '#377eb8', size = 0.5) +
  geom_hline(yintercept = -log10(0.05), linetype = 'dotted', colour = 'black') +
  geom_point(data = filter(variants, freq_cat %in% c('0.1-1', '1-10', '> 10'))) +
  geom_text_repel(data = filter(variants, freq_cat %in% c('1-10', '> 10') | (freq_cat == '0.1-1' & sift_score < 0.05)) %>% arrange(desc(freq_cat), log10_sift),
                  mapping = aes(label = str_c(wt, position, mut)), nudge_x = c(0.4, -0.4), nudge_y = c(0, 0.1, 0, -0.1), force = 4) +
  labs(x = 'Variant Frequency', y = expression(-log[10]~'SIFT4G Score'))

plots$foldx <- ggplot(variants, aes(x = freq * 100, y = clamp(total_energy, -10, 10))) +
  geom_point(aes(colour = sift_sig)) +
  geom_text_repel(data = filter(variants, freq > 0.003 | (freq > 0.001 & abs(total_energy) > 1)),
                  mapping = aes(label = str_c(wt, position, mut)), nudge_x = 0.3, size = 3, segment.size = 0.25) +
  geom_hline(yintercept = c(-1, 1), linetype = 'dotted') +
  scale_x_log10(labels = function(x){str_c(x, '%')}) +
  scale_colour_manual(name = 'SIFT Prediction', values = c(Neutral='black', Deleterious='red')) +
  labs(x = 'Frequency', y = expression(Delta*Delta*G~'(kJ'%.%'mol'^-1*', clamped to'%+-%'10)'),
       subtitle = 'Nsp2 Structural Destabilisation')

save_plotlist(plots, 'figures/nsp2', overwrite = 'all')
