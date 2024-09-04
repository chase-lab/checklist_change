
[![DOI](https://zenodo.org/badge/454080930.svg)](https://zenodo.org/badge/latestdoi/454080930)

## Checklist change

### Description
This research compendium regroups scripts used to download, re-structure and aggregate data sets to constitute a large meta-analysis of communities sampled at least twice, 10 years apart or more.
The specificity of this data set is that it aggregates data from studies varying greatly in their focus and methods but all sampled an area in the most exhaustive way allowing us to consider it a checklist. In some studies, only past or only present communities were provided and the other species community was built by adding invading species or excluding extinct species.

### Data
Raw and aggregated data tables are provided.
Raw data are stored for each data set individually in the data/raw data/ folder in compressed .rds files
Aggregated data are in `data/communities.csv` and `data/metadata.csv` and column definitions are given in `data/definitions_communities.txt` and `data/definitions_metadata.txt`, and reproduced at the bottom of this readme.

Here are commands exploring the data set:
``` r
dt <- data.table::fread(file = "data/communities.csv",
                        select = c("dataset_id","regional","local","year","species"),
                        stringsAsFactors = TRUE) |> 
   unique()

meta <- data.table::fread(file = "data/metadata.csv",
                          select = c("dataset_id","regional","local","taxon","realm",
                                     "year", "latitude","longitude",
                                     "gamma_bounding_box_km2", "gamma_sum_grains_km2"),
                          stringsAsFactors = TRUE,
                          colClasses = c(latitude = "numeric",
                                         longitude = "numeric")) [
                             j = year := as.integer(as.character(year))
                          ] |> 
   unique()

dt[i = meta,
   j = ":="(
      taxon = i.taxon,
      realm = i.realm
   ),
   on = .(dataset_id, regional, local)
][
   j = data.table::uniqueN(species),
   by = taxon
][
   order(-V1)
]

# How many dataset_ids
base::nlevels(meta$dataset_id)

# How many dataset_ids/regions
data.table::uniqueN(meta[, .(dataset_id, regional)])

# How many dataset_ids/regions/sites?
data.table::uniqueN(meta[, .(dataset_id, regional, local)])

# How many sites per regions on average?
meta[j = data.table::uniqueN(local), keyby = .(dataset_id, regional) ][
   j = mean(V1)]

# How many dataset_ids/regions/sites with unique coordinates?
data.table::uniqueN(meta[i = meta[j = data.table::uniqueN(.SD),
                                  .SDcols = c("latitude", "longitude"),
                                  keyby = .(dataset_id, regional, local)][V1 == 1L],
                         on = .(dataset_id, regional, local)])

# How many samples?
data.table::uniqueN(meta[, .(dataset_id, regional, local, year)])

# What is the mean year range?
unique(meta[, .(dataset_id, regional, local, year)])[j = mean(diff(range(year)))]

# How many localities with 2 samples?
# How many localities with at least 4, 5, 10 samples?
meta[j = data.table::uniqueN(year),
     by = .(dataset_id, regional, local)][j = .(y2 = sum(V1 == 2L),
                                                y4 = sum(V1 >= 4L),
                                                y5 = sum(V1 >= 5L),
                                                y10 = sum(V1 >= 10L))]
# How many regions with 2 samples?
# How many regions with at least 4, 5, 10 samples?
meta[j = data.table::uniqueN(year),
     by = .(dataset_id, regional)][j = .(y2 = sum(V1 == 2L),
                                         y4 = sum(V1 >= 4L),
                                         y5 = sum(V1 >= 5L),
                                         y10 = sum(V1 >= 10L))]
# Beginning year range
meta[j = min(year), by = .(dataset_id, regional)][j = range(V1)]

# End year range
meta[j = max(year), by = .(dataset_id, regional)][j = range(V1)]

# How many regions were first sampled before 1800?
meta[j = min(year) <= 1800L, by = .(dataset_id, regional)][j = sum(V1)]

# What is the maximum number of samples in a site?
meta[j = data.table::uniqueN(year), by = .(dataset_id, regional, local) ][
   j = max(V1)]

# How many samples per taxon groups?
meta[j = data.table::uniqueN(.SD),
     .SDcols = c("dataset_id", "regional", "local", "year"),
     by = "taxon"][order(-V1)]

# How many regions per realm groups?
meta[j = data.table::uniqueN(.SD),
     .SDcols = c("dataset_id", "regional"),
     by = "realm"][order(-V1)]

# How many samples per realm groups?
meta[j = data.table::uniqueN(.SD),
     .SDcols = c("dataset_id", "regional", "local", "year"),
     by = "realm"][order(-V1)]

# Mean richness per sample?
dt[j = data.table::uniqueN(species), 
   by = .(dataset_id, regional, local, year)][j = mean(V1)]

# gamma_extent range
meta[j = .(sum = range(gamma_sum_grains_km2, na.rm = TRUE),
           box = range(gamma_bounding_box_km2, na.rm = TRUE))]

```

### Workflow and reproducibility
#### Environment
To ensure reproducibility, the working environment (R version and package version) was documented and isolated using the package [`renv`](https://rstudio.github.io/renv/index.html). By running [`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html), [`renv`](https://rstudio.github.io/renv/index.html) will install all missing packages at once. This function will use the renv.lock file to download the same versions of packages that we used and install them on your system.

#### Relative paths
Included in the repository is a Rstudio project file: `checklist_change.Rproj` that should always be used to open the project to ensure that the working directory is set correctly. All paths in the project have the same relative root which is the `checklist_change` folder where the `.Rproj` file is located. Using `setwd()` is discouraged ([read more](https://www.r-bloggers.com/2020/01/rstudio-projects-and-working-directories-a-beginners-guide/)).

#### Workflow
After downloading or cloning this repository, run the following scripts in order to wrangle raw data and merge all data sets together into one long table.

```
renv::restore()
source("R/1.0_downloading_raw_data.r")
source("R/2.0_wrangling_raw_data.r")
source("R/3.0_merging_long-format_tables")
```
#### Additional installations
You might need to install the 64-bit version of Java to run Tabulizer.

### Variable definitions
#### Community data 
##### `./data/definitions_communities.txt`
| Variable name | Definition |
| :-------------|:-----------|
| dataset_id | Unique ID linked to a publication (article or data set). If the data set was split because different taxa group are provided, a letter is added at the end. No missing value. |
| year | Year of sampling. If sampling was pooled over several years, the last sampling year is used here. No missing value. |
| regional | Region name, contains at least two localities. Can be a national park, a state or a forest name for example but smaller scales are also included where the region is an experimental sites. A data set can have several regions. No missing value. UTF-8 encoding. |
| local | Name or code of the sampled locality or experimental sample. For example, it can correspond to the name of an island, a lake or forest. No missing value. UTF-8 encoding. |
| species | Species names. Whenever possible, complete (Genus + species epithet) names were included rather than codes. No missing value. UTF-8 encoding. |

#### Metadata
##### `./data/definitions_metadata.txt`
| Variable name | Definition |
| :-------------|:-----------|
| dataset_id | Unique ID linked to a publication (article or data set). If the data set was split because different taxa group are provided, a letter is added at the end. No missing value. |
| year | Year of sampling. If sampling was pooled over several years, the last sampling year is used here. Where year (i.e., date) for historical lists was not available, they were estimated based on human visitation/colonisation history. No missing value. |
| regional | Region name, contains at least two localities. Can be a national park, a state or a forest name for example but smaller scales are also included where the region is an experimental sites. A data set can have several regions. No missing value. |
| local | Name or code of the sampled locality or experimental sample as given by the original data provider. For example, it can correspond to the name of an island, a lake or forest. No missing value. |
| latitude | Latitude North in decimal degree, WGS84. NA values indicate that information could not be collected. |
| longitude | Longitude East in decimal degree, WGS84. NA values indicate that information could not be collected. |
| effort | Sampling effort expressed for example as the number of visits to a plot or the total area sampled in a given year. See Comment column for a description. NA value means that exact effort is unknown but considered extensive and exhaustive. |
| data_pooled_by_authors | TRUE if the data provided by the authors was already pooled covering several years: several samples made over several years pooled together. No missing value. |
| data_pooled_by_authors_comment | If there was pooling by the original authors, countains free text describing how the authors pooled their data. NA values when no pooling was done. |
| sampling_years | If there was pooling by the original authors, contains the years sampled for each period. "1997, 1999" means 1997 and 1999, "1997-1999" means 1997, 1998 and 1999. NA values indicate that information could not be collected. |
| alpha_grain_m2 | Area of the local unit or area of the sampling gear (in which case, alpha_grain_type = sample). NA values indicate that information could not be collected. |
| alpha_grain_type | Category of alpha_grain specifying what does the alpha_grain measure relate to. Allowed values are: "island", "plot", "administrative" (eg the area of a park or state), "watershed", "sample", "lake_pond", "archipelago", "trap", "transect", "ecosystem" (eg the area of the whole wetland or generally the area of adjacent comparable habitat), "box" (a box covering the sites) or "quadrat"". No missing value. |
| alpha_grain_comment | Description of how the alpha_grain was measured. NA values indicate that information could not be collected. |
| gamma_bounding_box_km2 | Measure of the extent/regional scale area as the area covering all sites, computed as a convex-hull or a rectangle box or as the area of the administrative unit in which sites are found. NA values indicate that information could not be collected. |
| gamma_bounding_box_type | Category of gamma_bounding_box specifying what does the gamma_bounding_box relate to. Generally the bounding box is computed based on coordinates of the sites of by using a coarse area such as the area of the park, the state or the whole island. Allowed values are: "administrative" (eg the area of a park or state), "island", "convex-hull", "watershed", "box" (a box covering the sites), "buffer", "functional" (eg the area of the whole wetland or generally the area of adjacent comparable habitat), "shore" or "lake_pond"". NA values indicate that information could not be collected. |
gamma_bounding_box_comment | Description or source (eg the paper, Wikipedia or measured on Google Earth) of the gamma_bounding_box value. NA values indicate that information could not be collected. |
gamma_sum_grains_km2 | Measure of the extent/regional scale area as the sum of the grains sampled each year. NA values indicate that information could not be collected. |
| gamma_sum_grains_type | Category of gamma_sum_grains specifying what does the gamma_sum_grains relate to. Generally the type is related to the type of the alpha_grain since it is a sum of all alpha_grains in a region in a given year. Allowed values are: "archipelago", "administrative" (eg the area of a park or state), "watershed", "sample", "lake_pond", "plot", "quadrat", "transect", "functional" (eg the area of the whole wetland or generally the area of adjacent comparable habitat) or "box" (a box covering the sites). NA values indicate that information could not be collected. |
| gamma_sum_grains_comment | Description or source (eg the paper, Wikipedia or measured on Google Earth) of the gamma_sum_grains value. NA values indicate that information could not be collected. |
| realm | Realm in which the sampling was done, one of: Freshwater or Terrestrial. No missing value. |
| taxon | Taxon group of the data set, one of: "Plants", "Invertebrates" or "Fish"". No missing value. |
| comment | A description of the data set origin, goal and sampling method. No missing value. |
| comment_standardisation | A short description of the modifications we made to the data set to ensure standard effort: excluded sites or years, excluded taxa, etc. No missing value. |
| doi | One or several DOIs separated by  |"  that have to be cited for each data set. |
| is_coordinate_local_scale | Logical. TRUE if coordinates re given at the scale of the site/locality. FALSE if the coordinates are at the regional scale or missing. No missing value. |
