#!/usr/bin/env Rscript
# Analyse difference in FoldX results for S protein in different states
source("src/config.R")

foldx <- bind_rows(open = read_tsv("data/s_foldx/open/average.fxout"),
                   closed = read_tsv("data/s_foldx/closed/average.fxout"),
                   .id = "state")

classify <- function(open, closed) {
  out <- rep(NA, length(open))
  out[abs(closed) < 1 & abs(open) < 1] <- "Both Neutral"
  out[abs(closed) >= 1 & abs(open) >= 1] <- "Both Significant"
  out[abs(closed) < 1 & abs(open) >= 1] <- "Closed Neutral & Open Significant"
  out[abs(closed) >= 1 & abs(open) < 1] <- "Closed Significant & Open Neutral"
  return(out)
}

comparison <- select(foldx, state, position, wt, mut, total_energy) %>%
  pivot_wider(names_from = state, values_from = total_energy) %>%
  mutate(diff = abs(open - closed),
         type = classify(open, closed)) %>%
  drop_na()

p <- ggplot(comparison, aes(x = open, y = closed)) +
  geom_point(aes(colour = type), shape = 20, size = 0.5) +
  geom_abline(slope = 1, intercept = 0) +
  geom_smooth(method = "lm", formula = y ~ x, size = 0.6) +
  scale_color_brewer(name = "", palette = "Dark2") +
  labs(x = "Open State", y = "Closed State")
ggsave("figures/spike_states.pdf", p, units = "cm", width = 15, height = 9)
