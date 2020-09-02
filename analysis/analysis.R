#!/usr/bin/env Rscript
# Analyse combined dataset - both for sanity checks and for discovery
source('src/config.R')

columns <- cols(
  uniprot = col_character(),
  name = col_character(),
  position = col_double(),
  wt = col_character(),
  mut = col_character(),
  sift_score = col_double(),
  template = col_character(),
  total_energy = col_double(),
  ptm = col_character(),
  int_uniprot = col_character(),
  int_name = col_character(),
  int_template = col_character(),
  interaction_energy = col_double(),
  diff_interaction_energy = col_double(),
  diff_interface_residues = col_integer(),
  freq = col_double()
)
variants <- read_tsv('data/output/summary.tsv', col_types = columns) %>%
  mutate(log10_sift = log10(sift_score + 1e-5),
         log10_freq = log10(freq + 1e-5))

sift <- read_tsv('data/output/sift.tsv')
foldx <- read_tsv('data/output/foldx.tsv')

ev_name_map = c(envelope='e', membrane='m', nsp1='nsp1', nsp10='nsp10', nsp11='nsp11', Nsp12='nsp12', nsp13='nsp13', nsp14='nsp14',
                nsp15='nsp15', Nsp15='nsp15', nsp16='nsp16', nsp2='nsp2', nsp3='nsp3', nsp4='nsp4', nsp5='nsp5', nsp6='nsp6', Nsp7='nsp7',
                nsp8='nsp8', nsp9='nsp9', nucleocapsid='nc', spike='s')
evcouplings <- dir('data/evcouplings/') %>%
  set_names() %>%
  map(~suppressMessages(read_csv(str_c('data/evcouplings/', .)))) %>%
  bind_rows(.id = 'name') %>%
  mutate(name = ev_name_map[str_split(name, '[_-]', simplify = TRUE)[,1]]) %>%
  select(-segment, -mutant, position=pos, mut=subs)

protein_limits <- group_by(variants, name) %>%
  filter(position == min(position) | position == max(position)) %>%
  ungroup() %>%
  select(name, position, wt) %>%
  distinct()

### Top Positions ###
# filter(variants, freq > 0.01) %>% arrange(desc(freq)) %>% View()

plots <- list()

### Histograms ###
plots$freq_hist <- ggplot(variants, aes(x = log10_freq)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = 'Log<sub>10</sub>Frequency',
       y = 'Count') +
  theme(axis.title.x = element_markdown())

plots$sift_hist <- ggplot(variants, aes(x = log10_sift)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = 'Log<sub>10</sub>SIFT4G Score',
       y = 'Count') +
  theme(axis.title.x = element_markdown())

plots$foldx_hist <- ggplot(variants, aes(x = total_energy)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = expression('FoldX'~Delta*Delta*'G'),
       y = 'Count')

plots$int_hist <- ggplot(variants, aes(x = diff_interaction_energy)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = expression('FoldX Interface'~Delta*Delta*'G'),
       y = 'Count')

plots$int_residues_hist <- ggplot(variants, aes(x = diff_interface_residues)) +
  geom_bar(fill = 'cornflowerblue') +
  scale_x_continuous(breaks = min(variants$diff_interface_residues, na.rm = TRUE):max(variants$diff_interface_residues, na.rm = TRUE)) +
  labs(x = 'Change in FoldX Interface Residue Count',
       y = 'Count') +
  theme(axis.title.x = element_markdown())

### Factors against each other ###
classify_freq <- function(x){
  out <- rep('> 0.01', length(x))
  out[x < 0.01] <- '< 0.01'
  out[x < 0.001] <- '< 0.001'
  out[x < 0.0001] <- '< 0.0001'
  out[is.na(x)] <- 'Not Observed'
  out <- factor(out, levels = c('Not Observed', '< 0.0001', '< 0.001', '< 0.01', '> 0.01'))
  return(out)
}
plots$sift_freq <- mutate(variants, freq_cat = classify_freq(freq)) %>%
  ggplot(aes(x = freq_cat, y = log10_sift)) +
  geom_violin(fill = 'cornflowerblue', colour = 'cornflowerblue') +
  labs(x = 'Frequency', y = expression('log'[10]*'SIFT4G Score'))

plots$foldx_freq <- mutate(variants, freq_cat = classify_freq(freq), ddg_clamped = clamp(total_energy, upper = 10)) %>%
  ggplot(aes(x = freq_cat, y = ddg_clamped)) +
  geom_violin(fill = 'cornflowerblue', colour = 'cornflowerblue') +
  labs(x = 'Frequency', y = expression('FoldX'~Delta*Delta*'G (Clamped to < 10)'))

plots$int_freq <- mutate(variants, freq_cat = classify_freq(freq)) %>%
  ggplot(aes(x = freq_cat, y = clamp(diff_interaction_energy, upper = 10))) +
  geom_violin(fill = 'cornflowerblue', colour = 'cornflowerblue') +
  labs(x = 'Frequency', y = expression('FoldX Interface'~Delta*Delta*'G (Clamped to < 10)'))

plots$int_residues_freq <- mutate(variants, freq_cat = classify_freq(freq)) %>%
  drop_na(diff_interface_residues) %>%
  count(freq_cat, diff_interface_residues) %>%
  complete(freq_cat, diff_interface_residues, fill = list(n=0)) %>%
  group_by(freq_cat) %>%
  mutate(total = sum(n), prop = n / total) %>%
  ungroup() %>%
  mutate(freq_cat = str_c(freq_cat, ' (n = ', total, ')')) %>%
  ggplot(aes(x = as.factor(diff_interface_residues), y = prop, fill = freq_cat)) +
  geom_col(position = 'dodge') +
  scale_fill_brewer(name = 'Variant Frequency', palette = 'Set1', type = 'qual') +
  labs(x = "Change in Interface Residues", y = 'Proportion of Frequency Group')

plots$ptm_freq <- mutate(variants, ptm = ifelse(is.na(ptm), 'None', str_to_title(ptm))) %>%
  ggplot(aes(x = log10(freq), colour = ptm)) +
  geom_line(stat = 'density') +
  scale_colour_brewer(name = 'PTM', palette = 'Set1', type = 'qual') +
  labs(x = expression(log[10](Frequency)), y = 'Density')

## Plot position of observed phosphomutants
# Includes start and end points of each protein to set x limits
observed_pho_positions <- group_by(variants, name) %>%
  filter(!all(is.na(ptm) | is.na(freq))) %>%
  filter((position == 1 & mut == 'A') | (position == max(position, na.rm = TRUE) & mut == 'A') | (!is.na(ptm) & !is.na(freq))) %>%
  ungroup() %>%
  select(name, position, wt, mut, ptm, log10_freq) %>%
  mutate(mimic = mut %in% c('E', 'D'),
         lab = ifelse(mimic, str_c(wt, ' %->% ', mut), NA))

mn_pho <- floor(min(observed_pho_positions$log10_freq, na.rm = TRUE))
plots$observed_phos <- (ggplot(filter(observed_pho_positions, !is.na(ptm))) +
  facet_wrap(~name, ncol = 1, scales = 'free_x') +
  geom_point(data = observed_pho_positions, mapping = aes(x = position), y = 0, alpha = 0) +
  geom_text_repel(aes(x = position, y = log10_freq, label = lab), parse=TRUE, nudge_x = 77, na.rm = TRUE) +
  geom_point(aes(x = position, y = log10_freq, colour = wt)) +
  geom_segment(aes(x = position, xend = position, yend = log10_freq, colour = wt), y = mn_pho) +
  scale_colour_brewer(name = 'WT', type = 'qual', palette = 'Dark2') +
  lims(y = c(mn_pho, 0)) +
  labs(x = 'Position', y = expression(log[10]~Frequency))) %>%
  labeled_plot(units = 'cm', width = 25, height = 5 * n_distinct(observed_pho_positions$name))

## Same with interfaces
observed_int_positions <- group_by(variants, name) %>%
  filter(!all(is.na(int_name) | is.na(freq))) %>%
  filter((position == 1 & mut == 'A') | (position == max(position, na.rm = TRUE) & mut == 'A') | (!is.na(int_name) & !is.na(freq))) %>%
  ungroup() %>%
  select(name, position, wt, mut, int_uniprot:diff_interface_residues, log10_freq)

mn_int <- floor(min(observed_int_positions$log10_freq, na.rm = TRUE))
plots$observed_interfaces <- (ggplot(filter(observed_int_positions, !is.na(int_name))) +
  facet_wrap(~name, ncol = 1, scales = 'free_x') +
  geom_point(data = observed_int_positions, mapping = aes(x = position), y = 0, alpha = 0) +
  geom_point(aes(x = position, y = log10_freq, colour = int_name)) +
  geom_segment(aes(x = position, xend = position, yend = log10_freq, colour = int_name), y = mn_int) +
  scale_colour_brewer(name = 'Interface\nProtein', type = 'qual', palette = 'Set2') +
  lims(y = c(mn_int, 0)) +
  labs(x = 'Position', y = expression(log[10]~Frequency))) %>%
  labeled_plot(units = 'cm', width = 25, height = 5 * n_distinct(observed_int_positions$name))

## Conserved Interfaces
interfaces <- filter(variants, !is.na(int_name)) %>%
  group_by(int_name, name, position, wt) %>%
  summarise(mean_sift = mean(log10_sift),
            mean_energy = mean(diff_interaction_energy),
            least_tolerated = mut[which.min(sift_score)],
            most_tolerated = mut[which.max(sift_score)],
            .groups = 'drop') %>%
  bind_rows(filter(protein_limits, name %in% .$name))

plots$int_sift <- (ggplot(interfaces) +
                     facet_wrap(~name, ncol = 1, scales = 'free_x') +
                     geom_point(aes(x = position), y = 0, shape = NA) +
                     geom_segment(aes(x = position, xend = position, yend = -mean_sift, colour = int_name), y = 0) +
                     geom_point(aes(x = position, y = -mean_sift, colour = int_name)) +
                     coord_cartesian(clip = 'off') +
                     scale_colour_brewer(name = 'Interface', type = "qual", palette = 'Dark2') +
                     labs(x = 'Position', y = expression("Mean -log"[10]*"(SIFT4G Score)"))) %>%
  labeled_plot(units = 'cm', height = 2.5 * n_distinct(interfaces$name), width = 20)

plots$int_ddg <- (ggplot(interfaces) +
                     facet_wrap(~name, ncol = 1, scales = 'free_x') +
                     geom_point(aes(x = position), y = 0, shape = NA) +
                     geom_segment(aes(x = position, xend = position, yend = mean_energy, colour = int_name), y = 0) +
                     geom_point(aes(x = position, y = mean_energy, colour = int_name)) +
                     coord_cartesian(clip = 'off') +
                     scale_colour_brewer(name = 'Interface', type = "qual", palette = 'Dark2') +
                     labs(x = 'Position', y = expression("Mean"~Delta*Delta*"G"))) %>%
  labeled_plot(units = 'cm', height = 2.5 * n_distinct(interfaces$name), width = 20)

### SIFT4G Quality ###
plots$sift_quality_hist <- (pivot_longer(sift, sift_median:num_seq, names_to = 'metric', values_to = 'value') %>%
                              mutate(metric = c(sift_median='Median IC', num_aa='# AA', num_seq='# Seq')[metric]) %>%
                              ggplot(aes(x=value, fill = metric)) +
                              geom_histogram(bins = 30, show.legend = FALSE) +
                              facet_wrap(~metric, nrow = 1, scales = 'free', strip.position = 'bottom') +
                              labs(x = '', y = 'Count') +
                              scale_fill_brewer(type = 'qual', palette = 'Set2') +
                              theme(strip.placement = 'outside')) %>%
  labeled_plot(units = 'cm', width = 40, height = 10)

plots$sift_median_ic <- left_join(sift, select(variants, uniprot, name, position, wt, mut, freq), by = c('uniprot', 'name', 'position', 'wt', 'mut')) %>%
  drop_na() %>%
  mutate(log10_freq = log10(freq), log10_sift = log10(sift_score + 0.00001)) %>% 
  ggplot(aes(x = log10_freq, y = log10_sift, colour = sift_median)) +
  geom_point() +
  scale_colour_distiller(name = 'Median IC', type = 'seq', palette = 'YlOrRd', direction = -1) +
  labs(x = expression('log'[10]*'Frequency'), y = expression('log'[10]*'SIFT4G Score'))

plots$sift_n_aa <- left_join(sift, select(variants, uniprot, name, position, wt, mut, freq), by = c('uniprot', 'name', 'position', 'wt', 'mut')) %>%
  drop_na() %>%
  mutate(log10_freq = log10(freq), log10_sift = log10(sift_score + 0.00001)) %>% 
  ggplot(aes(x = log10_freq, y = log10_sift, colour = clamp(num_aa, upper = 50))) +
  geom_point() +
  scale_colour_distiller(name = '# AA', type = 'seq', palette = 'YlOrRd', direction = -1) +
  labs(x = expression('log'[10]*'Frequency'), y = expression('log'[10]*'SIFT4G Score'))

plots$sift_n_seq <- left_join(sift, select(variants, uniprot, name, position, wt, mut, freq), by = c('uniprot', 'name', 'position', 'wt', 'mut')) %>%
  drop_na() %>%
  mutate(log10_freq = log10(freq), log10_sift = log10(sift_score + 0.00001)) %>% 
  ggplot(aes(x = log10_freq, y = log10_sift, colour = clamp(num_seq, upper = 50))) +
  geom_point() +
  scale_colour_distiller(name = '# Seq', type = 'seq', palette = 'YlOrRd', direction = -1) +
  labs(x = expression('log'[10]*'Frequency'), y = expression('log'[10]*'SIFT4G Score'))
   
### Vs EVCouplings ###
ev <- left_join(evcouplings, sift, by = c('name', 'position', 'wt', 'mut')) %>%
  mutate(log10_sift = log10(sift_score + 0.00001))

plots$sift_ev <- select(ev, name, prediction_epistatic, prediction_independent, log10_sift) %>%
  pivot_longer(starts_with('prediction'), names_to = 'type', names_prefix='prediction_', values_to = 'ev') %>%
  mutate(type = str_to_title(type)) %>%
  drop_na() %>%
  ggplot(aes(x = log10_sift, y = ev, colour = type)) +
  facet_grid(rows = vars(type), cols = vars(name)) +
  geom_point(shape = 20, show.legend = FALSE) +
  geom_smooth(method = 'lm', formula = y ~ x, colour = 'black') +
  scale_colour_brewer(name = 'EV Score', type = 'qual', palette = 'Dark2') +
  labs(x = expression('log'[10]*'SIFT4G Score'), y = 'EVCouplings Score')
plots$sift_ev <- labeled_plot(plots$sift_ev, units = 'cm', width = 60, height = 20)

plots$sift_ev_cor <- select(ev, name, prediction_epistatic, prediction_independent, log10_sift) %>%
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
plots$sift_ev_cor <- labeled_plot(plots$sift_ev_cor, units = 'cm', width = 20, height = 30)
  
plots$sift_ev_quality <- ggplot(ev, aes(x = log10_sift, y = prediction_epistatic, colour = sift_median)) +
  geom_point(shape = 20) +
  labs(x = expression('log'[10]*'SIFT4G Score'), y = 'Epistatic EVCouplings Score') +
  scale_colour_distiller(name = 'SIFT4G Median IC', type = 'seq', palette = 'YlGnBu')
plots$sift_ev_quality <- labeled_plot(plots$sift_ev_quality, units = 'cm', width = 15, height = 15)

plots$sift_ev_quality_hex <- ggplot(ev, aes(x = log10_sift, y = prediction_epistatic, z = sift_median, fill = ..value..)) +
  stat_summary_hex(fun = mean) +
  labs(x = expression('log'[10]*'SIFT4G Score'), y = 'Epistatic EVCouplings Score') +
  scale_fill_distiller(name = 'SIFT4G Median IC', type = 'seq', palette = 'YlGnBu')
plots$sift_ev_quality_hex <- labeled_plot(plots$sift_ev_quality_hex, units = 'cm', width = 15, height = 15)

### Save plots ###
save_plotlist(plots, 'figures/', verbose = 2, overwrite = 'all')
 