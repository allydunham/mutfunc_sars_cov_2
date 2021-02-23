#!/usr/bin/env Rscript
# Convert country table to Python object
# Based on https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv
source('src/config.R')

get_region <- function(region, sub, intermediate){
  x <- region
  
  subind <- sub %in% c("Southern Asia", "Northern Africa", "Sub-Saharan Africa", "Western Asia",
                       "Northern America", "South-eastern Asia", "Eastern Asia",  "Central Asia")
  x[subind] <- sub[subind]
  
  intind <- intermediate %in% c("Caribbean", "Central America", "South America")
  x[intind] <- intermediate[intind]
  str_remove_all(x, "ern") %>% 
    str_remove_all("[- ]") %>% 
    str_replace('Southeast', "SouthEast") %>%
    return()
}

countries <- read_csv('docs/countries.csv') %>% 
  mutate(out_region = get_region(region, `sub-region`, `intermediate-region`),
         name = str_remove_all(name, ' ')) %>%
  drop_na(out_region) %>%
  add_row(name=c('England', 'Wales', 'Scotland', 'NorthernIreland', 'UnitedKingdom'), out_region='UnitedKingdom') %>%
  arrange(out_region)

regions <- group_by(countries, out_region) %>%
  summarise(name_str = str_c('"', name, '"') %>% str_c(collapse = ', '),
            alpha_str = str_c('"', `alpha-3`, '"') %>% str_c(collapse = ', '),
            .groups = 'drop')

name_dict <- str_c('"', regions$out_region, '": [', regions$name_str, ']') %>% str_c(collapse = ',\n')
alpha_dict <- str_c('"', regions$out_region, '": [', regions$alpha_str, ']') %>% replace_na('') %>% str_c(collapse = ',\n')
