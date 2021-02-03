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
                                geom_point(data = filter(protein_limits, name %in% unique(int_positions$name)), mapping = aes(x = position), y = 0, alpha = 0) +
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
  labeled_plot(units = 'cm', height = 2.5 * n_distinct(conserved$name), width = 20)

plots$ddg <- (ggplot(conserved) +
                    facet_wrap(~name, ncol = 1, scales = 'free_x') +
                    geom_point(aes(x = position), y = 0, shape = NA) +
                    geom_segment(aes(x = position, xend = position, yend = mean_energy, colour = int_name), y = 0) +
                    geom_point(aes(x = position, y = mean_energy, colour = int_name)) +
                    coord_cartesian(clip = 'off') +
                    scale_colour_manual(name = 'Interface\nProtein', values = int_colour_scale) +
                    labs(x = 'Position', y = expression("Mean"~Delta*Delta*"G"))) %>%
  labeled_plot(units = 'cm', height = 2.5 * n_distinct(conserved$name), width = 40)

### In silico DMSs
is_dms <- function(tbl, interface){
  tbl <- group_by(tbl, name, position, wt, mut, log10_freq) %>%
    summarise(diff_interaction_energy = diff_interaction_energy[which.max(abs(diff_interaction_energy))], .groups = 'drop') %>%
    mutate(wt_int = factor(wt, levels = sort(Biostrings::AA_STANDARD)) %>% as.integer(),
                mut_int = factor(mut, levels = sort(Biostrings::AA_STANDARD)) %>% as.integer())
    
  tbl_summary <- group_by(tbl, position, wt_int) %>%
    summarise(mean_ddg = mean(diff_interaction_energy), .groups = 'drop')
  
  p <- ggplot() + 
    # Scale covers ddG heatmap, mean row and freq plot
    scale_x_continuous(breaks = c(1:20, 22, 24:29), limits = c(0, 29),
                       labels = c(sort(Biostrings::AA_STANDARD), expression(bar(Delta*Delta*G)), -5:0)) +
    
    # ddG heatmap & means row
    geom_tile(data = tbl, mapping = aes(x = mut_int, y = position, fill = clamp(diff_interaction_energy, lower = -5, upper = 5))) +
    geom_tile(data = tbl_summary, mapping = aes(x = wt_int, y = position), fill = 'grey', show.legend = FALSE) +
    geom_tile(data = tbl_summary, mapping = aes(x = 22, y = position, fill = mean_ddg), show.legend = FALSE) +
    scale_fill_gradientn(colours = c('#5e4fa2', '#3288bd', '#66c2a5', '#abdda4', '#e6f598', '#ffffbf',
                                     '#fee08b', '#fdae61', '#f46d43', '#d53e4f', '#9e0142'),
                         values = scales::rescale(-5:5, to=0:1), na.value = 'white', limits = c(-5, 5),
                         name = 'Interface &Delta;&Delta;G (kJ.mol<sup>-1</sup>)<br>Clamped to &plusmn;5<br>Largest effect used for multiple models') +
    # Add WT to legend
    geom_point(aes(colour = 'WT'), y = -100, x = -100, shape = 15, size = 5, show.legend = FALSE) +
    scale_colour_manual(name='', values = c(WT='grey')) +
    
    # Freq plot
    annotate('segment', x = 24:29, xend = 24:29, y = 0, yend = max(tbl$position), linetype = 'dotted', colour = 'grey') +
    geom_segment(data = tbl, mapping = aes(y=position, yend=position, x = 29 + log10_freq),
                 xend = 24) +
    geom_point(data = tbl, mapping = aes(y=position, x = 29 + log10_freq), shape=20) +
    
    # Misc
    labs(x = expression('log'[10]~'Frequency'), y = 'Position', title = interface) +
    coord_cartesian(clip = 'off', expand = FALSE) +
    theme(axis.ticks.x = element_blank(),
          axis.title.x = element_text(hjust = 1.05),
          panel.grid.major.y = element_blank(),
          plot.margin = unit(c(2,2,5,2), 'mm'),
          legend.title = element_markdown())
  labeled_plot(p, units = 'cm', height = max(max(tbl$position) * 0.05, 30), width = 20)
}

plots$is_dms <- select(variants, name, position, wt, mut, log10_freq, int_name, int_template, diff_interaction_energy) %>%
  drop_na(int_name, int_template) %>%
  mutate(name = display_names[name],
         int_name = display_names[int_name],
         int = str_c(name, ' - ', int_name)) %>%
  group_by(int) %>%
  {
    n <- group_keys(.)$int
    group_map(., ~is_dms(.x, .y$int)) %>%
      set_names(n)
  }
  

### Save plots ###
save_plotlist(plots, 'figures/interfaces', verbose = 2, overwrite = 'all')
