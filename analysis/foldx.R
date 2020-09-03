#!/usr/bin/env Rscript
# Analyse FoldX Scores
source('src/config.R')
source('src/analysis.R')

### Import Data ###
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

### Analyse ###
plots <- list()

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


### Save plots ###
save_plotlist(plots, 'figures/foldx', verbose = 2, overwrite = 'all')
