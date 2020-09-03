#!/usr/bin/env Rscript
# Utility functions for analysis



classify_freq <- function(x){
  out <- rep('> 0.01', length(x))
  out[x < 0.01] <- '< 0.01'
  out[x < 0.001] <- '< 0.001'
  out[x < 0.0001] <- '< 0.0001'
  out[is.na(x)] <- 'Not Observed'
  out <- factor(out, levels = c('Not Observed', '< 0.0001', '< 0.001', '< 0.01', '> 0.01'))
  return(out)
}