# opedal_2020

dataset_id <- "opedal_2020"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
data.table::setnames(ddata, gsub("([A-Z])$", "+\\1", colnames(ddata)))
data.table::setnames(ddata, "local.V1", "local")

# melting species
ddata <- data.table::melt(ddata,
  id.vars = "local",
  variable.name = "species",
  na.rm = TRUE
)
ddata[, c("species", "status") := data.table::tstrsplit(species, "\\+")]

# recoding and melting periods
ddata[, status := c("historical", "modern")[match(status, c("E", "C"))]]
ddata[is.na(status), status := "historical+modern"]
ddata[, c("period", "tmp") := data.table::tstrsplit(status, "\\+")]
ddata <- data.table::melt(ddata,
  id.vars = c("local", "species", "value"),
  measure.vars = c("period", "tmp"),
  value.name = "period",
  na.rm = TRUE
)
ddata[, variable := NULL]
ddata <- unique(ddata[value > 0])

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Finnish Archipelago",

  species = base::enc2utf8(species),

  year = c(1946L, 2017L)[match(period, c("historical", "modern"))],
  period = NULL

)]

env <- base::readRDS(file = paste("data/raw data", dataset_id, "env.rds", sep = "/"))

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(

  realm = "Terrestrial",
  taxon = "Plants",

  latitude = env$Y_manif[match(local, env$V1)],
  longitude = env$X_manif[match(local, env$V1)],

  effort = 1L,

  alpha_grain = env$area[match(local, env$V1)],
  alpha_grain_unit = "m2",
  alpha_grain_type = "island",
  alpha_grain_comment = "the authors consider effort comparable between surveys. Area is provided in the repository",

  gamma_bounding_box = geosphere::areaPolygon(env[grDevices::chull(env$X_manif, env$Y_manif), c("X_manif", "Y_manif")]) / 1000000,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  gamma_sum_grains = sum(env$area),
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "archipelago",
  gamma_sum_grains_comment = "sum of the areas of the sampled islands",

  comment = "Extracted from the zenodo repository shared by the authors (https://doi.org/10.5281/zenodo.3712825). Authors compiled historical and recent plant inventories from 471 islands. Community data was extracted from the colext_nospace/Y.csv table. Regarding 'year' values, the authors state: 'The historical inventories were conducted between 1925 and 1946 (mainly in the 1930s) by Eklund (1958), and in the 1940s by Skult (1960), and the recent inventories were conducted between 1996 and 2017 by M. von Numers'",
  comment_standardisation = "none needed"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
