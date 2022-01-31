## scibarras_2012

dataset_id <- "scibarras_2012"

ddata <- data.table::fread(paste0("data/raw data/", dataset_id, "/rdata.csv"), skip = 2, drop = "check")

## melting local sites
ddata <- data.table::melt(ddata,
  id.vars = "species",
  variable.name = "local",
  value.name = "period_temp",
  na.rm = TRUE
)

# melting periods
ddata[, period_temp := data.table::fcase(
  period_temp == "**", "recent",
  period_temp == "*?", "historical",
  default = "historical+recent"
)]
ddata[, c("temp1", "temp2") := data.table::tstrsplit(period_temp, split = "\\+")]

ddata <- data.table::melt(ddata,
  id.vars = c("species", "local"),
  measure.vars = c("temp1", "temp2"),
  value.name = "period",
  na.rm = TRUE
)


ddata[, ":="(
  dataset_id = dataset_id,
  regional = c(rep("Malta", 9), rep("Comino", 6), rep("Gozo", 8))[match(local, c(LETTERS[1:9], LETTERS[10:15], LETTERS[16:23]))],

  value = 1L,

  year = c(1930L, 1990L)[match(period, c("historical", "recent"))],
  period = NULL,
  variable = NULL
)]



# Metadata
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
env <- data.table::fread("./data/raw data/scibarras_2012/env.txt", sep = "\t", header = TRUE, skip = 1L, encoding = "UTF-8")
env[, latitude := parzer::parse_lat(latitude)][, longitude := parzer::parse_lon(longitude)]
env[, gamma_bounding_box := geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6]
env[, gamma_sum_grains := sum(area_m2), by = regional]

meta <- merge(meta, env)
data.table::setnames(meta, "area_m2", "alpha_grain")

meta[, ":="(
  taxon = "Plants",
  realm = "Terrestrial",

  effort = 1L,

  alpha_grain_unit = "m2",
  alpha_grain_type = "island",
  alpha_grain_comment = "area of the sampled islet measured in Google Earth",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "archipelago",
  gamma_sum_grains_comment = "sum of the area of the sampled islets",

  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  comment = "Extracted from Scibarras et al 2012 table 1 (table extraction with tabula). The authors compile historical inventories of plant composition of Maltese archipelago and updated checklists with more recent surveys. Regional is the Maltese Archipelago, local are islets situated close to the shores of three main islands of the archipelago. Should regional be the whole archipelago or should the islets be grouped by island they are tied to? Effort unspecified but islets were entirely explored and vegetation thoroughly checked. Historical and recent periods cover the 1930s and, 1990s and 2000s respectively.",
  comment_standardisation = "none needed",

  source = NULL
)]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
