## jones_2019

dataset_id <- "jones_2019"

ddata <- data.table::fread(paste0("data/raw data/", dataset_id, "/rdata.csv"), skip = 1)
env <- data.table::fread(file = paste0("data/raw data/", dataset_id, "/Table1-1.csv"), skip = 1, header = TRUE, sep = ",")
env[, effort := sum(length_sampled), by = local]

env <- unique(env[!grepl("T", block), .(coord = downstream[.N], effort), by = local][, ":="(latitude = base::substr(coord, 1, 8),
  longitude = base::substr(coord, 10, 20))])

## melting sites and time periods
ddata <- data.table::melt(ddata,
  id.vars = "species",
  variable.name = "temp"
)
# splitting period and local
ddata[, c("year", "local") := data.table::tstrsplit(temp, " ")][, temp := NULL]

ddata <- ddata[!is.na(value) & value != 0 & value != ""]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "South Dakota",

  value = 1L
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Fish",
  realm = "Freshwater",

  latitude = env$latitude[data.table::chmatch(local, env$local)], # coordinates of the most downstream site on the main tributary only
  longitude = env$longitude[data.table::chmatch(local, env$local)],

  effort = 1L,



  data_pooled_by_authors = FALSE,
  sampling_years = c("pre-1990", "1990-2005", "2006-2016")[data.table::chmatch(year, c("1989", "2005", "2016"))],

  alpha_grain = c(13000L, 14000L, 62800L, 7800L, 26000L)[data.table::chmatch(local, c("Grand", "Moreau", "Cheyenne", "Bad", "White"))],
  alpha_grain_unit = "km2",
  alpha_grain_type = "watershed",
  alpha_grain_comment = "entire watershed areas from Wikipedia",

  gamma_sum_grains = sum(c(13000L, 14000L, 62800L, 7800L, 26000L)),
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "watershed",
  gamma_sum_grains_comment = "'When combined, these rivers drain approximately 127,900 km2 of eastern Wyoming, northeast Montana, northwest Nebraska, and western South Dakota, approximately 72% of which is within South Dakota'. Since we had access only to the total watershed areas, not restricted to South Dakota, we consider the gamma as the sum of the watershed, not only the 72% inside South Dakota borders. All sampling points are in South Dakota, close to the mouth of the watersheds.",

  comment = "Extracted from Jones MSc 2019 table 1-15 (species name extraction with [tabulizer], presence absence entered by hand). Aggregated data. Regional is the Missouri watershed in western South Dakota, local are 5 major tributaries to the Missouri River. Sampling effort is intensive with each major tributary being sampled in 'A minimum of four mainstem and four tributary sites' using active and passive sampling gear. For the most recent campaign, Effort is provided by the authors as the length of river sampled and we multiply it by 5, considered the average width of the stretches to compute an area: 'At each site, reach length was determined as 40 times the mean stream width (Rabeni et al. 2009), with a minimum length of 100m and a maximum length of 1600m.' For older surveys, effort is unknown and partially checklist-like, cf hoagstrom_2007. Hence Jones' remark: 'It is important to note that this study was conducted under the assumption that species presence-absence data from each time period was representative of the community at the time of sampling however, sampling methods and level of sampling effort varied between time periods and investigators which may have affected our results.'. See table 2-18. Scale and time coverage differ between jones_2019 and hoagstrom_2007. Even sites and times that seem to overlap have different composition.",
  comment_standardisation = "none needed"
)]

# This section use to specify the sampled area during the 2006-2016 period but was commented out and watershed area was always used for alpha_grain for consistency
# meta[period == '2006-2016', ':='(
#    alpha_grain = env$effort[match(local, env$local)]*5,
#    alpha_grain_unit = 'm2',
#    alpha_grain_type = 'sample',
#    alpha_grain_comment = 'sum of sampled stretches times 5 which is the assumed average width of the stretches'
# )]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
