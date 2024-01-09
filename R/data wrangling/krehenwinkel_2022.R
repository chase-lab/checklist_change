# krehenwinkel_2022
dataset_id <- "krehenwinkel_2022"

ddata <- base::readRDS("data/raw data/krehenwinkel_2022/rdata.rds")
ddata <- ddata[j = local := paste(local, tree_species, sep = "_")][
   j = c("tree_species", "value") := NULL]
# coords <- sf::st_as_sf(ddata[, .(local, latitude, longitude)], coords = c( "longitude", "latitude"), crs = sf::st_crs("EPSG:23033"))
# # 2583
# # 5556
# # 23033
#
# coords <- sf::st_transform(coords, crs = "EPSG:4326")
# coords <- sf::st_coordinates(coords)
# coords
# ddata[, ":="(
#    latitude = coords[,'Y'],
#    longitude = coords[, 'X']
# )]
#
# world_map <- rnaturalearth::ne_countries(scale = 50, returnclass = 'sf')
# germ <- world_map[world_map$name == "Germany",]
# plot(germ, max.plot = 1)
# points(ddata$longitude, ddata$latitude)
# plot(ddata$longitude, ddata$latitude, asp = 1)
if (any(ddata$latitude > 90)) ddata[, c("latitude","longitude") := NA]

# data ----

ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Germany",

   value = 1L
)]

ddata <- ddata[
   i = !ddata[, diff(range(year)) < 9L, keyby = local][(V1)],
   on = "local"]

# metadata

meta <- unique(ddata[, .(dataset_id, regional, local, year,
                         latitude, longitude)])

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "several trees per site",

   alpha_grain = 100L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "estimated area of the crown of a tree",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the sampled trees",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by authors",

   comment = "Data extracted from the Supplement material of Henrik Krehenwinkel, Sven Weber, Rieke Broekmann, Anja Melcher, Julian Hans, Rüdiger Wolf, Axel Hochkirch, Susan Rachel Kennedy, Jan Koschorreck, Sven Künzel, Christoph Müller, Rebecca Retzlaff, Diana Teubner, Sonja Schanzer, Roland Klein, Martin Paulus, Thomas Udelhoven, Michael Veith (2022) Environmental DNA from archived leaves reveals widespread temporal turnover and biotic homogenization in forest arthropod communities eLife 11:e78521.
METHODS: 'We used a total of 312 leaf samples of four common German tree species: the European Beech Fagus sylvatica (98 samples), the Lombardy Poplar Populus nigra ‘italica’ (65 samples), the Norway Spruce Picea abies (123 samples), and the Scots Pine Pinus sylvestris (26 samples). The samples have been collected annually or biannually by the German Environmental Specimen Bank (ESB) since the 1980s[...]. A total of 24 sampling sites were included, covering sampling periods of up to 31 years and representing four land use types of varying degrees of anthropogenic disturbance [...]. ESB samples are collected and processed according to a highly standardized protocol at the same time every year. Sampling events between different years of the time series usually do not differ by more than 2 weeks.[...] A defined amount of leaf material (>1.100 g) is collected from a defined number of trees (15 at most sites) from each site and from 4 branches from each tree. The branches are distributed equally spaced in the outer crown area of the tree. The amount sampled translates to several thousand leaves from each site, which should suffice to saturate the recovered arthropod diversity.'
Regional is Germany, local are single trees from which many leaves were sampled",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.7554/eLife.78521"
)]

ddata[, c("latitude", "longitude") := NULL]

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
