#!/usr/bin/env Rscript
# Utility functions for analysis

load_variants <- function(){
  columns <- cols(
    uniprot = col_character(),
    name = col_character(),
    position = col_double(),
    wt = col_character(),
    mut = col_character(),
    sift_score = col_double(),
    template = col_character(),
    relative_surface_accessibility = col_double(),
    foldx_ddg = col_double(),
    ptm = col_character(),
    int_uniprot = col_character(),
    int_name = col_character(),
    int_template = col_character(),
    interaction_energy = col_double(),
    diff_interaction_energy = col_double(),
    diff_interface_residues = col_integer(),
    freq = col_double(),
    mut_escape_mean = col_double(),
    mut_escape_max = col_double(),
    annotation = col_character()
  )
  read_tsv('data/output/summary.tsv', col_types = columns) %>%
    rename(total_energy = foldx_ddg) %>%
    mutate(log10_sift = log10(sift_score + 1e-5),
           log10_freq = log10(freq + 1e-5))
}

# Select a list of variants (x) from the dataset, written as e.g. s A22V
view_variants <- function(df, x){
  keys <- str_c(df$name, ' ', df$wt, df$position, df$mut)
  df[keys %in% x,]
}

split_orf1a <- function(x) {
  protein <- rep(NA, length(x))
  
  protein[x < 7096] <- 'nsp16'
  protein[x < 6798] <- 'nsp15'
  protein[x < 6452] <- 'nsp14'
  protein[x < 5925] <- 'nsp13'
  protein[x < 5324] <- 'nsp12'
  protein[x < 4405] <- 'nsp11'
  protein[x < 4392] <- 'nsp10'
  protein[x < 4253] <- 'nsp9'
  protein[x < 4140] <- 'nsp8'
  protein[x < 3942] <- 'nsp7'
  protein[x < 3859] <- 'nsp6'
  protein[x < 3569] <- 'nsp5'
  protein[x < 3263] <- 'nsp4'
  protein[x < 2763] <- 'nsp3'
  protein[x < 818] <- 'nsp2'
  protein[x < 180] <- 'nsp1'
  
  return(protein)
}

convert_orf1a_position <- function(x, protein) {
  x[protein == 'nsp16'] <- x[protein == 'nsp16'] - 6798
  x[protein == 'nsp15'] <- x[protein == 'nsp15'] - 6452
  x[protein == 'nsp14'] <- x[protein == 'nsp14'] - 5925
  x[protein == 'nsp13'] <- x[protein == 'nsp13'] - 5324
  x[protein == 'nsp12'] <- x[protein == 'nsp12'] - 4405
  x[protein == 'nsp11'] <- x[protein == 'nsp11'] - 4392
  x[protein == 'nsp10'] <- x[protein == 'nsp10'] - 4253
  x[protein == 'nsp9'] <- x[protein == 'nsp9'] - 4140
  x[protein == 'nsp8'] <- x[protein == 'nsp8'] - 3942
  x[protein == 'nsp7'] <- x[protein == 'nsp7'] - 3859
  x[protein == 'nsp6'] <- x[protein == 'nsp6'] - 3569
  x[protein == 'nsp5'] <- x[protein == 'nsp5'] - 3263
  x[protein == 'nsp4'] <- x[protein == 'nsp4'] - 2763
  x[protein == 'nsp3'] <- x[protein == 'nsp3'] - 818
  x[protein == 'nsp2'] <- x[protein == 'nsp2'] - 180
  
  return(x)
}

get_protein_limits <- function(variants){
  group_by(variants, name) %>%
    filter(position == min(position) | position == max(position)) %>%
    ungroup() %>%
    select(name, position, wt) %>%
    distinct()
}

classify_freq <- function(x){
  out <- rep('> 10', length(x))
  out[x < 0.1] <- '1-10'
  out[x < 0.01] <- '0.1-1'
  out[x < 0.001] <- '< 0.1'
  out[is.na(x)] <- 'NA'
  out <- factor(out, levels = c('NA', '< 0.1', '0.1-1', '1-10', '> 10'))
  return(out)
}

int_colour_scale <- c(None='black', ace2='#a6cee3', tom70='brown', nsp10='#1f78b4', nsp12='#b2df8a', nsp13='green', nsp14='#33a02c',
                      nsp16='#fb9a99', nsp7='#e31a1c', nsp8='#fdbf6f', nsp9='#ff7f00', `40S ribosomal protein S3`='#cab2d6',
                      `40S ribosomal protein S30`='#cab2d6', `18S ribosomal RNA`='#cab2d6', `40S ribosomal protein S2`='#cab2d6',
                      `40S ribosomal protein S9`='#cab2d6', s='#6a3d9a', orf3a='#ffff99', nc='#b15928', orf9b='#ffff33',
                      `REGN10987 antibody Fab fragment heavy chain`='#b15928', `REGN10933 antibody Fab fragment heavy chain`='#b15928',
                      `REGN10987 antibody Fab fragment light chain`='#b15928', `REGN10933 antibody Fab fragment light chain`='#b15928',
                      `H014 Fab Heavy Chain`='#b15928', `H014 Fab Light Chain`='#b15928',
                      `COVA2-04 light chain`='#b15928', `COVA2-04 heavy chain`='#b15928')

display_names <- c(nsp1='nsp1', nsp2='nsp2', nsp3='nsp3', nsp4='nsp4', nsp5='3CL-PRO', nsp6='nsp6',
                   nsp7='nsp7', nsp8='nsp8', nsp9='nsp9', nsp10='nsp10', nsp11='nsp11', nsp12='RdRp',
                   nsp13='Hel', nsp14='ExoN', nsp15='nsp15', nsp16='nsp16', s='S', orf3a='orf3a', e='E', 
                   m='M', orf6='orf6', orf7a='orf7a', orf7b='orf7b', orf8='orf8', n="N", nc='N', orf10='orf10',
                   orf9b='orf9b', orf14='orf14',
                   ace2='ACE2', `40s`='40S', tom70='TOM70', `40S ribosomal protein S3`='40S',
                   `40S ribosomal protein S30`='40S', `18S ribosomal RNA`='40S',
                   `40S ribosomal protein S2`='40S', `40S ribosomal protein S9`='40S',
                   `REGN10987 Fab Heavy Chain`='REGN10987 Heavy Chain',
                   `REGN10933 Fab Heavy Chain`='REGN10933 Heavy Chain',
                   `REGN10987 Fab Light Chain`='REGN10987 Light Chain',
                   `REGN10933 Fab Light Chain`='REGN10933 Light Chain',
                   `H014 Fab Heavy Chain`='H014 Heavy Chain', `H014 Fab Light Chain`='H014 Light Chain',
                   `COVA2-04 Light Chain`='COVA2-04 Light Chain', `COVA2-04 Heavy Chain`='COVA2-04 Heavy Chain')

# Blank placeholder ggplot
blank_plot <- function(text = NULL){
  p <- ggplot(tibble(x=c(0, 1)), aes(x=x, y=x)) +
    geom_blank() +
    theme(panel.grid.major.y = element_blank(),
          axis.ticks = element_blank(),
          axis.text = element_blank(),
          axis.title = element_blank())
  
  if (!is.null(text)){
    p <- p + annotate(geom = 'text', x = 0.5, y = 0.5, label = text)
  }
}

# ROC Calculations
calc_roc <- function(tbl, true_col, var_col, greater=TRUE){
  true_col <- enquo(true_col)
  var_col <- enquo(var_col)
  
  tbl <- select(tbl, !!true_col, !!var_col) %>%
    drop_na()
  if (nrow(tbl) == 0){
    return(tibble(TP=NA, TN=NA, FP=NA, FN=NA))
  }
  
  true <- pull(tbl, !!true_col)
  var <- pull(tbl, !!var_col)
  steps <- c(-Inf, sort(unique(var)), Inf)
  
  true_mat <- matrix(true, nrow = length(true), ncol = length(steps))
  var_mat <- matrix(var, nrow = length(var), ncol = length(steps))
  thresh_mat <- matrix(steps, nrow = length(var), ncol = length(steps), byrow = TRUE)
  
  if (greater){
    preds <- var_mat >= thresh_mat
  } else {
    preds <- var_mat <= thresh_mat
  }
  
  tp <- colSums(preds & true_mat)
  tn <- colSums(!preds & !true_mat)
  fp <- colSums(preds & !true_mat)
  fn <- colSums(!preds & true_mat)
  tbl <- tibble(thresh = steps, tp = tp, tn = tn, fp = fp, fn = fn,
                tpr = tp / (tp + fn),
                tnr = tn / (tn + fp),
                fpr = fp / (tn + fp),
                precision = tp / (tp + fp))
  
  if (greater){
    tbl <- arrange(tbl, desc(thresh))
  } else {
    tbl <- arrange(tbl, thresh)
  }
  
  return(tbl)
}
