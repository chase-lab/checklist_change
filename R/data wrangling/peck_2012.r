## peck_2012
dataset_id <- "peck_2012"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

# splitting and melting island names
ddata[, paste0("tmp", 1:12) := data.table::tstrsplit(distribution, ", ")]
ddata <- data.table::melt(ddata,
                          id.vars = c("species", "status"),
                          value.name = "local",
                          measure.vars = paste0("tmp", 1:12),
                          na.rm = TRUE
)

# recoding, splitting and melting status into period
ddata[, status := c("historical+recent", "recent", "recent", NA_character_)[match(status, c("Native, Endemic", "Introduced, Accidental", "Introduced, Questionable Native", "No Data"))]]
ddata[, paste0("tmp", 1:2) := data.table::tstrsplit(status, "\\+")]
ddata <- data.table::melt(ddata,
                          id.vars = c("species", "local"),
                          measure.vars = paste0("tmp", 1:2),
                          value.name = "period",
                          na.rm = TRUE
)

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Galapagos",

   value = 1L,
   year = c(1500L, 2000L)[match(period, c("historical", "recent"))],

   period = NULL,
   variable = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
island_names <- c("Isabela", "Española", "Darwin", "San Cristóbal", "Fernandina",
                  "Floreana", "Genovesa", "Santa Cruz", "Pinta", "Marchena",
                  "Santiago", "Pinzón", "Santa Fé", "Wolf")
latitudes <- parzer::parse_lat(c("00°30`S", "1.38°S", "1.678°N", "0.83°S", "0°22`S",
                                 "1°17`51``S", '0°19`00"N', "0.623017°S", "0.587252°N", "0.35°N",
                                 "0.252364°S", "0.610236°S", "0.818°S", "1.382506°N"))
longitudes <- parzer::parse_lon(c("91°04`W", "89.68°W", "92.003°W", "89.43°W", "91°33`W",
                                  "90°26`03``W", '89°57`00"W', "90.368254°W", "90.762184°W", "90.5°W",
                                  "90.717952°W", "90.666234°W", "90.062°W", "91.815056°W"))

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   latitude = latitudes[match(local, island_names)],
   longitude = longitudes[match(local, island_names)],

   effort = 1L,

   alpha_grain = c(4640, 60, 1, 558, 642, 173, 14, 986, 60, 130, 585, 18, 24, 1.3)[match(local, island_names)],
   alpha_grain_unit = "km2",
   alpha_grain_type = "island",
   alpha_grain_comment = "Wikipedia",

   gamma_sum_grains = 7892.3,
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "sum of the area of the islands",

   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitudes, latitudes)[grDevices::chull(longitudes, latitudes), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "extracted from peck & Herrera CDF Checklist of Galapagos Cockroaches, Mantids and Termites. Species inventories of 14 islands and islets of the Galapagos archipelago. No known extinctions. Missing data on origin so distribution might be wider for some species. The accidental cockroach introductions could date as far as 1535 which is why this date is used for historical composition. Full reference: Peck, S. B., Herrera, H. W. (2011). CDF Checklist of Galapagos Cockroaches, Mantids and Termites - FCD Lista de especies de
Cucarachas, mantidos y termitas de Galápagos. In: Bungartz, F., Herrera, H., Jaramillo, P., Tirado, N., Jímenez-Uzcategui, G., Ruiz, D.,
Guézou, A. Ziemmeck, F. (eds.). Charles Darwin Foundation Galapagos Species Checklist - Lista de Especies de Galápagos de la
Fundación Charles Darwin. Charles Darwin Foundation / Fundación Charles Darwin, Puerto Ayora, Galapagos:
http://www.darwinfoundation.org/datazone/checklists/terrestrial-invertebrates/dictyoptera/ Regional is the Galapagos archipelago, local are islands",
   comment_standardisation = "none needed"
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
