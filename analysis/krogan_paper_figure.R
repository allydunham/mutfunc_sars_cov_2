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
  left_join(select(variants, name, position, wt, mut, sift_score, relative_surface_accessibility, total_energy, 
                   int_template, int_name, diff_interaction_energy),
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

human_complexes <- c('7kdt', '6m0j')
antibody_complexes <- c('6xdg', '7cai', '7cak', '7jmo')

interface_probability <- bind_rows(
  filter(strains, type == "substitution") %>%
    select(strain, name, position, wt, mut, int_template, int_name, diff_interaction_energy),
  select(variants, name, position, wt, mut, int_template, int_name, diff_interaction_energy) %>%
    mutate(strain = "background")
) %>%
  filter(name == "s") %>%
  mutate(int_template = str_split(int_template, "\\.", simplify = TRUE)[,1],
         int_type = case_when(int_template %in% human_complexes ~ "Human",
                              int_template %in% antibody_complexes ~ "Antibody",
                              is.na(int_template) ~ "None",
                              TRUE ~ "Virus"),
         destab = diff_interaction_energy > 1 | diff_interaction_energy < -1) %>%
  group_by(strain, position, mut) %>%
  summarise(int = !all(is.na(int_template)),
            int_de = !all(is.na(int_template)) & any(destab),
            antibody = any(int_template %in% antibody_complexes),
            antibody_de = any(int_template %in% antibody_complexes & destab),
            human = any(int_template %in% human_complexes),
            human_de = any(int_template %in% human_complexes & destab),
            virus = any(int_template %in% "6x29"),
            virus_de = any(int_template %in% "6x29" & destab),
            .groups = "drop") %>%
  group_by(strain) %>%
  summarise(n = n(),
            n_int_all = sum(int, na.rm = TRUE),
            n_int_de = sum(int_de, na.rm = TRUE),
            n_antibody_all = sum(antibody, na.rm = TRUE),
            n_antibody_de = sum(antibody_de, na.rm = TRUE),
            n_human_all = sum(human, na.rm = TRUE),
            n_human_de = sum(human_de, na.rm = TRUE), 
            n_virus_all = sum(virus, na.rm = TRUE),
            n_virus_de = sum(virus_de, na.rm = TRUE),
            .groups = "drop") %>%
  pivot_longer(starts_with("n_"), names_to = "type", values_to = "count", names_prefix = "n_") %>%
  mutate(p = count / n,
         strain = factor(strain, levels = names(strain_names)),
         type = factor(type, levels = c("human_all", "human_de", "antibody_all", "antibody_de",
                                        "virus_all", "virus_de", "int_all", "int_de")))

interface_probability_text <- separate(interface_probability, type, c("type", "cat"), sep = "_") %>%
  group_by(strain, type) %>%
  mutate(p = max(p)) %>%
  ungroup() %>%
  select(strain, type, cat, count, p) %>%
  pivot_wider(names_from = "cat", values_from = "count") %>%
  mutate(text = str_c(de, "/", all),
         type =  factor(type, levels = c("human", "antibody", "virus", "int")))

plots$interface_prob <- ggplot(interface_probability, mapping = aes(x = strain, y = p, fill = type)) +
  geom_col(data = filter(interface_probability, str_ends(type, "_all")), width = 0.6, position = position_dodge()) +
  geom_col(data = filter(interface_probability, str_ends(type, "_de")), width = 0.6, position = position_dodge()) +
  geom_text(data = interface_probability_text, mapping = aes(label = text), hjust = -0.1, vjust = 0.5, size = 2.6, position = position_dodge(width = 0.6)) +
  geom_text(data = filter(interface_probability, type == "int_all"),
            mapping = aes(label = n), y = 1, hjust = -0.1, vjust = 0.5) +
  coord_flip() +
  scale_x_discrete(labels = strain_names) + 
  scale_y_continuous(expand = expansion(c(0, 0.2)), limits = c(0, 1)) +
  scale_fill_manual(name = "",
                    values = c("int_all"="#a6cee3", "antibody_all"="#b2df8a", "human_all"="#fb9a99", "virus_all"="#fdbf6f",
                               "int_de"="#1f78b4", "antibody_de"="#33a02c", "human_de"="#e31a1c", "virus_de"="#ff7f00"),
                    labels = c("int_all"="Any Interface", "antibody_all"="Antibody", "human_all"="ACE2", "virus_all"="S Trimer",
                               "int_de"="Destabilising", "antibody_de"="Destabilising", "human_de"="Destabilising", "virus_de"="Destabilising")) +
  labs(x = "", y = "Proportion at an interface") +
  guides(fill = guide_legend(reverse = FALSE, byrow = TRUE)) +
  theme(axis.ticks.y = element_blank(),
        panel.grid.major.x = element_line(colour = "grey", linetype = "dotted"),
        panel.grid.major.y = element_blank(),
        legend.position = "bottom")

save_plotlist(plots, "figures/krogan", overwrite = "all")
