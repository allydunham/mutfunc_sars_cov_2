#!/usr/bin/env Rscript
# Generate figure S1 (Summary of kemp et al 2021 variants)
source('src/config.R')
source('src/analysis.R')

annotation <- read_tsv('data/frequency/variant_annotation.tsv', comment = '##') %>%
  select(variants = `#Uploaded_variation`, allele = Allele, name=Gene, position = Protein_position, aa = Amino_acids) %>%
  mutate(chrom = 'NC_045512v2') %>%
  separate(aa, into = c('wt', 'mut'), sep = '/') %>%
  tidyr::extract(variants, c('rna_wt', 'rna_position'), "([ATCG])([0-9]*).*", convert = TRUE) %>%
  select(rna_position, rna_wt, rna_mut=allele, name, position, wt, mut) %>%
  mutate(name = str_replace(name, 'nsp12_[12]', 'nsp12'))

kemp_variants <- read_tsv('data/kemp_variants.tsv') %>%
  select(rna_position = Locus, rna_wt = From, rna_mut = To, name = Protein, `1`:`101`) %>%
  left_join(annotation, by = c('name', 'rna_position', 'rna_wt', 'rna_mut')) %>%
  select(name, position, wt, mut, `1`:`101`) %>%
  drop_na()

variants <- load_variants()

kemp_summary <- pivot_longer(kemp_variants, `1`:`101`, names_to = 'day', values_to = 'freq') %>%
  group_by(name, position, wt, mut) %>%
  summarise(max_kemp_freq = max(freq), .groups = 'drop') %>%
  left_join(variants, by = c('name', 'position', 'wt', 'mut')) %>%
  mutate(int_name = replace_na(display_names[int_name], 'None'),
         ptm = str_to_title(replace_na(ptm, 'None'))) %>%
  filter(!str_detect(int_name, 'Chain'))

sig_counts <- group_by(variants, name, position, wt, mut, freq) %>% 
  summarise(sig_sift = any(sift_score < 0.05),
            fx_sig = any(abs(total_energy) > 1),
            ptm_sig = any(ptm == 'phosphosite'),
            int_sig = any(abs(diff_interaction_energy) > 1),
            .groups = 'drop') %>% 
  replace_na(list(sig_sift=FALSE, fx_sig=FALSE, ptm_sig=FALSE, int_sig=FALSE)) %>% 
  mutate(any_sig = sig_sift | fx_sig | ptm_sig | int_sig,
         any_struct = fx_sig | ptm_sig | int_sig) %>%
  left_join(select(kemp_summary, name, position, wt, mut, max_kemp_freq), by = c('name', 'position', 'wt', 'mut'))

### Binary test
# n <- filter(sig_counts, max_kemp_freq > 10) %>% nrow()
# successes <- filter(sig_counts, max_kemp_freq > 10) %>% pull(any_struct) %>% sum()
# p <- filter(sig_counts, freq > 0.01) %>% summarise(p = sum(any_struct) / n()) %>% pull(p)
# binom.test(successes, n, p, 'greater')

### Overview
p_overview <- filter(kemp_summary, max_kemp_freq > 10) %>%
  group_by(name, position, wt, mut, log10_sift, total_energy, ptm) %>%
  summarise(int_name = str_c(unique(int_name), collapse = ', '), .groups = 'drop') %>%
  ggplot(aes(x = -log10_sift, y = total_energy, shape = ptm, colour = int_name)) +
  geom_point() +
  geom_hline(yintercept = c(-1, 1), linetype = 'dotted') +
  geom_vline(xintercept = -log10(0.05), linetype = 'dotted') +
  scale_colour_manual(name = 'Interface', values = c(None='black', ACE2='#e41a1c', N='#377eb8', 'RdRp, nsp8'='#4daf4a', S='#984ea3')) +
  scale_shape_manual(name = 'PTM', values = c(None=20, Phosphosite=17)) +
  labs(x = expression(-log[10]~'SIFT4G Score'), y = expression(Delta*Delta*G~'(kJ' %.% 'mol'^-1*')'))

### Assemble figure
# size <- theme(text = element_text(size = 7))
# p1 <- p_schematic + labs(tag = 'A') + size
# p2 <- p_coverage + labs(tag = 'B') + size
# p3 <- p_complexes + labs(tag = 'C') + size
# p4 <- p_sift_freq + labs(tag = 'D') + size
# p5 <- p_sift_dms  + labs(tag = 'E') + size
# p6 <- p_foldx_freq + labs(tag = 'F') + size
# p7 <- p_foldx_dms  + labs(tag = 'G') + size
# 
# figure <- multi_panel_figure(width = c(46.5, 44, 46.5, 44), height = 183, rows = 3,
#                              panel_label_type = 'none', row_spacing = 0, column_spacing = 0) %>%
#   fill_panel(p1, row = 1, column = 1:4) %>%
#   fill_panel(p2, row = 2, column = 1) %>%
#   fill_panel(p3, row = 2, column = 2:4) %>%
#   fill_panel(p4, row = 3, column = 1) %>%
#   fill_panel(p5, row = 3, column = 2) %>%
#   fill_panel(p6, row = 3, column = 3) %>%
#   fill_panel(p7, row = 3, column = 4)
ggsave('figures/figures/figureS1.pdf', p_overview, width = 180, height = 180, units = 'mm', device = cairo_pdf)
ggsave('figures/figures/figureS1.png', p_overview, width = 180, height = 180, units = 'mm')
