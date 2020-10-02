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
     labs(x = 'Position', y = expression("Mean FoldX"~Delta*Delta*"G (kj" %.% "mol"^-2*")"), title = key)) %>%
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
     geom_tile() +
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

## Factors
max_factors <- select(foldx, name, position, wt, backbone_hbond:entropy_complex) %>%
  group_by(name, position, wt) %>%
  summarise_at(vars(backbone_hbond:entropy_complex), mean) %>%
  pivot_longer(backbone_hbond:entropy_complex, names_to = 'factor', values_to = 'ddg') %>%
  group_by(name, position, wt) %>%
  filter(ddg == max(ddg, na.rm = TRUE))

factor_cols <- c(entropy_sidechain='#8dd3c7', sidechain_hbond='#ffffb3', solvation_polar='#bebada', van_der_waals_clashes='#fb8072',
                 solvation_hydrophobic='#80b1d3', backbone_hbond='#fdb462', entropy_mainchain='#b3de69', partial_covalent_bonds='#e41a1c',
                 electrostatics='#377eb8', backbone_clash='#4daf4a', helix_dipole='#984ea3', van_der_waals='#ff7f00', disulfide='#ffff33',
                 torsional_clash='#a65628')

plot_factors <- function(tbl, key){
  prot <- filter(protein_limits, name == key)
  (ggplot(tbl, aes(x = position, y = ddg, colour = factor)) +
      geom_point(data = prot, mapping = aes(x = position), y = 0, shape = NA, colour = NA) +
      geom_segment(aes(xend = position, yend = ddg), y = 0) +
      geom_point() +
      scale_colour_manual(name = 'Strongest\nComponent', values = factor_cols) +
      labs(x = 'Position', y = expression(Delta*Delta*G), title = key)) %>%
    labeled_plot(units = 'cm', width = max(20, 0.05 * max(prot$position)), height = 15)
}

plots$max_factors <- group_by(max_factors, name) %>%
  group_map(plot_factors) %>%
  set_names(group_keys(group_by(max_factors, name))$name)

### Save plots ###
save_plotlist(plots, 'figures/foldx', verbose = 2, overwrite = 'all')
