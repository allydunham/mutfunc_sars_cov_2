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
  read_tsv('data/output/summary.tsv', col_types = columns) %>%
    mutate(log10_sift = log10(sift_score + 1e-5),
           log10_freq = log10(freq + 1e-5))
}

# Select a list of variants (x) from the dataset, written as e.g. s A22V
view_variants <- function(df, x){
  keys <- str_c(df$name, ' ', df$wt, df$position, df$mut)
  df[keys %in% x,]
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
  out[x < 0.001] <- '0.01-0.1'
  out[x < 0.0001] <- '< 0.01'
  out[is.na(x)] <- 'NA'
  out <- factor(out, levels = c('NA', '< 0.01', '0.01-0.1', '0.1-1', '1-10', '> 10'))
  return(out)
}

int_colour_scale <- c(None='black', ace2='#a6cee3', nsp10='#1f78b4', nsp12='#b2df8a', nsp14='#33a02c',
                      nsp16='#fb9a99', nsp7='#e31a1c', nsp8='#fdbf6f', nsp9='#ff7f00', `40S ribosomal protein S3`='#cab2d6',
                      `40S ribosomal protein S30`='#cab2d6', `18S ribosomal RNA`='#cab2d6', `40S ribosomal protein S2`='#cab2d6',
                      `40S ribosomal protein S9`='#cab2d6', s='#6a3d9a', orf3a='#ffff99', nc='#b15928', orf9b='#ffff33')

display_names <- c(nsp1='nsp1', nsp2='nsp2', nsp3='nsp3', nsp4='nsp4', nsp5='3CL-PRO', nsp6='nsp6',
                   nsp7='nsp7', nsp8='nsp8', nsp9='nsp9', nsp10='nsp10', nsp11='nsp11', nsp12='RdRp',
                   nsp13='Hel', nsp14='ExoN', nsp15='nsp15', nsp16='nsp16', s='S', orf3a='orf3a', e='E', 
                   m='M', orf6='orf6', orf7a='orf7a', orf7b='orf7b', orf8='orf8', nc='N', orf10='orf10',
                   orf9b='orf9b', orf14='orf14',
                   ace2='ACE2', `40s`='40S', tom70='TOM70', `40S ribosomal protein S3`='40S',
                   `40S ribosomal protein S30`='40S', `18S ribosomal RNA`='40S',
                   `40S ribosomal protein S2`='40S', `40S ribosomal protein S9`='40S')

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
  steps <- sort(unique(var))
  
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
  return(
    tibble(thresh = steps, tp = tp, tn = tn, fp = fp, fn = fn,
           tpr = tp / (tp + fn),
           tnr = tn / (tn + fp),
           fpr = 1 - tnr,
           precision = tp / (tp + fp))
    )
}