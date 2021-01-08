#!/usr/bin/env Rscript
# NC Phosphosite Cluster Co-occurance
source('src/config.R')

variants <- c('180S/I', '183S/Y', '194S/L', '197S/L', '202S/N', '205T/I', '206S/F')
sites <- read_tsv('data/frequency/variant_annotation.tsv', comment = '##') %>% 
  filter(Gene == 'ENSSASG00005000005', str_c(Protein_position, Amino_acids) %in% variants) %>%
  select(variants = `#Uploaded_variation`, location = Location, allele = Allele, position = Protein_position, aa = Amino_acids) %>%
  separate(aa, into = c('wt', 'mut'), sep = '/') %>%
  mutate(location = as.integer(str_split_fixed(location, ':', 2)[,2])) %>%
  select(-variants, pos = location, alt = allele)

get_genotypes <- function(refs, alts, inds){
  alt_mat <- cbind(refs, str_split(alts, ',', simplify = TRUE), deparse.level = 0)
  ind_mat <- matrix(c(1:nrow(alt_mat), inds + 1), ncol = 2, nrow = nrow(alt_mat))
  return(alt_mat[ind_mat])
}

vcf <- read_tsv('data/frequency/nc_phos_cluster.tsv', col_types = cols(genotype=col_character())) %>%
  rename_all(str_to_lower) %>%
  filter(!genotype == '.') %>% # Don't want uncalled genotypes
  mutate(genotype = as.integer(genotype),
         alt = get_genotypes(ref, alt, genotype)) %>%
  left_join(sites, by = c("pos", "alt"))

strain_summary <- group_by(vcf, sample) %>%
  summarise(phospho_variants = sum(!is.na(position)), # Protein position listed means its one of our target phosphorylations
            .groups = 'drop')

p <- ggplot(strain_summary, aes(x = phospho_variants)) +
  geom_histogram(fill = 'cornflowerblue') +
  labs()
