#!/usr/bin/env Rscript
# NC Phosphosite Cluster Co-occurance
source('src/config.R')

variants <- c('180S/I', '183S/Y', '194S/L', '197S/L', '202S/N', '205T/I', '206S/F')
sites <- read_tsv('data/frequency/variant_annotation.tsv', comment = '##') %>% 
  filter(Gene == 'ENSSASG00005000005', str_c(Protein_position, Amino_acids) %in% variants)

vcf <- read_tsv('data/frequency/nc_phos_cluster.tsv', col_types = cols(genotype=col_character()))
