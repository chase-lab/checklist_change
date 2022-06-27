## jimenez-uzcategui_2013
dataset_id <- "jimenez-uzcategui_2013"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
ddata <- ddata[!grepl("Unknown", distribution)]

# splitting and melting island names
ddata[, paste0("tmp", 1:9) := data.table::tstrsplit(distribution, ", |,")]
ddata <- data.table::melt(ddata,
  id.vars = c("species", "status"),
  value.name = "local",
  measure.vars = paste0("tmp", 1:9)
)

# recoding, splitting and melting status into period
ddata[, status := c("historical", "historical+modern", "modern")[data.table::chmatch(status, c("NativeExtinct", "Native", "Introduced"))]]
ddata[, paste0("tmp", 1:2) := data.table::tstrsplit(status, "\\+")]
ddata <- data.table::melt(ddata,
  id.vars = c("species", "local"),
  measure.vars = paste0("tmp", 1:2),
  value.name = "period"
)

ddata <- ddata[!is.na(local) & !is.na(period)]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Galapagos",

  species = trimws(species),

  value = 1L,

  year = c(1800, 2000)[data.table::chmatch(period, c("historical", "modern"))],

  period = NULL,
  variable = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
island_names <- c("Isabela", "Española", "Darwin", "San Cristóbal", "Fernandina", "Floreana", "Genovesa", "Santa Cruz", "Pinta", "Marchena", "Santiago", "Pinzón", "Santa Fé", "Wolf")
latitudes <- parzer::parse_lat(c("00°30`S", "1.38°S", "1.678°N", "0.83°S", "0°22`S", "1°17`51``S", '0°19`00"N', "0.623017°S", "0.587252°N", "0.35°N", "0.252364°S", "0.610236°S", "0.818°S", "1.382506°N"))
longitudes <- parzer::parse_lon(c("91°04`W", "89.68°W", "92.003°W", "89.43°W", "91°33`W", "90°26`03``W", '89°57`00"W', "90.368254°W", "90.762184°W", "90.5°W", "90.717952°W", "90.666234°W", "90.062°W", "91.815056°W"))

meta[, ":="(
  taxon = "Herpetofauna",
  realm = "Terrestrial",

  latitude = latitudes[data.table::chmatch(local, island_names)],
  longitude = longitudes[data.table::chmatch(local, island_names)],

  effort = NA,

  alpha_grain = c(4640, 60, 1, 558, 642, 173, 14, 986, 60, 130, 585, 18, 24, 1.3)[data.table::chmatch(local, island_names)],
  alpha_grain_unit = "km2",
  alpha_grain_type = "island",
  alpha_grain_comment = "Wikipedia",

  gamma_bounding_box = geosphere::areaPolygon(data.frame(longitudes, latitudes)[grDevices::chull(x = longitudes, y = latitudes), ]) / 1000000,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  gamma_sum_grains = 7892.3,
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "archipelago",
  gamma_sum_grains_comment = "sum of the area of the islands",

  comment = "extracted from jimenez-uzcategui et al CDF Checklist of Galapagos Reptiles. In the Jiménez-Uzcátegui et al checklists, year is not explicit but native species extinctions and exotic species arrival are expected to be more recent than human settlement in 1832. We considered an historical checklist with all native species and a current checklist with native and non-native species but without 5 extinct reptile species.Effort is unknown and considered extensive and exhaustive.",
  comment_standardisation = "Species with an Unknown distribution were excluded."
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
