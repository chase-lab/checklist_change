# vernon_2013
dataset_id <- "vernon_2013"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

# melting the islands
ddata[, paste0("tmp", 1:8) := data.table::tstrsplit(distribution, "/")]
ddata <- data.table::melt(data = ddata,
                          id.vars = c("species", "status", "distribution"),
                          value.name = "local"
)
# extracting the "(ex)" for extinction
ddata[j = c("local", "status2") := data.table::tstrsplit(local, " \\(")][
   j = status2 := sub("\\)", "", status2)]

# assessing periods during which species are recent and melting period
ddata[, period_temp := data.table::fcase(
   status %in% c("E", "I") & is.na(status2), "historical+recent",
   status %in% c("E", "I") & status2 == "ex", "historical",
   default = "recent"
)]
ddata[, c("period_temp", "period_temp2") := data.table::tstrsplit(period_temp, "\\+")]
ddata <- data.table::melt(data = ddata,
                          id.vars = c("species", "local"),
                          measure.vars = c("period_temp", "period_temp2"),
                          value.name = "period"
)
ddata <- na.omit(ddata)

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Hawaii Archipelago",
   local = c("Niihau", "Kauai", "Oahu", "Molokai", "Lanai", "Maui", "Kaho olawe",
             "Hawaii")[match(local,
                             c("N", "K", "O", "Mo", "L", "Ma", "Ka", "H"))],

   value = 1L
)][, ":="(
   year = c(1800L, 2013L)[match(period, c("historical", "recent"))],
   period = NULL,
   variable = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])

latitudes <- parzer::parse_lat(c("21°54`N", "22°05`N", "21.4730°N", "21°08`N",
                                 "20°50`N", "20°48`N", "20°33`N", "19.566667 N"))
longitudes <- parzer::parse_lon(c("160°10`W", "159°30`W", "157.9868°W", "157°02`W",
                                  "156°56`W", "156°20`W", "156°36`W", "-155.5 E"))

meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   latitude = latitudes[match(
      local,
      c("Niihau", "Kauai", "Oahu", "Molokai", "Lanai", "Maui", "Kaho olawe", "Hawaii")
   )],
   longitude = longitudes[match(
      local,
      c("Niihau", "Kauai", "Oahu", "Molokai", "Lanai", "Maui", "Kaho olawe", "Hawaii")
   )],

   effort = 1L,

   alpha_grain = c(180, 1456.4, 1545.4, 673.4, 364, 1883, 115.5, 10430)[match(
      local,
      c("Niihau", "Kauai", "Oahu", "Molokai", "Lanai", "Maui", "Kaho olawe", "Hawaii")
   )],
   alpha_grain_unit = "km2",
   alpha_grain_type = "island",
   alpha_grain_comment = "Wikipedia",

   gamma_sum_grains = 28311L,
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "sum of the area of the islands constituting the archipelago",

   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitudes, latitudes)[grDevices::chull(longitudes, latitudes), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "Extracted from  Amanda L. Vernon and Tom A. Ranker 'Current Status of the Ferns and Lycophytes of the Hawaiian Islands,' American Fern Journal 103(2), 59-111, (1 April 2013). https://doi.org/10.1640/0002-8444-103.2.59. A checklist of ferns in Hawaii Islands Vernon and Ranker compiled existing floras and inventories of ferns and lycophytes on 8 Haawaiian islands. Historical and recent composition provided here were reconstructed by considering that extinct species were only recent in historical times and exotic species only appeared in recent times.
Regional is the Hawaiian archipelago and local are islands.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1640/0002-8444-103.2.59'
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
