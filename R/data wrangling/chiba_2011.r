# chiba_2011
dataset_id <- "chiba_2011"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

islands <- c("Muko", "Na", "Yo", "Chichijima", "Anijima", "Otojima", "Nishijima",
             "Higashijima", "Minamijima", "Hy", "Hahajima", "Hirashijima",
             "Mukoujima", "Anejima", "Meijima", "Imotojima")
archipelagos <- rep(c("Mucojima", "Chichijima", "Hahajima"), times = c(3, 7, 6))
data.table::setnames(
   x = ddata,
   old = c("Mc", "Na", "Yo", "Ch", "An", "Ot", "Ni", "Hg", "Mi", "Hy", "Ha",
           "Hi", "Mk", "Ae", "Me", "Im"),
   new = islands
)

# GIS
ogasawara_archipelago <- sf::read_sf(dsn = "data/GIS data/chiba_2011_island_shapes.kml")

ogasawara_archipelago$Description[ogasawara_archipelago$Description == "Mimamijima"] <- "Minamijima" # typo

# island coordinates
sf::sf_use_s2(use_s2 = FALSE)
ogasawara_archipelago <- sf::st_zm(ogasawara_archipelago, drop = TRUE) |>
   sf::st_centroid() |>
   sf::st_coordinates() |>
   cbind(ogasawara_archipelago)

# archipelago extent
ogasawara_archipelago$alpha_grain <- ogasawara_archipelago |>
   sf::st_convex_hull() |>
   sf::st_area()

mucojima_extent <- sum(ogasawara_archipelago$alpha_grain[match(
   x = ogasawara_archipelago$Description, table = islands[1:3], nomatch = 0L)])
chichijima_extent <- sum(ogasawara_archipelago$alpha_grain[match(
   x = ogasawara_archipelago$Description, table = islands[4:9], nomatch = 0L)])
hahajima_extent <- sum(ogasawara_archipelago$alpha_grain[match(
   x = ogasawara_archipelago$Description, islands[11:16], nomatch = 0L)])

# melting sites
ddata[, species := paste(Genus, species, SpeciesNo)]
ddata <- data.table::melt(
   data = ddata,
   id.vars = c("species", "period"),
   measure.vars = c("Muko", "Na", "Yo", "Chichijima", "Anijima", "Otojima", "Nishijima",
                    "Higashijima", "Minamijima", "Hy", "Hahajima", "Hirashijima",
                    "Mukoujima", "Anejima", "Meijima", "Imotojima"),
   value.name = "value",
   variable.name = "local",
   na.rm = TRUE
)
ddata <- ddata[value != 0]
ddata[, value := 1]

# Community data
ddata[, ":="(
   dataset_id = dataset_id,
   regional = archipelagos[match(local, islands)],

   year = c(1991L, 2009L)[match(period, c("historical", "modern"))],
   period = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
data.table::setDT(ogasawara_archipelago)
meta[i = ogasawara_archipelago,
     j = ":="(
     latitude = i.Y,
     longitude = i.X,
     alpha_grain = i.alpha_grain),
     on = c("local" = "Description")]

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   effort = 1L,

   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "only one sampling per location per period",
   sampling_years = c("1987-1991", "2004-2009")[match(year, c(1991L, 2009L))],

   # alpha_grain = 100L,
   # alpha_grain_unit = 'm2',
   # alpha_grain_type = 'sample',

   alpha_grain_unit = "m2",
   alpha_grain_type = "island",

   gamma_sum_grains = c(mucojima_extent, chichijima_extent, hahajima_extent)[match(regional, c("Mucojima", "Chichijima", "Hahajima"))],
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "sum of the area of the islands. The area of 3 out of 16 islands (the smallest) is unknown so the extent is slightly underestimated.",

   gamma_bounding_box = geosphere::areaPolygon(x = na.omit(data.frame(longitude, latitude))[grDevices::chull(x = na.omit(longitude), y = na.omit(latitude)), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "Extracted from Chiba & Roy 2011, PNAS, Selectivity of terrestrial gastropod extinctions on an oceanic archipelago and insights into the anthropogenic extinction process by  Smith, KG, Almeida, RJ. When are extinctions simply bad luck? Rarefaction as a framework for disentangling selective and stochastic extinctions. J Appl Ecol. 2020; 57: 101–110. https://doi.org/10.1111/1365-2664.13510.
METHODS: 'The Terrestrial gastropod fauna of the Ogasawara archipelago has been examined since early surveys during 1839–1907, followed by work in 1930-1940, 1973, 1977, and 1987-1991. We used these baseline data along with more recent surveys in 2004–2009 to identify local and global extinctions'.
Exact effort varies and is unknown: 'number of sites (9-20 per area during 1987-1991 and 10-35 during 2004-2009)'. In each site a 10x10m plot was searched for large species and 20 .5x.5m subsamples were thoroughly searched for small species.
Regional is the archipelago (one of the three archipelagos of the Ogasawara archipelago). local is an island.",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.1073/pnas.1100085108 | https://doi.org/10.1111/1365-2664.13510"
)]

base::dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
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
