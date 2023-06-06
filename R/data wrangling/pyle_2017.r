# pyle_2017

dataset_id <- "pyle_2017"

ddata <- data.table::fread(paste0("./data/raw data/", dataset_id, "/rdata.csv"), header = TRUE, skip = 1)
data.table::setnames(ddata, "COMMON NAME", "species")

# melting sites
ddata <- data.table::melt(ddata,
  id.vars = "species",
  value.name = "period",
  measure.vars = c("Kaua'i", "O'ahu", "Moloka'i", "Lana'i", "Maui", "Hawai'i"),
  variable.name = "local"
)
ddata <- ddata[period != ""]

# recoding, splitting and melting periods
ddata[, period := c("historical", "historical+present", "present")[match(period, c("Extinct", "Native", "Exotic"))]]
ddata[, paste0("tmp", 1:2) := data.table::tstrsplit(period, "\\+")]
ddata <- data.table::melt(ddata,
  id.vars = c("species", "local"),
  value.name = "period",
  measure.vars = paste0("tmp", 1:2),
  na.rm = TRUE
)

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Hawaii archipelago",
  year = c("1900", "2017")[match(period, c("historical", "present"))],

  value = 1L,

  period = NULL,
  variable = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
latitudes <- parzer::parse_lat(c("22°05`N", "21.4730°N", "21°08`N", "20°50`N", "20°48`N", "19.566667 N"))
longitudes <- parzer::parse_lon(c("159°30`W", "157.9868°W", "157°02`W", "156°56`W", "156°20`W", "-155.5 E"))

meta[, ":="(
  taxon = "Birds",
  realm = "Terrestrial",

  latitude = latitudes[match(
    local,
    c("Kaua'i", "O'ahu", "Moloka'i", "Lana'i", "Maui", "Hawai'i")
  )],
  longitude = longitudes[match(
    local,
    c("Kaua'i", "O'ahu", "Moloka'i", "Lana'i", "Maui", "Hawai'i")
  )],

  effort = 1L,

  alpha_grain = c(1456.4, 1545.4, 673.4, 364, 1883, 10430)[match(
    local,
    c("Kaua'i", "O'ahu", "Moloka'i", "Lana'i", "Maui", "Hawai'i")
  )],
  alpha_grain_unit = "km2",
  alpha_grain_type = "island",
  alpha_grain_comment = "Wikipedia",

  gamma_sum_grains = 16352L,
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "archipelago",
  gamma_sum_grains_comment = "sum of the area of sampled islands",

  gamma_bounding_box = geosphere::areaPolygon(data.frame(longitudes, latitudes)[grDevices::chull(longitudes, latitudes), ]) / 10^6,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  comment = "Checklist by RL Pyle and P Pyle, data aggregated by the authors of Chase et al 2019 (Species richness change across spatial scales). Full reference: Pyle, R.L., and P. Pyle. 2017. The Birds of the Hawaiian Islands: Occurrence, History, Distribution, and Status. B.P. Bishop Museum, Honolulu, HI, U.S.A. Version 2 (1 January 2017) http://hbs.bishopmuseum.org/birds/rlp-monograph ",
  comment_standardisation = "none needed"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
