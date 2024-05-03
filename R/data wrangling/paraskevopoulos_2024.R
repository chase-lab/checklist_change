dataset_id <- "paraskevopoulos_2024"

ddata <- base::readRDS(file = "data/raw data/paraskevopoulos_2024/rdata.rds")

data.table::setnames(ddata, new = tolower(colnames(ddata)))
data.table::setnames(
   x = ddata,
   old = c('sampling site','current species','lat','lon'),
   new = c('local','species','latitude','longitude'))

# Raw data ----
ddata[, ":="(latitude = mean(latitude), longitude = mean(longitude)),
      by = local]
ddata <- unique(ddata)[!is.na(species)]

## Community data ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Gregory Canyon",

   value = 1L
)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   effort = 1L,
   data_pooled_by_authors = FALSE,

   alpha_grain = NA,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "Area of the sites unknown",

   gamma_bounding_box = geosphere::areaPolygon(x = data.frame(longitude, latitude)[grDevices::chull(x = longitude, y = latitude), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the areas of the sampled sites",


   comment = "Extracted from the repository Paraskevopoulos, Anna; Sanders, Nathan; Resasco, Julian (2024). Temperature-driven homogenization of an ant community over 60 years in a montane ecosystem [Dataset]. Dryad. https://doi.org/10.5061/dryad.2fqz612x4
METHODS 'This dataset has ant collection data and microclimate information' in 1957 (26 sites), 1958 (7 sites), 2021 (33 sites) and 2022 (8 sites). Ant individuals and colonies were looked for visually in predetermined sites, baited traps were set and mouth aspirators were used to capture individuals for later identification. Authors aimed at exhaustivity and comparability through time and space.",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.5061/dryad.2fqz612x4 | https://doi.org/10.1002/ecy.4302"
)][j = gamma_sum_grains := sum(alpha_grain), keyby = year]

ddata[, c("latitude","longitude") := NULL]

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
