#!/usr/bin/env Rscript
# Generate figure panels for Krogan paper
source('src/config.R')
source('src/analysis.R')
plots <- list()

feature_names <- c(sift_score = '"SIFT4G Score"',
                   relative_surface_accessibility = '"Relative Surface Acc."',
                   total_energy = '"FoldX"~Delta*Delta*"G"',
                   diff_interaction_energy = '"Interface"~Delta*Delta*"G"')

strain_names <- c("alpha_20I_V1" = "Alpha 20I V1", "beta_20H_V2" = "Beta 20H V2",
                  "gamma_20J_V3" = "Gamma 20J V3", "delta_21J" = "Delta 21J", 
                  "omicron_21K" = "Omicron 21K", "background" = "Background")

strain_colours <- c("alpha_20I_V1" = "#e41a1c", "beta_20H_V2" = "#377eb8",
                    "gamma_20J_V3" = "#4daf4a", "delta_21J" = "#984ea3", 
                    "omicron_21K" = "#ff7f00", "background" = "#d9d9d9")

variants <- load_variants() %>%
  mutate(total_energy = clamp(total_energy, -10, 10),
         diff_interaction_energy = clamp(diff_interaction_energy, -10, 10))

strains <- read_tsv("data/strain_variants.tsv") %>%
  extract(variant, c("wt", "position", "mut"), "([A-Z])([0-9]*)([A-Z\\-\\*]*)", convert = TRUE) %>%
  rename(name = gene) %>%
  mutate(type = case_when(mut == "-" ~ "deletion",
                          mut == "*" ~ "truncation",
                          nchar(mut) > 1 ~ "insertion",
                          TRUE ~ "substitution"),
         name = str_to_lower(name),
         name = ifelse(name == "orf1a", split_orf1a(position), name),
         position = ifelse(str_starts(name, "nsp"), convert_orf1a_position(position, name), position)) %>%
  left_join(select(variants, name, position, wt, mut, sift_score, relative_surface_accessibility, total_energy, int_name, diff_interaction_energy),
            by = c("name", "position", "wt", "mut"))

feature_distributions <- bind_rows(
  filter(strains, type == "substitution") %>%
    select(strain, name, position, wt, mut, sift_score, relative_surface_accessibility, total_energy, diff_interaction_energy),
  select(variants, name, position, wt, mut, sift_score, relative_surface_accessibility, total_energy, diff_interaction_energy) %>%
    mutate(strain = "background")
) %>%
  pivot_longer(sift_score:diff_interaction_energy, names_to = "metric", values_to = "score") %>%
  drop_na()

plots$distributions <- ggplot(mapping = aes(x = score, y = ..scaled..)) +
  facet_wrap(~metric, scales = "free", strip.position = "bottom", labeller = labeller(metric = feature_names, .default = label_parsed)) +
  stat_density(data = filter(feature_distributions, strain == "background"), geom = "area", position = position_identity(), fill = "grey") +
  stat_density(data = filter(feature_distributions, strain != "background"), geom = "line", position = position_identity(),
               mapping = aes(colour = strain)) +
  labs(x = "", y = "Density") +
  scale_colour_manual(name = "", values = strain_colours, labels = strain_names) +
  theme(axis.title.x = element_blank(),
        strip.placement = "outside")

interface_probability <- bind_rows(
  filter(strains, type == "substitution") %>%
    select(strain, name, position, wt, mut, int_name, diff_interaction_energy),
  select(variants, name, position, wt, mut, int_name, diff_interaction_energy) %>%
    mutate(strain = "background")
) %>%
  distinct(strain, name, position, wt, mut, .keep_all = TRUE) %>%
  group_by(strain, name) %>%
  summarise(n_int = sum(!is.na(int_name)),
            n = n(), 
            p = n_int / n,
            .groups = "drop")
  
plots$interface_prob <- ggplot(filter(interface_probability, name == "s") %>% mutate(strain = factor(strain, levels = names(strain_names))),
                           aes(x = strain, y = p, fill = strain, label = str_c(n_int, " / ", n))) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_text(hjust = -0.1, vjust = 0.5) +
  coord_flip() +
  scale_x_discrete(labels = strain_names) + 
  scale_y_continuous(expand = expansion(c(0, 0.1))) +
  scale_fill_manual(name = "", values = strain_colours) +
  labs(x = "", y = "Proportion at an interface") +
  theme(axis.ticks.y = element_blank(),
        panel.grid.major.x = element_line(colour = "grey", linetype = "dotted"),
        panel.grid.major.y = element_blank())

save_plotlist(plots, "figures/krogan")
