## baiser_2017
dataset_id <- "baiser_2017"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(
   ddata,
   old = c("island", "Archipelago", "presence"),
   new = c("local", "regional", "value")
)

## GIS data ----
gift <- base::readRDS("data/GIS data/giftdata.rds")
env <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/baiser_2017_gift.csv"),
   na.strings = c("", "NA"),
   skip = 1L
)
env[j = c("latitude", "longitude") := data.table::tstrsplit(coordinates, " ")][
   j = coordinates := NULL]
env[is.na(latitude), ":="(
   latitude = as.character(gift$Lat[match(match_island_GIFT_ID, gift$ID)]),
   longitude = as.character(gift$Long[match(match_island_GIFT_ID, gift$ID)])
)]

data.table::setnames(env, "area_km2", "alpha_grain")

env[is.na(alpha_grain), alpha_grain := gift$Area[match(match_island_GIFT_ID, gift$ID)]][, gamma_sum_grains := sum(alpha_grain), by = Archipelago]

## community data ----

ddata[, ":="(
   dataset_id = dataset_id,
   regional = data.table::fifelse(is.na(regional), local, regional),

   year = c(1500L, 2017L)[match(period, c("old", "current"))],
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
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review",

   alpha_grain_unit = "km2",
   alpha_grain_type = "island",
   alpha_grain_comment = "area of the island",

   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "sum of the area of the islands from each archipelago.",

   comment = "Extracted from Dryad repo Baiser, Benjamin; Valle, Dennis; Zelazny, Zoe; Burleigh, J. Gordon (2017). Data from: Non-random patterns of invasion and extinction reduce phylogenetic diversity in island bird assemblages [Dataset]. Dryad. https://doi.org/10.5061/dryad.rs714. The authors 'extracted presence/absence data from a database of bird species on 152 oceanic islands compiled by Blackburn et al. (2004) and Cassey et al. (2007) from species lists, field guides, and literature'.
Where needed, coordinates were extracted from the gift database: Weigelt, P., König, C. & Kreft, H. (2020) GIFT – A Global Inventory of Floras and Traits for macroecology and biogeography. Journal of Biogeography, 47, 16-43. doi: 10.1111/jbi.13623
Past is considered to be pre-colonisation times and recent checklists were made after the 1990s.
regional is an archipelago, local is an island",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.5061/dryad.rs714 | https://doi.org/10.1111/ecog.02738",

   match_island_GIFT_ID = NULL,
   area_source = NULL,
   coordinates_source = NULL,
   Archipelago = NULL
)]

meta[local == "San.Andres", ":="(
   alpha_grain = 27L,
   gamma_sum_grains = 57L,
   latitude = "12°35'N", longitude = "81°42'W")] # Wikipedia
meta[local == "Providencia", ":="(
   alpha_grain = 17L,
   gamma_sum_grains = 57L,
   latitude = "13°20'56''N", longitude = "81°22'29''W")] # Wikipedia

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
   row.names = FALSE
)
