# chiba_2011
dataset_id <- "chiba_2011"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

islands <- c("Muko", "Na", "Yo", "Chichijima", "Anijima", "Otojima", "Nishijima", "Higashijima", "Minamijima", "Hy", "Hahajima", "Hirashijima", "Mukoujima", "Anejima", "Meijima", "Imotojima")
archipelagos <- c(rep(c("Mucojima", "Chichijima", "Hahajima"), times = c(3, 7, 6)))
data.table::setnames(
  x = ddata,
  old = c("Mc", "Na", "Yo", "Ch", "An", "Ot", "Ni", "Hg", "Mi", "Hy", "Ha", "Hi", "Mk", "Ae", "Me", "Im"),
  new = islands
)

# GIS
library(sp)
ogasawara_archipelago <- rgdal::readOGR("./data/GIS data/chiba_2011_island_shapes.kml", pointDropZ = TRUE, verbose = FALSE)
ogasawara_archipelago$Description[ogasawara_archipelago$Description == "Mimamijima"] <- "Minamijima" # typo
# island coordinates
island_centroids <- t(sapply(
  lapply(
    slot(ogasawara_archipelago, "polygons"),
    function(x) {
      lapply(
        slot(x, "Polygons"),
        function(y) slot(y, "coords")
      )
    }
  ),
  function(x) geosphere::centroid(x[[1]])
))
dimnames(island_centroids) <- list(ogasawara_archipelago[[2]], c("Longitude", "Latitude"))

# archipelago extent
island_areas <- geosphere::areaPolygon(ogasawara_archipelago) / 1000000

mucojima_extent <- sum(island_areas[which(ogasawara_archipelago[[2]] %in% islands[1:3])])
chichijima_extent <- sum(island_areas[which(ogasawara_archipelago[[2]] %in% islands[4:9])])
hahajima_extent <- sum(island_areas[which(ogasawara_archipelago[[2]] %in% islands[11:16])])

# meling sites
ddata[, species := paste(Genus, species, SpeciesNo)]
ddata <- data.table::melt(ddata,
  id.vars = c("species", "period"),
  measure.vars = c("Muko", "Na", "Yo", "Chichijima", "Anijima", "Otojima", "Nishijima", "Higashijima", "Minamijima", "Hy", "Hahajima", "Hirashijima", "Mukoujima", "Anejima", "Meijima", "Imotojima"),
  value.name = "value",
  variable.name = "local",
  na.rm = TRUE
)
ddata <- ddata[value != 0]
ddata[value > 0, value := 1]


ddata[, ":="(
  dataset_id = dataset_id,
  regional = archipelagos[match(local, islands)],

  year = c(1991L, 2009L)[match(period, c("historical", "modern"))],
  period = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Invertebrates",
  realm = "Terrestrial",

  latitude = island_centroids[match(local, rownames(island_centroids)), "Latitude"],
  longitude = island_centroids[match(local, rownames(island_centroids)), "Longitude"],

  effort = 1L,

  data_pooled_by_authors = TRUE,
  data_pooled_by_authors_comment = "only one sampling per location per period",
  sampling_years = c("1987-1991", "2004-2009")[match(year, c(1991L, 2009L))],

  # alpha_grain = 100L,
  # alpha_grain_unit = 'm2',
  # alpha_grain_type = 'sample',

  alpha_grain = island_areas[match(local, rownames(island_centroids))],
  alpha_grain_unit = "km2",
  alpha_grain_type = "island",

  gamma_sum_grains = c(mucojima_extent, chichijima_extent, hahajima_extent)[match(regional, c("Mucojima", "Chichijima", "Hahajima"))],
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "archipelago",
  gamma_sum_grains_comment = "sum of the area of the islands. The area of 3 out of 16 islands (the smallest) is unknown so the extent is slightly underestimated.",

  gamma_bounding_box = geosphere::areaPolygon(island_centroids[grDevices::chull(island_centroids[, c("Longitude", "Latitude")]), c("Longitude", "Latitude")]) / 1000000,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  comment = "Extracted from Chiba et al excel table. Regional is the archipelago (one of the three archipelagos of the Ogasawara archipelago). local is an island. 'The Terrestrial gastropod fauna of the Ogasawara archipelago has been examined since early surveys during 1839–1907, followed by work in 1930-1940, 1973, 1977, and 1987-1991. We used these baseline data along with more recent surveys in 2004–2009 to identify local and global extinctions'. Effort varies and is unknown: 'number of sites (9-20 per area during 1987-1991 and 10-35 during 2004-2009)'. In each site a 10x10m plot was searched for large species and 20 .5x.5m subsamples were thoroughly searched for small species.",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.1073/pnas.1100085108 '
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
