# Mutfunc: SARS-CoV-2 (Pipeline)

This repository contains the data generation pipeline for [Mutfunc: SARS-CoV-2](http://sars.mutfunc.com), which is a resource containing variant effect predictions and annotations for all possible SARS-CoV-2 amino acid substitutions.
The source code for the web interface is in a separate [repository](https://github.com/allydunham/mutfunc_sars_cov_2_frontend/).
The dataset and methods are described in detail in the Mutfunc: SARS-CoV-2 [preprint](https://www.biorxiv.org/content/10.1101/2021.02.24.432721v1).

## Citation

Alistair Dunham, Gwendolyn M Jang, Monita Muralidharan, Danielle Swaney & Pedro Beltrao. 2021. A missense variant effect prediction and annotation resource for SARS-CoV-2 ([bioRxiv](https://www.biorxiv.org/content/10.1101/2021.02.24.432721v1))

## Installation

1. Clone the repo
2. Install required dependancies (see below).
3. Download any required additional data
4. Run `snakemake setup_directories` to initialise any missing directories

## Dependancies

The tools and python modules are required to run the data generation pipeline and R packages are used for the data analysis scripts (`analysis/`).
Analysis can be run without running the data generation pipeline by [downloading](http://sars.mutfunc.com/download) the Mutfunc: SARS-CoV-2 dataset and several additional datasets.
I used Python 3.8.2 and R 3.6.3, but any version supporting the required packages should work.

### Tools

* SIFT4G (I used a slightly modified version that outputs scores to 5 decimal places instead of 2)
* FoldX 5
* Naccess
* Singularity (to run the VEP container)
* Ensembl VEP
* MMseqs2

### Python

* Snakemake
* Numpy
* Pandas
* Biopython
* ruamel.yaml

### R

* tidyverse
* broom
* ggpubr
* ggtext
* ggrepel
* [plotlistr](github.com/allydunham/plotlistr)

## Additional Datasets

Various additional data file are required for parts of the pipeline and analysis:

* An aligned SAR-CoV-2 variant VCF file, placed in a location defined in `snakemake.yaml`. This is used to calculate variant frequencies. I use a version of the VCF used by [sarscov2phylo](https://github.com/roblanf/sarscov2phylo) pruned to only include public sequences.
* supplementary data file S2 from [Bouhaddou et al. (2020)](https://www.cell.com/cell/fulltext/S0092-8674\(20\)30811-4), saved as `data/ptms/SuppTable_annotated_viral_phosphosites_revised.tsv`. This is used to source PTM data.
* Table S1 from [Greaney et al. (2021)](https://www.cell.com/cell-host-microbe/fulltext/S1931-3128\(20\)30624-7), saved as `data/greaney_spike_antibody.csv`. This is used for antibody escape data.
* `media-3.csv` from [Starr et al. (2020)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7310626/), saved as `data/starr_ace2_spike.csv`. This is used to compare predictions to the Spike DMS study in the analysis and is not used in the pipeline.
* [EVCouplings predictions](https://marks.hms.harvard.edu/sars-cov-2/), saved in `data/evcouplings`. This is only used for `analysis/evcouplings.R`

## Running the Pipeline

The pipeline manages generation of the dataset, including downloading most source data from online repositories.
It is managed by Snakemake, with a master `Snakefile` and additional rulesets for each section in the `pipeline/` directory.
Scripts for various sections of the pipeline are found in `bin/` and modules in `src/`.
The configuration file (`snakemake.yaml`) specifies various parameters to run the pipeline, including paths to various local files and a flag telling the pipeline whether to look for online updates for data files.
The pipeline can be run using the `snakemake` command, but running the complete pipeline really requires access to a computer cluster and using the required snakemake cluster configuration for you environment.
Running on a single machine, even a very powerful one, would take a restrictive amount of time (e.g. multiple days).

## Running Analysis

The analysis R scripts found in `analysis/` generate figures summarising the data.
They are not automatically run by the data generation pipeline and must be manually executed to generate figures.
Most of them can be run without running the data generation pipeline if the Mutfunc: SARS-CoV-2 dataset is downloaded and places in `data/output` and the specified additional datasets are downloaded.
