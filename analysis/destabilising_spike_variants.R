#!/usr/bin/env Rscript
# Identify variants causing Spike destabilisation
library(data.table)
source('src/config.R')
source('src/analysis.R')

# Identify variants that destabilise Spike, based on any of the three metrics
variants <- read_tsv('data/frequency/variant_annotation.tsv', comment = '##') %>%
  filter(Gene == 's', Consequence == 'missense_variant') %>%
  select(variants = `#Uploaded_variation`, allele = Allele, name=Gene, position = Protein_position, aa = Amino_acids) %>%
  mutate(chrom = 'NC_045512v2') %>%
  separate(aa, into = c('wt', 'mut'), sep = '/') %>%
  tidyr::extract(variants, c('rna_wt', 'rna_position'), "([ATCG])([0-9]*).*", convert = TRUE) %>%
  select(chrom, rna_position, rna_wt, rna_mut=allele, name, position, wt, mut) %>%
  left_join(select(load_variants(), name, position, wt, mut, sift_score, total_energy, int_name, diff_interaction_energy),
            by=c('name', 'position', 'wt', 'mut')) %>%
  filter(total_energy > 1 | diff_interaction_energy > 1 | sift_score < 0.05) %>%
  mutate(int_name = ifelse(is.na(int_name), 'tmp', str_c('int_ddg_', int_name))) %>%
  # Take most destabilising in cases where there are 2 S interfaces
  pivot_wider(names_from = int_name, values_from = diff_interaction_energy, values_fn = max) %>%
  select(-tmp)

# Make position list to pass to VCFTools for filtering (must be done before next stage of script will run)
# vcftools --vcf data/frequency/variants.filtered.vcf --positions data/spike_destabilising_positions.tsv --recode --recode-INFO-all --stdout > data/spike_destabilising_positions.vcf
select(variants, `#chrom` = chrom, rna_position) %>% distinct() %>% write_tsv('data/spike_destabilising_positions.tsv')

# Load and melt vcf (must use data.table initially to quickly handle large number of columns)
# Filter to cases where a sample has a variant in a position with at least one destabilising variant
samples <- fread(file = 'data/spike_destabilising_positions.vcf', sep = '\t', header = TRUE, skip = 1, colClasses = 'character')
sample_names <- colnames(samples)[10:ncol(samples)]
n_samples <- length(sample_names)
samples <- melt(samples, id.vars = c("#CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT"),
                variable.name = 'sample', value.name = 'allele')
samples <- samples[!allele == '0' & !allele == '.']

# Summarise each sample with the number of destabilising variants of each type they carry
sample_counts <- as_tibble(samples) %>%
  select(rna_position = POS, rna_wt = REF, rna_mut = ALT, info = INFO, sample, allele) %>%
  mutate(rna_position = as.integer(rna_position),
         allele = as.integer(allele),
         rna_mut = str_split(rna_mut, ',', simplify = TRUE)[matrix(c(1:length(allele), allele), nrow = length(allele), byrow = FALSE)]) %>%
  select(-allele, -info) %>%
  left_join(variants, ., by = c('rna_position', 'rna_wt', 'rna_mut')) %>%
  group_by(sample) %>%
  summarise(n_any = n(),
            n_struct = sum(total_energy > 1 | int_ddg_s > 1 | int_ddg_ace2 > 1, na.rm = TRUE),
            n_sift = sum(sift_score < 0.05, na.rm = TRUE),
            n_foldx = sum(total_energy > 1, na.rm = TRUE),
            n_foldx_not_sift = sum(total_energy > 1 & sift_score > 0.05, na.rm = TRUE),
            n_int_s = sum(int_ddg_s > 1, na.rm = TRUE),
            n_int_ace2 = sum(int_ddg_ace2 > 1, na.rm = TRUE),
            .groups = 'drop') %>%
  {
    unmutated_samples <- sample_names[!sample_names %in% .$sample]
    bind_rows(., tibble(sample=unmutated_samples, n_any = 0, n_struct = 0, n_sift = 0, n_foldx = 0,
                        n_foldx_not_sift = 0, n_int_s = 0, n_int_ace2 = 0))
  }

# Calculate summary proportions
sample_props <- c(overall = sum(!sample_counts$n_any == 0) / n_samples,
                  structural = sum(!sample_counts$n_struct == 0) / n_samples,
                  sift = sum(!sample_counts$n_sift == 0) / n_samples,
                  foldx = sum(!sample_counts$n_foldx == 0) / n_samples,
                  foldx_not_sift = sum(!sample_counts$n_foldx_not_sift == 0) / n_samples,
                  int_s = sum(!sample_counts$n_int_s == 0) / n_samples,
                  int_ace2 = sum(!sample_counts$n_int_ace2 == 0) / n_samples)

# Analysis
plots <- list()
metric_names = c(any="'Any Significant Prediction'", struct="'Any Structural Prediction'", sift="'SIFT4G Score < 0.05'",
                 foldx='"FoldX"~Delta*Delta*"G > 1"', foldx_not_sift='"FoldX"~Delta*Delta*"G > 1 and SIFT4G Score < 0.05"',
                 int_s="'FoldX Spike Interface'~Delta*Delta*'G > 1'", int_ace2="'FoldX Ace2 Interface'~Delta*Delta*'G > 1'")
plots$destabilising_counts <- pivot_longer(sample_counts, -sample, names_to = 'metric', values_to = 'count', names_prefix = 'n_') %>%
  count(metric, count) %>%
  mutate(metric = factor(metric_names[metric], levels = metric_names)) %>%
  ggplot(aes(x = count, y = n, fill = metric, label = n)) +
  facet_wrap(~metric, labeller = label_parsed) +
  geom_col(show.legend = FALSE, width = 0.7) +
  geom_text(hjust = 0.5, vjust = -0.5) +
  scale_fill_brewer(palette = 'Set1') +
  scale_x_continuous(breaks = 0:max(sample_counts$n_any)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.11))) +
  coord_cartesian(clip = 'off') +
  labs(x = 'Count', y = 'Number of Samples') +
  theme(axis.ticks.x = element_blank())

### Save plots ###
save_plotlist(plots, 'figures/spike_destabilisation', verbose = 2, overwrite = 'all')
