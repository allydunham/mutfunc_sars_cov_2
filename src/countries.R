#!/usr/bin/env Rscript
# Convert country table to Python object
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
  mutate(out_region = get_region(region, `sub-region`, `intermediate-region`)) %>%
  drop_na(out_region)

name_to_region <- str_c('"', countries$name, '": "', countries$`sub-region`, '"') %>% str_c(collapse = ',') %>% str_c('{', ., '}')
