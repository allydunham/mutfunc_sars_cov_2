#!/usr/bin/env Rscript
# Generate figure 3 (High frequency variants - alignments, structures etc.)
source('src/config.R')
source('src/analysis.R')
library(png)

variants <- load_variants()
freqs <- read_tsv('data/output/frequency.tsv')
subsets <- read_tsv('data/frequency/subsets/summary.tsv')

label_text_size = 2.5

# white - f3f3f3
# blue - 34e8b9
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
  annotate('richtext', x = 0.755, y = 0.81, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>N439K (0.9%)</b><br>&Delta;&Delta;G = -1.15&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.405, xend = 0.31, y = 0.58, yend = 0.85) +
  annotate('richtext', x = 0.3, y = 0.86, hjust = 1, vjust = 1, size = label_text_size,
           label = '<b>T29I (0.2%)</b><br>&Delta;&Delta;G = 1.59&thinsp;kJ.mol<sup>-1</sup><br>Phosphosite',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.475, xend = 0.6, y = 0.41, yend = 0.2) +
  annotate('richtext', x = 0.605, y = 0.21, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>D614G (87%)</b><br>&Delta;&Delta;G = 1.65&thinsp;kJ.mol<sup>-1</sup><br>In S-S interface',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.25, xend = 0.1, y = 0.33, yend = 0.15) +
  annotate('richtext', x = 0.07, y = 0.14, vjust = 1, hjust = 0, size = label_text_size,
           label = '<b>V1068F (0.2%)</b><br>In S-S interface<br>Interface &Delta;&Delta;G = 2.05&thinsp;kJ.mol<sup>-1</sup>',
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
  
  annotate('segment', x = 0.270, xend = 0.15, y = 0.67, yend = 0.85) +
  annotate('richtext', x = 0.13, y = 0.86, hjust = 0, vjust = 0, size = label_text_size,
           label = '<b>F486L (0.06%)</b><br>Interface &Delta;&Delta;G = 1.14&thinsp;kJ.mol<sup>-1</sup>',
           fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt")) +
  
  annotate('segment', x = 0.42, xend = 0.495, y = 0.46, yend = 0.24) +
  annotate('richtext', x = 0.51, y = 0.25, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>N501Y (0.04%)</b><br>Interface &Delta;&Delta;G = 5.03&thinsp;kJ.mol<sup>-1</sup><br>SIFT4G Score = 0.04',
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
  
  annotate('segment', x = 0.69, xend = 0.71, y = 0.82, yend = 0.87) +
  annotate('richtext', x = 0.69, y = 0.87, hjust = 0, vjust = 0, size = label_text_size,
           label = '<b>T223I (1.1%)</b><br>In dimer interface<br>Interface &Delta;&Delta;G = 2.51&thinsp;kJ.mol<sup>-1</sup>',
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
# PyMol Coords
# set_view (\
#           0.716750860,   -0.693986356,    0.068173833,\
#           0.042574126,   -0.054031096,   -0.997629046,\
#           0.696024716,    0.717957973,   -0.009179173,\
#           -0.001143366,   -0.000001438, -375.847808838,\
#           112.391754150,  123.914146423,  131.940490723,\
#           296.517120361,  455.289459229,  -20.000000000 )
nsp7_nsp8_nsp12_img <- readPNG('figures/figures/variants/nsp7_nsp8_pol.png')
p_nsp7_nsp8_nsp12_variants <- ggplot() +
  coord_fixed(expand = FALSE, xlim = c(0, 1), ylim = c(0, 1), clip = 'off') +
  annotation_raster(nsp7_nsp8_nsp12_img, xmin = 0.1, xmax = 0.9, ymin = 0.1, ymax = 0.9) +
  
  annotate('segment', x = 0.565, xend = 0.7, y = 0.71, yend = 0.8) +
  annotate('segment', x = 0.555, xend = 0.7, y = 0.38, yend = 0.8) +
  annotate('richtext', x = 0.71, y = 0.815, hjust = 0, vjust = 1, size = label_text_size,
           label = '<b>nsp8 I107V (0.2%)</b><br>&Delta;&Delta;G = 1.22&thinsp;kJ.mol<sup>-1</sup><br>In nsp7 and RdRp<br>interfaces',
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
p2 <- p_s_ace2_variants + labs(tag = 'B') + size
p3 <- p_orf3a_variants + labs(tag = 'C') + size
p4 <- p_nsp7_nsp8_nsp12_variants + labs(tag = 'D') + size

figure <- multi_panel_figure(width = c(90, 90), height = c(90, 90), panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
  fill_panel(p1, row = 1, column = 1) %>%
  fill_panel(p2, row = 1, column = 2) %>%
  fill_panel(p3, row = 2, column = 1) %>%
  fill_panel(p4, row = 2, column = 2)
ggsave('figures/figures/figure3.pdf', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')
ggsave('figures/figures/figure3.png', figure, width = figure_width(figure), height = figure_height(figure), units = 'mm')