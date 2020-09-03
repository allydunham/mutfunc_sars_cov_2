#!/usr/bin/env Rscript
# Analyse FoldX Scores
source('src/config.R')
source('src/analysis.R')

### Import Data ###
variants <- load_variants()
foldx <- read_tsv('data/output/foldx.tsv')
protein_limits <- get_protein_limits(variants)
plots <- list()

### Analyse ###
plots$hist <- ggplot(variants, aes(x = total_energy)) +
  geom_histogram(fill = 'cornflowerblue', bins = 40) +
  labs(x = expression('FoldX'~Delta*Delta*'G'),
       y = 'Count')

plots$vs_freq <- mutate(variants, freq_cat = classify_freq(freq), ddg_clamped = clamp(total_energy, upper = 10)) %>%
  ggplot(aes(x = freq_cat, y = ddg_clamped)) +
  geom_violin(fill = 'cornflowerblue', colour = 'cornflowerblue') +
  labs(x = 'Frequency', y = expression('FoldX'~Delta*Delta*'G (Clamped to < 10)'))

## Along Proteins
summary <- group_by(variants, name, position, wt) %>%
  summarise(mean_ddg = mean(total_energy),
            ptm = ptm[1],
            interface = int_name[1],
            .groups = 'drop') %>%
  mutate(interface = replace_na(interface, 'None'))

plot_fx_pos <- function(tbl, key){
  (ggplot() +
     geom_point(data = tbl, mapping = aes(x = position), y = 0, shape = NA) +
     geom_segment(data = tbl, mapping = aes(x = position, xend = position, yend = mean_ddg, colour = interface), y = 0,
                  show.legend = n_distinct(tbl$interface) > 1) +
     geom_point(data = filter(tbl, !is.na(ptm)), mapping = aes(x = position, y = mean_ddg, fill = ptm), shape = 21) +
     scale_colour_manual(name = 'Interface', values = int_colour_scale) +
     scale_fill_manual(values = c(phosphosite='red')) +
     labs(x = 'Position', y = expression("Mean -log"[10]*"(SIFT4G Score)"), title = key)) %>%
    labeled_plot(units = 'cm', width = max(0.05 * max(tbl$position), 15), height = 10)
}

plots$foldx_positions <- group_by(summary, name) %>%
  filter(!all(is.na(mean_ddg))) %>%
  group_by(name)
plots$foldx_positions <- group_map(plots$foldx_positions, plot_fx_pos) %>%
  set_names(group_keys(plots$foldx_positions)$name)

## Matrices
plot_mat <- function(tbl, key){
  (ggplot(tbl, aes(x = position, y = mut, fill = clamp(total_energy, lower = -5, upper = 5))) +
     geom_tile(data = select(tbl, position, wt) %>% distinct(), mapping = aes(x = position, y = wt), fill = 'black') +
     geom_raster() +
     labs(x = 'Position', y = '', title = key) +
     scale_fill_distiller(name = 'Clamped &Delta;&Delta;G', type = 'div', palette = 'RdYlBu', limits = c(-5, 5), na.value = 'lightgrey') +
     theme(axis.line = element_blank(),
           axis.ticks = element_blank(),
           panel.grid.major.y = element_blank(),
           legend.title = element_markdown())) %>%
    labeled_plot(units = 'cm', height = 15, width = max(20, 0.05 * max(tbl$position)))
}

plots$matrices <- group_by(variants, name) %>%
  group_map(plot_mat) %>%
  set_names(group_keys(group_by(variants, name))$name)

### Save plots ###
save_plotlist(plots, 'figures/foldx', verbose = 2, overwrite = 'all')
