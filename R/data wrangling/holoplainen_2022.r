dataset_id <- "holoplainen_2022"
ddata <- base::readRDS(file = "data/raw data/holoplainen_2022/rdata.rds")

data.table::setnames(ddata, c('year', 'date', 'latitude', 'longitude', 'local', 'species'))

# Data selection ----
## keeping only sites sampled at least 10 years appart ----
ddata <- ddata[ddata[, diff(range(year)), by = local][V1 >= 10L][, .(local)], on = 'local']
## Pooling observations from one site from the same year ----
ddata <- unique(ddata[, date := NULL])

# Communities ----
ddata[, ':='(
   dataset_id = dataset_id,
   regional = 'Finland',

   value = 1L
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, latitude, longitude)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   effort = 1L,

   data_pooled_by_authors = FALSE,

   alpha_grain = NA,
   alpha_grain_unit = NA,
   alpha_grain_type = "sample",
   alpha_grain_comment = "each observation on the field constitutes a site, area varies and is unknown",

   gamma_sum_grains = NA,
   gamma_sum_grains_unit = NA,
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "each observation on the field constitutes a site, area varies and is unknown",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Extracted from ",
   comment_standardisation = "none needed"
)][, gamma_bounding_box := geosphere::areaPolygon(x = data.frame(longitude, latitude)[grDevices::chull(x = longitude, y = latitude), ]) / 10^6]

ddata[, c('latitude','longitude') := NULL]

# Saving ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
