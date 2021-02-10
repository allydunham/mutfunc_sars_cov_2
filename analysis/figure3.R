#!/usr/bin/env Rscript
# Generate figure 3 (Variants of interest)
source('src/config.R')
source('src/analysis.R')
library(png)

variants <- load_variants()
freqs <- read_tsv('data/output/frequency.tsv')
subsets <- read_tsv('data/frequency/subsets/summary.tsv')

label_text_size = 2.5

# white - f3f3f3
# pale blue - 34e8b9
# UK blue - nitrogen
# SA red - red
# Br green - carbon
# All 3 - black
# SA/Br yellow - dash
# UK/SA purple - purpleblue
### Panel - S
s_img <- readPNG('figures/figures/variants/s.png')
p_s_variants <- ggplot() +
  coord_fixed(expand = FALSE, xlim = c(0, 1), ylim = c(0, 1), clip = 'off') +
  annotation_raster(s_img, xmin = 0.1, xmax = 0.9, ymin = 0.1, ymax = 0.9) +
  
  # All strains
  annotate('segment', x = 0.48, xend = 0.5, y = 0.1, yend = 0.37) +
  annotate('richtext', x = 0.5, y = 0.1, hjust = 1, vjust = 1, size = label_text_size,
           label = '<b>D614G (All)</b><br>87% Frequency',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.62, xend = 0.63, y = 0.86, yend = 0.725) +
  annotate('richtext', x = 0.6, y = 0.87, hjust = 0, vjust = 0, size = label_text_size,
           label = '<b>N501Y (All)</b><br>ACE2 Interface &Delta;&Delta;G = 5.75&thinsp;kJ.mol<sup>-1</sup><br>COVA2-04 Antibody Interface &Delta;&Delta;G = 1.57&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  # UK
  annotate('segment', x = 0.89, xend = 0.545, y = 0.34, yend = 0.4625) +
  annotate('richtext', x = 0.9, y = 0.35, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>A570D (UK)</b><br>&Delta;&Delta;G = 2.28&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.21, xend = 0.37, y = 0.09, yend = 0.285) +
  annotate('richtext', x = 0.2, y = 0.1, hjust = 1, vjust = 1, size = label_text_size,
           label = '<b>P681H (UK)</b><br>&Delta;&Delta;G = 1.96&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.26, xend = 0.425, y = 0.74, yend = 0.625) +
  annotate('richtext', x = 0.25, y = 0.75, hjust = 1, vjust = 1, size = label_text_size,
           label = '<b>S982A (UK)</b><br>&Delta;&Delta;G = -1.33&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  # SA
  annotate('segment', x = 0.74, xend = 0.49, y = 0.24, yend = 0.48) +
  annotate('richtext', x = 0.75, y = 0.25, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>D80A (SA)</b><br>&Delta;&Delta;G = 1.66&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.11, xend = 0.4, y = 0.29, yend = 0.45) +
  annotate('richtext', x = 0.1, y = 0.3, hjust = 1, vjust = 1, size = label_text_size,
           label = '<b>D215G (SA)</b><br>&Delta;&Delta;G = 2.56&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.21, xend = 0.415, y = 0.64, yend = 0.54) +
  annotate('richtext', x = 0.2, y = 0.65, hjust = 1, vjust = 1, size = label_text_size,
           label = '<b>R246N (SA)</b><br>&Delta;&Delta;G = 2.73&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  # Br
  annotate('segment', x = 0.69, xend = 0.495, y = 0.14, yend = 0.43) +
  annotate('richtext', x = 0.7, y = 0.15, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>P26S (Brazil)</b><br>&Delta;&Delta;G = 1.03&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.89, xend = 0.52, y = 0.59, yend = 0.525) +
  annotate('richtext', x = 0.9, y = 0.6, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>D138Y (Brazil)</b><br>&Delta;&Delta;G = 4.16&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.11, xend = 0.39, y = 0.49, yend = 0.52) +
  annotate('richtext', x = 0.1, y = 0.5, hjust = 1, vjust = 1, size = label_text_size,
           label = '<b>R190S (Brazil)</b><br>&Delta;&Delta;G = 3.47&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  # SA/Br
  annotate('segment', x = 0.89, xend = 0.515, y = 0.49, yend = 0.51) +
  annotate('richtext', x = 0.9, y = 0.5, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>L18F (SA/Brazil)</b><br>&Delta;&Delta;G = 2.92&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.84, xend = 0.7, y = 0.75, yend = 0.7) +
  annotate('richtext', x = 0.85, y = 0.76, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>E484K (SA/Brazil)</b><br>In ACE2 and Antibody interface<br>Stabilises ACE2 and REGN10933 binding<br>Destabilises H014 binding',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.30, xend = 0.605, y = 0.90, yend = 0.66) +
  annotate('richtext', x = 0.29, y = 0.91, hjust = 1, vjust = 1, size = label_text_size,
           label = '<b>K417 (SA/Brazil)</b><br>N mutant in SA, T mutant in Brazil<br>Both &Delta;&Delta;G > 1&thinsp;kJ.mol<sup>-1</sup><br>In ACE2 and Antibody binding site',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  # Key
  geom_point(aes(colour = c('UK', 'SA', 'Brazil', 'SA/Brazil')), x = -100, y = -100) +
  scale_colour_manual(name='', values = c(UK='#3333FF', SA='red', Brazil='#33FF33', `SA/Brazil`='#FF8000', `UK/SA`='#8000FF')) +
  
  labs(subtitle = 'Spike') +
  theme(axis.title = element_blank(), axis.text = element_blank(),
        axis.ticks = element_blank(), panel.grid.major.y = element_blank(),
        legend.position = 'bottom')

### Panel - orf8
orf8_img <- readPNG('figures/figures/variants/orf8.png')
p_orf8_variants <- ggplot() +
  coord_fixed(expand = FALSE, xlim = c(0, 1), ylim = c(0, 1), clip = 'off') +
  annotation_raster(orf8_img, xmin = 0.1, xmax = 0.9, ymin = 0.1, ymax = 0.9) +
  
  annotate('segment', x = 0.16, xend = 0.3, y = 0.14, yend = 0.35) +
  annotate('richtext', x = 0.15, y = 0.15, hjust = 1, vjust = 1, size = label_text_size,
           label = '<b>S24L (4%)</b><br>&Delta;&Delta;G = -1.3&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.16, xend = 0.3, y = 0.14, yend = 0.35) +
  annotate('richtext', x = 0.15, y = 0.85, hjust = 1, vjust = 1, size = label_text_size,
           label = '<b>E92K (SA)</b><br>&Delta;&Delta;G = 1.21&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.16, xend = 0.3, y = 0.14, yend = 0.35) +
  annotate('richtext', x = 0.85, y = 0.85, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>A51I (UK)</b><br>&Delta;&Delta;G = 2.13&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.16, xend = 0.3, y = 0.14, yend = 0.35) +
  annotate('richtext', x = 0.85, y = 0.15, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>Y73C (UK)</b><br>&Delta;&Delta;G = 1.93&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  labs(subtitle = 'orf8') +
  theme(axis.title = element_blank(), axis.text = element_blank(),
        axis.ticks = element_blank(), panel.grid.major.y = element_blank())

### Panel - orf3a
orf3a_img <- readPNG('figures/figures/variants/orf3a.png')
p_orf3a_variants <- ggplot() +
  coord_fixed(expand = FALSE, xlim = c(0, 1), ylim = c(0, 1), clip = 'off') +
  annotation_raster(orf3a_img, xmin = 0.1, xmax = 0.9, ymin = 0.1, ymax = 0.9) +
  
  annotate('segment', x = 0.69, xend = 0.71, y = 0.82, yend = 0.87) +
  annotate('richtext', x = 0.69, y = 0.87, hjust = 0, vjust = 0, size = label_text_size,
           label = '<b>T223I (1.1%)</b><br>In dimer interface<br>Interface &Delta;&Delta;G = 1.05&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.36, xend = 0.4, y = 0.45, yend = 0.79) +
  annotate('richtext', x = 0.4, y = 0.8, hjust = 1, vjust = 0, size = label_text_size,
           label = '<b>Q57H (25%)</b><br>&Delta;&Delta;G = 1.48&thinsp;kJ.mol<sup>-1</sup><br>In dimer interface<br>Interface &Delta;&Delta;G = 0.699&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.6, xend = 0.7, y = 0.4, yend = 0.25) +
  annotate('richtext', x = 0.705, y = 0.26, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>R126S (0.2%)</b><br>&Delta;&Delta;G = 3.43&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.28, xend = 0.19, y = 0.26, yend = 0.13) +
  annotate('richtext', x = 0.17, y = 0.12, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>L46F (0.3%)</b><br>&Delta;&Delta;G = 1.48&thinsp;kJ.mol<sup>-1</sup><br>In dimer interface<br>Interface &Delta;&Delta;G = 2.51&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  labs(subtitle = 'Orf3a') +
  theme(axis.title = element_blank(), axis.text = element_blank(),
        axis.ticks = element_blank(), panel.grid.major.y = element_blank())

### Panel - nsp7 / nsp8 / nsp12
# blue - 0x377eb8
# orange - 0xff7f00
# purple - 0x984ea3
nsp7_nsp8_nsp12_img <- readPNG('figures/figures/variants/nsp7_nsp8_pol.png')
p_nsp7_nsp8_nsp12_variants <- ggplot() +
  coord_fixed(expand = FALSE, xlim = c(0, 1), ylim = c(0, 1), clip = 'off') +
  annotation_raster(nsp7_nsp8_nsp12_img, xmin = 0.1, xmax = 0.9, ymin = 0.1, ymax = 0.9) +
  
  annotate('segment', x = 0.565, xend = 0.7, y = 0.71, yend = 0.8) +
  annotate('segment', x = 0.555, xend = 0.7, y = 0.38, yend = 0.8) +
  annotate('richtext', x = 0.71, y = 0.815, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>nsp8 I107V (0.2%)</b><br>&Delta;&Delta;G = 0.96&thinsp;kJ.mol<sup>-1</sup><br>In nsp7 and RdRp<br>interfaces',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.55, xend = 0.4, y = 0.6, yend = 0.75) +
  annotate('richtext', x = 0.39, y = 0.76, hjust = 1, vjust = 1, size = label_text_size, 
           label = '<b>nsp7 S25L (1.6%)</b><br>In nsp8 interfaces<br>Interface &Delta;&Delta;G = -1.33 to -1.54&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.49, xend = 0.65, y = 0.39, yend = 0.2) +
  annotate('richtext', x = 0.655, y = 0.21, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>RdRp P323L (87%)</b><br>Linked to S D614G<br>Not predicted significant',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.39, xend = 0.15, y = 0.34, yend = 0.12) +
  annotate('richtext', x = 0.12, y = 0.115, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>RdRp E254D (1%)</b><br>&Delta;&Delta;G = 2.32&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  geom_point(aes(x = -1, y = -1, colour = c('nsp7', 'nsp8', 'RdRp')), shape = 15, size = 4) +
  scale_colour_manual(name = '', values = c(nsp7='#984ea3', nsp8='#ff7f00', RdRp='#377eb8')) +
  labs(subtitle = 'nsp7 - nsp8 - RdRp Complex') +
  theme(axis.title = element_blank(), axis.text = element_blank(),
        axis.ticks = element_blank(), panel.grid.major.y = element_blank(),
        legend.position = c(0.5, 0.01), legend.direction = 'horizontal',
        legend.background = element_blank())

### Assemble figure
size <- theme(text = element_text(size = 8))
p1 <- p_s_variants + labs(tag = 'A') + size
p2 <- p_orf8_variants + labs(tag = 'B') + size
p3 <- p_orf3a_variants + labs(tag = 'C') + size
p4 <- p_nsp7_nsp8_nsp12_variants + labs(tag = 'D') + size

figure <- multi_panel_figure(width = c(60, 60, 60), height = c(180, 90), panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1:3) %>%
  fill_panel(p2, row = 2, column = 1) %>%
  fill_panel(p3, row = 2, column = 2) %>%
  fill_panel(p4, row = 2, column = 3)
ggsave('figures/figures/figure3.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/figure3.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')