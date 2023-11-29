dataset_id <- "holoplainen_2022"
ddata <- base::readRDS(file = "data/raw data/holoplainen_2022/rdata.rds")

data.table::setnames(ddata, c('year', 'date', 'latitude', 'longitude', 'local', 'species'))

# Data selection ----
## keeping only sites sampled at least 10 years appart ----
ddata <- ddata[
   i = !ddata[j = diff(range(year)), by = local][V1 < 9L],
   on = 'local']
## Pooling observations from one site from the same year ----
ddata <- unique(ddata[, date := NULL])

# Communities ----
ddata[, ':='(
   dataset_id = dataset_id,
   regional = 'Finland',

   value = 1L
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])
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

   comment = "Extracted from the NCEI NOAA repository related to the article Holopainen, Jari, Helama, Samuli, and Väre, Henry. 2023. Plant Phenological Dataset Collated by the Finnish Society of Sciences and Letters. Ecology 104( 2): e3962. METHODS: Here we provide a unique dataset of plant phenological observations made in boreal Europe between 1750 and 1965 from locations situated across historical and modern Finland, mostly between 70° and 60°N and 30° and 20°E. This dataset was generated initially by the efforts of several generations of volunteers representing naturalists whose field observations and notes had initially made the continuous collection of the data possible [...] Species names given originally either in Latin, Finnish, German, and/or Swedish were transformed into scientific species names. Moreover, outdated taxonomic names were updated as appropriate.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1002/ecy.3962'
)][, gamma_bounding_box := geosphere::areaPolygon(x = data.frame(longitude, latitude)[grDevices::chull(x = longitude, y = latitude), ]) / 10^6]

ddata[, c('latitude','longitude') := NULL]

# Saving ----
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
