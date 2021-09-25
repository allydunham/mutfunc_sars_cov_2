#!/usr/bin/env Rscript
# Analyse results of variant protein pull down
library(biomaRt)
source("src/config.R")
source("src/analysis.R")

variants <- load_variants()

col_names <- c("bait_prey", "bait_saint_spc", "prey_saint_spc", "preygene_saint_spc", 
               "spec", "specsum", "avgspec", "numreplicates_saint_spc", "ctrlcounts", 
               "avgp_saint_spc", "maxp_saint_spc", "topoavgp_saint_spc", "topomaxp_saint_spc", 
               "saintscore_saint_spc", "logoddsscore", "foldchange_saint_spc", 
               "bfdr_saint_spc", "boosted_by_saint_spc", "bait_saint_int", "prey_saint_int", 
               "preygene_saint_int", "intensity", "intensitysum", "avgintensity", 
               "numreplicates_saint_int", "ctrlintensity", "avgp_saint_int", 
               "maxp_saint_int", "topoavgp_saint_int", "topomaxp_saint_int", 
               "saintscore_saint_int", "oddsscore", "foldchange_saint_int", 
               "bfdr_saint_int", "boosted_by_saint_int", "experiment_id", "bait_compass", 
               "prey_compass", "avepsm", "z", "wd", "entropy", "wd_percentile", 
               "z_percentile", "wd_percentile_perbait", "z_percentile_perbait", 
               "bait_mist", "prey_mist", "abundance", "reproducibility", "specificity", 
               "mist", "ip", "protein", "groupneg", "grouppos", "label", "log2fc", 
               "se", "tvalue", "df", "pvalue", "adj_pvalue", "issue", "missingpercentage", 
               "imputationpercentage", "bioreppos", "totalreppos", "biorepneg", "totalrepneg")

col_types <- c("text", "text", "text", "text", "text", "numeric", "numeric", "numeric", "text", "numeric", "numeric",
               "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "text", "text", "text",
               "text", "numeric", "numeric", "numeric", "text", "numeric", "numeric", "numeric", "numeric", 
               "numeric", "numeric", "numeric", "numeric", "numeric", "text", "text", "text", "numeric", "numeric",
               "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "text", "text", "numeric", "numeric",
               "numeric", "numeric", "text", "text", "text", "text", "text", "numeric", "numeric", "numeric", "numeric",
               "numeric", "numeric", "text", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric")

results <- readxl::read_xlsx("data/result_CoV23_Pedro.xlsx", skip = 2, col_names = col_names, col_types = col_types, na = "NA") %>%
  drop_na(bait_saint_spc) %>%
  select(bait = bait_saint_spc, prey = prey_saint_spc, avgspec, avgp_saint_spc, bfdr_saint_spc,  avgintensity,
         avgp_saint_int, bfdr_saint_int, compass_z = z, mist, log2fc, adj_pvalue) %>%
  separate(bait, c("name", "variant"), sep = "_") %>%
  filter(mist >= 0.7, avgspec >= 2, bfdr_saint_spc < 0.05)

wt_prots <- filter(results, variant == "WT") %>% pull(prey)

results_summary <- filter(results, !variant %in% c("WT", "nature")) %>%
  extract(variant, c("wt", "position", "mut"), regex = "([A-Z])([0-9]*)([A-Z])", convert = TRUE) %>%
  group_by(name, position, wt, mut) %>%
  summarise(interactions = list(prey),
            gained = list(prey[!prey %in% wt_prots]),
            lost  = list(wt_prots[!wt_prots %in% prey]),
            .groups = "drop") %>%
  mutate(name = "nc",
         n_gained = map_int(gained, length),
         n_lost = map_int(lost, length),
         n_change = n_gained + n_lost) %>%
  left_join(variants, by = c("name", "position", "wt", "mut"))

ensembl <- useEnsembl(biomart="ensembl", dataset = "hsapiens_gene_ensembl")

counts <- select(results_summary, name, position, wt, mut, gained, lost) %>%
  pivot_longer(c(gained, lost), names_to = "type", values_to = "gene") %>%
  unnest(gene) %>%
  group_by(gene) %>%
  summarise(n_gained = sum(type == "gained"),
            n_lost = sum(type == "lost"),
            n_tot = n_gained + n_lost) %>%
  arrange(desc(n_tot)) %>%
  {
    uniprot <- unique(.$gene)
    bm <- as_tibble(getBM(c("uniprotswissprot", "external_gene_name", "description"), filters = "uniprotswissprot", values = uniprot, mart = ensembl))
    left_join(., bm, by = c(gene = "uniprotswissprot"))
  }
  
