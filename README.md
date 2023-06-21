

[![DOI](https://zenodo.org/badge/454080930.svg)](https://zenodo.org/badge/latestdoi/454080930)


# Checklist change

## Description

This research compendium regroups scripts used to download, re-structure and aggregate data sets to constitute a large meta-analysis of communities sampled at least twice, 10 years apart or more. It is a child project from chase-lab/homogenisation and a broher project to chase-lab/metacommunity-surveys and chase-lab/homogenisation-richness.

## Data
Raw and aggregated data tables are provided. Aggregated data are in data/communities.csv and data/metadata.csv and column definitions are given in definitions_communities.txt and definitions_metadata.txt.

## Reproducibility and R environment

To ensure reproducibility, the working environment (R version and package version) was documented and isolated using the package `renv` (https://rstudio.github.io/renv/index.html). By running `renv::restore()`, `renv` will install all missing packages at once. This function will use the renv.lock file to download the same versions of packages that we used and install them on your system.

After downloading or cloning this repository, run these scripts in order to wrangle raw data and merge all data sets into one long table.
```
renv::restore()
source('./R/1.0_downloading_raw_data.r')
source('./R/2.0_wrangling_raw_data.r')
source('./R/3.0_merging_long-format_tables')
```
### Additional installations
You might need to install the 64-bit version of Java to run Tabulizer.
