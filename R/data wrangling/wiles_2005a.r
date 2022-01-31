dataset_id <- "wiles_2005a"

birds_raw <- base::readRDS(paste0("./data/raw data/wiles_2005/birds_raw.rds"))

# Environment ----
gift <- base::readRDS("./data/GIS data/giftdata.rds")
env <- data.table::fread(paste0("./data/raw data/wiles_2005/wiles_2005_gift.csv"),
  na.strings = c("", "NA"),
  skip = 1
)
env[, c("latitude", "longitude") := data.table::tstrsplit(coordinates, " ")][, coordinates := NULL]
env[, c("longitude", "latitude") := parzer::parse_lon_lat(longitude, latitude)]

env[, ":="(
  latitude = data.table::fifelse(
    is.na(latitude),
    gift$Lat[match(match_island_GIFT_ID, gift$ID)],
    latitude
  ),
  longitude = data.table::fifelse(
    is.na(latitude),
    gift$Long[match(match_island_GIFT_ID, gift$ID)],
    longitude
  )
)]

data.table::setnames(env, "area_km2", "alpha_grain")

env[, alpha_grain := data.table::fifelse(
  is.na(alpha_grain),
  gift$Area[match(match_island_GIFT_ID, gift$ID)],
  alpha_grain
)]

## aggregating gift islands belonging to the same state
env[, ":="(
  alpha_grain = sum(alpha_grain),
  latitude = mean(latitude),
  longitude = mean(longitude)
),
by = local
]

env <- unique(env[, .(local, alpha_grain, latitude, longitude)])


# community ----

birds <- lapply(birds_raw, function(mat) data.table::setDT(as.data.frame(mat)))

# Missing rows in page 6 and 7
birds[[6]] <- data.table::data.table(rbind(
  stats::setNames(data.frame("Spotted Redshank•", "Tringa erythropus", "", "", "H-J2", "", "V-O4", "", "", "", ""), paste0("V", 1:11)),
  birds[[6]]
))

birds[[7]] <- data.table::data.table(rbind(
  stats::setNames(
    data.frame(
      c("[Pin-tailed Snipe]", "Swinhoe’s Snipe"),
      c("Gallinago stenura", "Gallinago megala"),
      c("", "M-B1"),
      c("", "M-P8"),
      c("", "M-B1"),
      c("H-P8", "M-P8"),
      c("", "M-P8"),
      c("", ""), c("", ""), c("", ""), c("", "")
    ),
    paste0("V", 1:11)
  ),
  birds[[7]]
))

# harmonising column names for all and deleting first row for all but pages 6 and 7
sapply(birds[-(6:7)], function(dt) data.table::setnames(dt, new = c("english_name", "species", unlist(dt[1])[-(1:2)])))
sapply(birds[6:7], function(dt) data.table::setnames(dt, new = colnames(birds[[1]])))
birds[-(6:7)] <- lapply(birds[-(6:7)], function(dt) dt[-1])

# In some tables, columns GUAM and NMI are not split
lapply(birds[sapply(birds, ncol) == 10], function(dt) {
  dt[, c("GUAM", "CNMI") := data.table::tstrsplit(unlist(.SD), "(?<=[0-9])\\ {1}(?=[A-Z])", perl = TRUE), .SDcols = patterns("GUAM")]
  dt[, 5 := NULL]
  return()
})


ddata <- data.table::rbindlist(birds, fill = FALSE, use.names = TRUE)

ddata[, family := data.table::fifelse(grepl("AE$", species), species, as.character(NA))][, family := zoo::na.locf(family)]
ddata[, species := data.table::fifelse(species == "", stringi::stri_extract_first_regex(english_name, "(?<= )[A-Za-z]+ [a-z]+$"), species)]
ddata <- ddata[species != family & !grepl("Total", english_name)]

# deleting marine species
# ddata <- ddata[!family %in% c('DIOMEDEIDAE','FREGATIDAE','PROCELLARIIDAE','HYDROBATIDAE','SULIDAE','LARIDAE') ] # PELECANIDAE?
# excluding species coded as pelagic or migrants instead



# Melting sites
ddata[, names(ddata) := lapply(.SD, function(column) replace(column, column == "", NA))] # replace all '' values by NA
ddata <- data.table::melt(ddata,
  id.vars = c("family", "species", "english_name"),
  variable.name = "local",
  value.name = "value",
  na.rm = TRUE
)

# Recoding, splitting and melting values into periods
ddata[, period_raw := c("historical+recent", "historical", "historical", "recent", "historical+recent", NA, NA, NA, NA)[match(substr(value, 1L, 1L), c("R", "X", "C", "I", "M", "S", "P", "V", "H"))]]
ddata[, c("period_temp_1", "period_temp_2") := data.table::tstrsplit(period_raw, "\\+")]
ddata <- data.table::melt(ddata,
  id.vars = c("species", "local"),
  measure.vars = c("period_temp_1", "period_temp_2"),
  value.name = "period",
  na.rm = TRUE
)

# Ddata ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Micronesia",
  local = c("Palau", "Yap", "Guam", "Northern Mariana Islands", "Chuuk", "Pohnpei", "Kosrae", "Marshall islands", "Wake")[match(local, c("PAL", "YAP", "GUAM", "CNMI", "CHU", "POHN", "KOSR", "MARS", "WAKE"))],

  year = c(1800L, 2000L)[match(period, c("historical", "recent"))],

  value = 1L,

  period = NULL,
  variable = NULL
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta <- merge(meta, env, all.x = TRUE)
meta[, ":="(
  taxon = "Birds",
  realm = "Terrestrial",

  effort = 1L,

  alpha_grain_unit = "km2",
  alpha_grain_type = "island",

  gamma_sum_grains = sum(env$alpha_grain),
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "archipelago",

  gamma_bounding_box = geosphere::areaPolygon(env[grDevices::chull(env[, c("longitude", "latitude")]), c("longitude", "latitude")]) / 10^6,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  comment = "Extracted from Wiles, G. J. (2005). A checklist of the birds and mammals of Micronesia. MICRONESICA-AGANA-, 38(1), 141. For Birds, the authors compiled and updated the existing inventories of 8 islands or groups of islands of the Micronesian Archipelago. local is an island or a group of islands. Historical and recent compositions were reconstructed by considering that extinct species were only present in historical times and invasive species were only present in recent times.",
  comment_standardisation = "pelagic, occasional, vagrant and hypothetical species excluded"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
