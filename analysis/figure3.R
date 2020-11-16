#!/usr/bin/env Rscript
# Generate figure 3 (High frequency variants - alignments, structures etc.)
source('src/config.R')
source('src/analysis.R')
library(png)

variants <- load_variants()
freqs <- read_tsv('data/output/frequency.tsv')
subsets <- read_tsv('data/frequency/subsets/summary.tsv')

### Panel - S - N439K (stabilising FoldX structure)
# PyMol Coords
# set_view (\
#           0.492808074,   -0.591798484,    0.637895107,\
#           -0.598377347,    0.301752806,    0.742216408,\
#           -0.631729662,   -0.747473598,   -0.205411986,\
#           0.001030162,    0.001419798, -458.790069580,\
#           222.544189453,  212.164047241,  212.693725586,\
#           341.063446045,  576.301269531,  -20.000000000 )
s_img <- readPNG('figures/figures/variants/s.png')
p_s_variants <- ggplot() +
  coord_fixed(expand = FALSE, xlim = c(0, 1), ylim = c(0, 1), clip = 'off') +
  annotation_raster(s_img, xmin = 0.1, xmax = 0.9, ymin = 0.1, ymax = 0.9) +
  
  annotate('segment', x = 0.7, xend = 0.75, y = 0.715, yend = 0.8) +
  annotate('richtext', x = 0.755, y = 0.8, hjust = 0,
           label = 'N439K',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.405, xend = 0.31, y = 0.58, yend = 0.85) +
  annotate('richtext', x = 0.3, y = 0.85, hjust = 1,
           label = 'T29I',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.475, xend = 0.6, y = 0.41, yend = 0.2) +
  annotate('richtext', x = 0.605, y = 0.2, hjust = 0,
           label = 'D614G',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.25, xend = 0.1, y = 0.33, yend = 0.15) +
  annotate('richtext', x = 0.09, y = 0.14, vjust = 1,
           label = 'V1068F',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  labs(subtitle = 'Spike Protein') +
  theme(axis.title = element_blank(), axis.text = element_blank(),
        axis.ticks = element_blank(), panel.grid.major.y = element_blank())

### Panel - A/ACE2
# PyMol View
# set_view (\
#           0.612106681,   -0.430461407,    0.663343191,\
#           -0.491768897,    0.449705899,    0.745604098,\
#           -0.619261503,   -0.782600701,    0.063581698,\
#           -0.000017494,    0.000017755, -294.500122070,\
#           -27.727266312,   11.856555939,   -5.606089592,\
#           218.007110596,  370.997283936,  -20.000000000 )
s_ace2_img <- readPNG('figures/figures/variants/s_ace2.png')
p_s_ace2_variants <- ggplot() +
  coord_fixed(expand = FALSE, xlim = c(0, 1), ylim = c(0, 1), clip = 'off') +
  annotation_raster(s_ace2_img, xmin = 0.1, xmax = 0.9, ymin = 0.1, ymax = 0.9) +
  
  annotate('segment', x = 0.270, xend = 0.15, y = 0.67, yend = 0.8) +
  annotate('richtext', x = 0.13, y = 0.81, hjust = 0, vjust = 0,
           label = 'F486L',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.42, xend = 0.495, y = 0.46, yend = 0.24) +
  annotate('richtext', x = 0.51, y = 0.25, hjust = 0, vjust = 1, 
           label = 'N501Y',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  labs(subtitle = 'Spike - ACE2 Complex') +
  theme(axis.title = element_blank(), axis.text = element_blank(),
        axis.ticks = element_blank(), panel.grid.major.y = element_blank())

### Panel - orf3a
# PyMol view
# set_view (\
#           0.198206469,   -0.100859635,   -0.974957108,\
#           -0.699580550,    0.682135403,   -0.212790310,\
#           0.686512470,    0.724237800,    0.064644232,\
#           -0.000381038,    0.000342563, -224.914428711,\
#           145.586242676,  144.836700439,  152.811203003,\
#           171.247375488,  278.578277588,  -20.000000000 )
orf3a_img <- readPNG('figures/figures/variants/orf3a.png')
p_orf3a_variants <- ggplot() +
  coord_fixed(expand = FALSE, xlim = c(0, 1), ylim = c(0, 1), clip = 'off') +
  annotation_raster(orf3a_img, xmin = 0.1, xmax = 0.9, ymin = 0.1, ymax = 0.9) +
  
  annotate('segment', x = 0.69, xend = 0.69, y = 0.82, yend = 0.87) +
  annotate('richtext', x = 0.69, y = 0.87, hjust = 0, vjust = 0,
           label = 'T223I',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.36, xend = 0.25, y = 0.45, yend = 0.75) +
  annotate('richtext', x = 0.23, y = 0.75, hjust = 0, vjust = 0, 
           label = 'Q57H',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.6, xend = 0.7, y = 0.4, yend = 0.25) +
  annotate('richtext', x = 0.705, y = 0.235, hjust = 0, vjust = 0,
           label = 'R126S',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.28, xend = 0.19, y = 0.26, yend = 0.13) +
  annotate('richtext', x = 0.17, y = 0.12, hjust = 0, vjust = 1, 
           label = 'L46F',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  labs(subtitle = 'Orf3a') +
  theme(axis.title = element_blank(), axis.text = element_blank(),
        axis.ticks = element_blank(), panel.grid.major.y = element_blank())


### Panel - N - R203K / G204R (SIFT4G Alignment), ~200 Phosphosite cluster?

### Panel - nsp7 - L71F (nsp8 interface destabilisation)


### Assemble figure
size <- theme(text = element_text(size = 8))
p1 <- p_s_variants + labs(tag = 'A') + size
p2 <- p_s_ace2_variants + labs(tag = 'B') + size
p3 <- p_orf3a_variants + labs(tag = 'C') + size

figure <- multi_panel_figure(width = c(90, 90), height = c(90, 90), panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1) %>%
  fill_panel(p2, row = 1, column = 2) %>%
  fill_panel(p3, row = 2, column = 1)
ggsave('figures/figures/figure3.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/figure3.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')