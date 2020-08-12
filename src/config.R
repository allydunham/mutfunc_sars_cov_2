#!/usr/bin/env Rscript
# Universal R Config

# Import packages
library(tidyverse)
library(broom)
library(ggpubr)
library(ggtext)

# Custom packages - available at github.com/allydunham
library(plotlistr)

### GGPlot theme ###
# clean with centered title by default
theme_set(theme_pubclean() + theme(legend.position = 'right',
                                   plot.title = element_text(hjust = 0.5),
                                   plot.subtitle = element_text(hjust = 0.5),
                                   strip.background = element_blank(),
                                   legend.key = element_blank()))