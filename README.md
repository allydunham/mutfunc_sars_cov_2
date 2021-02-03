# SARS-CoV-2 Mutfunc

This repository contains the code for the SARS-CoV-2 Mutfunc pipeline and website.
The project has been published in PAPER, where the methods and dataset are described.
This repo contains code for running the data pipeline and analysis scripts.
The source code for the [web interface](https://github.com/allydunham/mutfunc_sars_cov_2_frontend/) is stored separately.

## Pipeline

The pipeline manages generation of the dataset, including downloading most source data from online repositories.
It is managed by Snakemake, with a master `Snakefile` and additional rulesets for each section in the `pipeline/` directory.
Scripts for various sections of the pipeline are found in `bin/` and some modules are in `src/`.

## Analysis

The analysis scripts found in `analysis/` generate figures summarising the data.
`spike_experiment.R` requires data from Starr et al. 2020 (media-3.csv from <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7310626/>) to be downloaded to `data/starr_ace2_spike.csv`.
`evcouplings.R` requires EVCouplings predictions from <https://marks.hms.harvard.edu/sars-cov-2/> to be downloaded to `data/evcouplings`.

## Dependancies

### Tools

* SIFT4G (I used a slightly modified version that outputs scores to 4 decimal places instead of 2)
* FoldX 5
* Naccess
* Singularity (to run the VEP container)
* Ensembl VEP
* MMseqs2

### Python

Python 3.8.2 was used for all scripts.

* Numpy
* Pandas
* Biopython
* ruamel.yaml

### R

R version 3.6.3 was used for these analyses.

* tidyverse
* broom
* ggpubr
* ggtext
* ggrepel
* [plotlistr](github.com/allydunham/plotlistr)
