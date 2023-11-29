# opedal_2020

dataset_id <- "opedal_2020"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
data.table::setnames(ddata, new = gsub("([A-Z])$", "+\\1", colnames(ddata)))
data.table::setnames(ddata, old = "local.V1", new = "local")

# melting species
ddata <- data.table::melt(
   data = ddata,
   id.vars = "local",
   variable.name = "species",
   na.rm = TRUE
)
ddata[, c("species", "status") := data.table::tstrsplit(species, "\\+")]

# recoding and melting periods
ddata[, status := c("historical", "modern")[data.table::chmatch(status, c("E", "C"))]]
ddata[is.na(status), status := "historical+modern"]
ddata[, c("period", "tmp") := data.table::tstrsplit(status, "\\+")]
ddata <- data.table::melt(
   data = ddata,
   id.vars = c("local", "species", "value"),
   measure.vars = c("period", "tmp"),
   value.name = "period",
   na.rm = TRUE
)
ddata[, variable := NULL]
ddata <- unique(ddata[value > 0])

ddata[, ":="(
   dataset_id = factor(dataset_id),
   regional = factor("Finnish Archipelago"),

   species = base::enc2utf8(species),

   year = c(1946L, 2017L)[match(period, c("historical", "modern"))],
   period = NULL

)]

env <- base::readRDS(
   file = paste("data/raw data", dataset_id, "env.rds", sep = "/"))

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[i = env,
     j = ":="(
        latitude = i.Y_manif,
        longitude = i.X_manif,
        alpha_grain = i.area
     ),
     on = c("local" = "V1")]

meta[, ":="(

   realm = "Terrestrial",
   taxon = "Plants",

   effort = 1L,

   alpha_grain_unit = "m2",
   alpha_grain_type = "island",
   alpha_grain_comment = "the authors consider effort comparable between surveys. Area is provided in the repository",

   gamma_bounding_box = geosphere::areaPolygon(x = data.frame(longitude, latitude)[grDevices::chull(x = longitude, y = latitude), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   gamma_sum_grains = sum(alpha_grain),
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "sum of the areas of the sampled islands",

   comment = "Extracted from the zenodo repository shared by the authors (Øystein Opedal. (2020). oysteiop/ArchipelagoPlants: Publication release (1.0). Zenodo. https://doi.org/10.5281/zenodo.3712825). Authors compiled historical and recent plant inventories from 471 islands. Community data was extracted from the colext_nospace/Y.csv table. Regarding 'year' values, the authors state: 'The historical inventories were conducted between 1925 and 1946 (mainly in the 1930s) by Eklund (1958), and in the 1940s by Skult (1960), and the recent inventories were conducted between 1996 and 2017 by M. von Numers'
Regional is the Finnish Archipelago and local are islands",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.1002/ecy.3067 | https://doi.org/10.5281/zenodo.3712825"
)]

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
