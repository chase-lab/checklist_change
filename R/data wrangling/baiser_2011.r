## baiser_2011


dataset_id <- "baiser_2011"
ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(
  ddata, c("island", "Archipelago", "presence"),
  c("local", "regional", "value")
)
## GIS data ----
gift <- base::readRDS("./data/GIS data/giftdata.rds")
env <- data.table::fread(paste0("./data/raw data/", dataset_id, "/baiser_2011_gift.csv"),
  na.strings = c("", "NA"),
  skip = 1L
)
env[, c("latitude", "longitude") := data.table::tstrsplit(coordinates, " ")][, coordinates := NULL] # cleaning will be done in 3.0_merging_long_format_tables.r with parzer package
env[is.na(latitude), ":="(
  latitude = as.character(gift$Lat[match(match_island_GIFT_ID, gift$ID)]),
  longitude = as.character(gift$Long[match(match_island_GIFT_ID, gift$ID)])
)]

data.table::setnames(env, "area_km2", "alpha_grain")

env[is.na(alpha_grain), alpha_grain := gift$Area[match(match_island_GIFT_ID, gift$ID)]][,
  gamma_sum_grains := sum(alpha_grain),
  by = Archipelago
]

## community data ----

ddata[, ":="(
  dataset_id = dataset_id,
  regional = data.table::fifelse(is.na(regional), local, regional),

  year = c(1500L, 2000L)[match(period, c("old", "current"))],
  period = NULL,
  Ocean = NULL
)]

ddata <- unique(ddata)

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta <- merge(meta, env, by.x = "local", by.y = "island")

meta[, ":="(
  realm = "Terrestrial",
  taxon = "Birds",

  effort = 1L,

  alpha_grain_unit = "km2",
  alpha_grain_type = "island",
  alpha_grain_comment = "area of the island",

  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "archipelago",
  gamma_sum_grains_comment = "sum of the area of the islands from each archipelago.",


  comment = "Extracted from baiser et al 2011 Dryad repo. The authors 'extracted presence/absence data from a database of bird species on 152 oceanic islands compiled by Blackburn et al. (2004) and Cassey et al. (2007) from species lists, field guides, and literature'. Past is considered to be pre-colonisation times and recent checklists were made after the 1990s.",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.5061/dryad.rs714',

  match_island_GIFT_ID = NULL,
  area_source = NULL,
  coordinates_source = NULL,
  Archipelago = NULL
)]

meta[local == "San.Andres", ":="(alpha_grain = 27L, gamma_sum_grains = 57L, latitude = "12°35'N", longitude = "81°42'W")] # Wikipedia
meta[local == "Providencia", ":="(alpha_grain = 17L, gamma_sum_grains = 57L, latitude = "13°20'56''N", longitude = "81°22'29''W")] # Wikipedia



dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
