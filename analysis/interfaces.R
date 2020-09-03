#!/usr/bin/env Rscript
# Analyse Interfaces
source('src/config.R')
source('src/analysis.R')

variants <- load_variants()
protein_limits <- get_protein_limits(variants)
plots <- list()

### Analyse ###
plots$ddg_hist <- ggplot(variants, aes(x = diff_interaction_energy)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = expression('FoldX Interface'~Delta*Delta*'G'),
       y = 'Count')

plots$residues_hist <- ggplot(variants, aes(x = diff_interface_residues)) +
  geom_bar(fill = 'cornflowerblue') +
  scale_x_continuous(breaks = min(variants$diff_interface_residues, na.rm = TRUE):max(variants$diff_interface_residues, na.rm = TRUE)) +
  labs(x = 'Change in FoldX Interface Residue Count',
       y = 'Count') +
  theme(axis.title.x = element_markdown())

plots$dgg_freq <- mutate(variants, freq_cat = classify_freq(freq)) %>%
  ggplot(aes(x = freq_cat, y = clamp(diff_interaction_energy, upper = 10))) +
  geom_violin(fill = 'cornflowerblue', colour = 'cornflowerblue') +
  labs(x = 'Frequency', y = expression('FoldX Interface'~Delta*Delta*'G (Clamped to < 10)'))

plots$residues_freq <- mutate(variants, freq_cat = classify_freq(freq)) %>%
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

## Observed Interfaces
observed <- filter(variants, !is.na(int_name), !is.na(log10_freq)) %>%
  select(name, position, wt, mut, int_uniprot:diff_interface_residues, log10_freq)

int_positions <- select(variants, name, position, int_name) %>%
  drop_na() %>%
  distinct()

min_freq <- floor(min(observed$log10_freq, na.rm = TRUE))
plots$observed_interfaces <- (ggplot() +
                                facet_wrap(~name, ncol = 1, scales = 'free_x') +
                                geom_point(data = protein_limits, mapping = aes(x = position), y = 0, alpha = 0) +
                                geom_point(data = int_positions, mapping = aes(x = position, colour = int_name), y = min_freq, shape = 15) +
                                geom_point(data = observed, mapping = aes(x = position, y = log10_freq, colour = int_name)) +
                                geom_segment(data = observed, mapping = aes(x = position, xend = position, yend = log10_freq, colour = int_name), y = min_freq) +
                                scale_colour_manual(name = 'Interface\nProtein', values = int_colour_scale) +
                                lims(y = c(min_freq, 0)) +
                                labs(x = 'Position', y = expression(log[10]~Frequency))) %>%
  labeled_plot(units = 'cm', width = 25, height = 5 * n_distinct(int_positions$name))

## Conserved Interfaces
conserved <- filter(variants, !is.na(int_name)) %>%
  group_by(int_name, name, position, wt) %>%
  summarise(mean_sift = mean(log10_sift),
            mean_energy = mean(diff_interaction_energy),
            least_tolerated = mut[which.min(sift_score)],
            most_tolerated = mut[which.max(sift_score)],
            .groups = 'drop') %>%
  bind_rows(filter(protein_limits, name %in% .$name))

plots$sift <- (ggplot(conserved) +
                     facet_wrap(~name, ncol = 1, scales = 'free_x') +
                     geom_point(aes(x = position), y = 0, shape = NA) +
                     geom_segment(aes(x = position, xend = position, yend = -mean_sift, colour = int_name), y = 0) +
                     geom_point(aes(x = position, y = -mean_sift, colour = int_name)) +
                     coord_cartesian(clip = 'off') +
                     scale_colour_manual(name = 'Interface\nProtein', values = int_colour_scale) +
                     labs(x = 'Position', y = expression("Mean -log"[10]*"(SIFT4G Score)"))) %>%
  labeled_plot(units = 'cm', height = 2.5 * n_distinct(interfaces$name), width = 20)

plots$ddg <- (ggplot(conserved) +
                    facet_wrap(~name, ncol = 1, scales = 'free_x') +
                    geom_point(aes(x = position), y = 0, shape = NA) +
                    geom_segment(aes(x = position, xend = position, yend = mean_energy, colour = int_name), y = 0) +
                    geom_point(aes(x = position, y = mean_energy, colour = int_name)) +
                    coord_cartesian(clip = 'off') +
                    scale_colour_manual(name = 'Interface\nProtein', values = int_colour_scale) +
                    labs(x = 'Position', y = expression("Mean"~Delta*Delta*"G"))) %>%
  labeled_plot(units = 'cm', height = 2.5 * n_distinct(interfaces$name), width = 20)

### Save plots ###
save_plotlist(plots, 'figures/interfaces', verbose = 2, overwrite = 'all')
