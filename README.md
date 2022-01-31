# Checklist change

## Description

This research compendium regroups scripts used to download, re-structure and aggregate data sets to constitute a large meta-analysis of communities sampled at least twice, 10 years apart or more. It is a child project from chase-lab/homogenisation and a broher project to chase-lab/metacommunity-surveys.

## Reproducibility and R environment
### Installation
After downloading or cloning this repository, run these scripts in order to download raw data, wrangle raw data and merge all data sets into one long table.
```
source('./R/1.0_downloading_raw_data.r')
source('./R/2.0_wrangling_raw_data.r')
source('./R/3.0_merging_long-format_tables')
```
And finally, as described below: `renv::restore()`

### Containerisation
To ensure that the working environment (R version and package version) are documented and isolated, the package renv (https://rstudio.github.io/renv/index.html) was used. By running `renv::restore()`, renv will install all missing packages at once. This function will use the renv.lock file to download the same versions of packages that we used.

### Additional installations
You might need to install the 64-bit version of Java to run Tabulizer.
