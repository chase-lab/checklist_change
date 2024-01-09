# su_2021
dataset_id <- "su_2021"

## loading before and after communities ----
load("data/raw data/su_2021/Sugh-biodiveristy_freshwaterfish_paper_abd3369/000_input/Occ_bef_2456_10682")

load("data/raw data/su_2021/Sugh-biodiveristy_freshwaterfish_paper_abd3369/000_input/Occ_aft_2456_10682")

basins <- rownames(Occ_aft_2456_10682)

## loading environmental variables ----
load("data/raw data/su_2021/Sugh-biodiveristy_freshwaterfish_paper_abd3369/000_input/basin_2456")

data.table::setDT(basin_2456)
data.table::setnames(
   x = basin_2456,
   old = c("Basin.Name", "Median.Longitude", "Median.Latitude",
           "Surface.Area", "realm"),
   new = c("local", "longitude", "latitude", "alpha_grain", "regional")
)


## melting and merging before and after communities ----
data.table::setDT(Occ_bef_2456_10682)
Occ_bef_2456_10682[, local := basins]
Occ_bef_2456_10682 <- data.table::melt(
   data = Occ_bef_2456_10682,
   id.vars = "local",
   variable.name = "species")
Occ_bef_2456_10682 <- Occ_bef_2456_10682[value > 0]
Occ_bef_2456_10682[, period := "historical"]

data.table::setDT(Occ_aft_2456_10682)
Occ_aft_2456_10682[, local := basins]
Occ_aft_2456_10682 <- data.table::melt(
   data = Occ_aft_2456_10682,
   id.vars = "local",
   variable.name = "species")
Occ_aft_2456_10682 <- Occ_aft_2456_10682[value > 0]
Occ_aft_2456_10682[, period := "recent"]

ddata <- rbind(Occ_bef_2456_10682, Occ_aft_2456_10682)

## community table ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = basin_2456$regional[match(local, basin_2456$local)],

   year = c(1700L, 2018L)[match(period, c("historical", "recent"))],
   period = NULL
)]


## metadata table ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta <- merge(meta, basin_2456[, .(local, longitude, latitude, alpha_grain)])

meta[, ":="(
   realm = "Freshwater",
   taxon = "Fish",

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review",

   alpha_grain_unit = "km2",
   alpha_grain_type = "watershed",
   alpha_grain_comment = "provided by the authors in 000_input/basin_2456",

   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "watershed",

   # gamma_bounding_box = c(22.1, 7.6, 22.9, 19, 7.5, 54.1)[match(regional, c("Afrotropical", "Australian" , "Nearctic"  , "Neotropical" ,  "Oriental" , "Palearctic"))] * 10^6,
   # gamma_bounding_box_unit = 'km2',
   # gamma_bounding_box_type = "ecozone",
   # gamma_bounding_box_comment = "values from https://en.wikipedia.org/wiki/Biogeographic_realm#WWF_/_Global_200_biogeographic_realms_(BBC_%22ecozones%22)",

   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "Extracted from the authors' figshare repository Su, Guohuan; Villeger, Sébastien; Sebastien, Brosse; Tao, Shengli; Xu, Jun; Logez, Maxime (2021). Scripts and files for 'Human Impacts on Global Freshwater Fish Biodiversity'. figshare. Online resource. https://doi.org/10.6084/m9.figshare.13383170.v1. The authors gathered historical and recent fish composition in 2456 river basins worldwide.
Regional are Biomes and local are watersheds.",
   doi = "https://doi.org/10.6084/m9.figshare.13383170.v1 | https://doi.org/10.1126/science.abd3369",
   comment_standardisation = "none needed"
)][, gamma_sum_grains := sum(alpha_grain) / 2, by = .(regional, year)]

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
