dataset_id <- 'botham_2022'

ddata <- base::readRDS(file = 'data/raw data/botham_2022/rdata.rds')

data.table::setnames(ddata, tolower(colnames(ddata)))
data.table::setnames(
   x = ddata,
   old = c('site code','country','easting','northing','length'),
   new = c('local','regional','longitude','latitude','alpha_grain'))

# Converting coordinates
coords <- unique(ddata[, .(regional, local, alpha_grain, latitude, longitude)])
Ireland <- sf::st_as_sf(coords[regional == 'Northern Ireland'], coords = c('longitude', 'latitude'), crs = sf::st_crs(29901))
NotIreland <- sf::st_as_sf(coords[regional != 'Northern Ireland'], coords = c('longitude', 'latitude'), crs = sf::st_crs(27700))

coords_sf <- rbind(
   sf::st_transform(Ireland, crs = sf::st_crs('+proj=longlat +datum=WGS84')),
   sf::st_transform(NotIreland, crs = sf::st_crs('+proj=longlat +datum=WGS84'))
)
coords_sf[, 'longitude'] <- sf::st_coordinates(coords_sf)[, 1]
coords_sf[, 'latitude'] <- sf::st_coordinates(coords_sf)[, 2]
data.table::setDT(coords_sf)



# Communities ----
ddata[, ':='(
   dataset_id = dataset_id,

   value = 1L,

   latitude = NULL,
   longitude = NULL,
   alpha_grain = NULL
)]


# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta <- meta[coords_sf[, geometry := NULL], on = c('regional', 'local')]

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "checklist",

   effort = 26L,

   alpha_grain = alpha_grain * 5L,
   alpha_grain_type = 'plot',
   alpha_grain_unit = 'm2',
   alpha_grain_comment = 'area of the belt transects. Length varies between sites',

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "transect",
   gamma_sum_grains_comment = "sum of the sampled transects",

   # gamma_bounding_box = c(130279L, 20779L, 77933L, 14130L, 572L, 198L)[data.table::chmatch(regional, c('England', 'Wales', 'Scotland', 'Northern Ireland','Isle of Man', 'Channel Islands'))],
   # gamma_bounding_box_unit = "km2",
   # gamma_bounding_box_type = "administrative",
   # gamma_bounding_box_comment = "area of the country",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates given by the authors",

   comment = "Extracted from https://doi.org/10.5285/1286b858-34a7-4ff2-84a1-a55e48d63e86. Butterflies samples obtained by trained volunteers walking along fixed transects from UK. METHODS: 'a fixed-route walk (transect) is established at a site and butterflies are recorded along the route on a regular (weekly) basis under reasonable weather conditions for a number of years. Transect routes are chosen to sample evenly the habitat types and management activity on sites. Care is taken in choosing a transect route as it must then remain fixed to enable butterfly sightings to be compared from year to year. Transects are typically about 2-4km long, taking between 45 minutes and two hours to walk, and are divided into sections corresponding to different habitat or management units.
Butterflies are recorded in a fixed width band (typically 5m wide) along the transect each week from the beginning of April until the end of September yielding, ideally, 26 counts per year.' . Coordinates were converted to WGS84 following authors' indication:
Spatial reference systems
OSGB 1936 / British National Grid
OSNI 1952 / Irish National Grid",
comment_standardisation = "none needed"
)][, ':='(
   gamma_sum_grain = sum(alpha_grain, na.rm = TRUE),
   gamma_bounding_box = geosphere::areaPolygon(x = data.frame(longitude, latitude)[grDevices::chull(x = longitude, y = latitude), ]) / 10^6
), by = .(regional, year)]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)

