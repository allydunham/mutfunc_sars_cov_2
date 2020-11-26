#!/usr/bin/env Rscript
# Generate figure 4 (Experimental results)
source('src/config.R')
source('src/analysis.R')

variants <- load_variants()

### Panel - 

### Assemble figure
size <- theme(text = element_text(size = 7))
p1 <- blank_plot('Experiment Results') + labs(tag = 'A') + size

figure <- multi_panel_figure(width = 183, height = 183, panel_label_type = 'none', row_spacing = 0, column_spacing = 0, rows = 1, columns = 1) %>%
  fill_panel(p1, row = 1, column = 1)
ggsave('figures/figures/figure4.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/figure4.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')