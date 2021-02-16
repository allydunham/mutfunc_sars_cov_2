#!/usr/bin/env Rscript
# Generate Supplementary Tables
source('src/config.R')
source('src/analysis.R')

variants <- load_variants()

### Table S1 - High Frequency Variants
s1 <- filter(variants, freq > 0.001, sift_score < 0.05 | abs(total_energy) > 1 | !is.na(int_name) | !is.na(ptm)) %>%
  arrange(desc(freq))

distinct(s1, name, position, wt, mut)
write_tsv(s1, 'docs/s1.tsv')

### Table S2 - Antibody Escape Variants
s2 <- filter(variants, int_name == 'ace2' | is.na(int_name)) %>% # Not interest in antibody binding or S trimer binding here
  filter(mut_escape_mean > 0.05 | mut_escape_max > 0.1, sift_score > 0.05, abs(total_energy) < 1, is.na(ptm),
         abs(diff_interaction_energy) < 1 | is.na(int_name)) %>%
  arrange(desc(mut_escape_mean))
write_tsv(s2, 'docs/s2.tsv')
