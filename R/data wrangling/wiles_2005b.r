dataset_id <- "wiles_2005b"

mammals_raw <- base::readRDS(paste0("data/raw data/wiles_2005/mammals_raw.rds"))

# Environment ----
gift <- base::readRDS("data/GIS data/giftdata.rds")
env <- data.table::fread(
   file = paste0("data/raw data/wiles_2005/wiles_2005_gift.csv"),
   sep = "\t", header = TRUE, na.strings = c("", "NA"),
   skip = 1, encoding = "Latin-1"
)
env[, c("latitude", "longitude") := data.table::tstrsplit(coordinates, " ")][, coordinates := NULL]
env[!is.na(longitude), c("longitude", "latitude") := parzer::parse_lon_lat(longitude, latitude)]

env[is.na(latitude), ":="(
   latitude = gift$Lat[match(match_island_GIFT_ID, gift$ID)],
   longitude = gift$Long[match(match_island_GIFT_ID, gift$ID)]
)]

data.table::setnames(env, "area_km2", "alpha_grain")

env[i = is.na(alpha_grain),
    j = alpha_grain := gift$Area[match(match_island_GIFT_ID, gift$ID)]][
       j = gamma_sum_grains := sum(alpha_grain)]

## aggregating gift islands belonging to the same state
env[, ":="(
   alpha_grain = as.numeric(alpha_grain),
   latitude = as.numeric(latitude),
   longitude = as.numeric(longitude)
)][, ":="(
   alpha_grain = sum(alpha_grain),
   latitude = mean(latitude),
   longitude = mean(longitude)
), keyby = local]

env <- unique(env[, .(local, alpha_grain, gamma_sum_grains, latitude, longitude)])


# community ----

mammals <- lapply(mammals_raw, function(mat) data.table::setDT(as.data.frame(mat)))


# harmonising column names for all and deleting first row for all but pages 6 and 7
for (i in seq_along(mammals)) data.table::setnames(
   mammals[[i]],
   new = c("english_name", "species", unlist(mammals[[i]][1])[-(1:2)])
)
mammals <- lapply(mammals, function(dt) dt[-1])

ddata <- data.table::rbindlist(mammals, fill = FALSE, use.names = TRUE)

ddata[, family := data.table::fifelse(
   test = grepl("AE$", species),
   yes = species,
   no = as.character(NA))][, family := zoo::na.locf(family)]
ddata[, species := data.table::fifelse(
   test = species == "",
   yes = stringi::stri_extract_first_regex(english_name, "(?<= )[A-Za-z]+ [a-z]+$"),
   no = species)]
ddata <- ddata[species != family & !grepl("Total", english_name)]

# deleting marine species
# ddata <- ddata[!family %in% c('') ]
# excluding species coded as pelagic or migrants instead



# Melting sites
ddata[, names(ddata) := lapply(.SD, function(column) replace(column, column == "", NA))] # replace all '' values by NA
ddata <- data.table::melt(
   data = ddata,
   id.vars = c("family", "species", "english_name"),
   variable.name = "local",
   value.name = "value",
   na.rm = TRUE
)

# Recoding, splitting and melting values into periods
ddata[, period_raw := c("historical+recent", "historical", "historical", "recent",
                        NA, NA, NA,
                        NA, NA)[match(
                           x = substr(value, 1, 1),
                           table = c("R", "X", "C", "I", "M", "S", "P", "V", "H"))]]
ddata[, c("period_temp_1", "period_temp_2") := data.table::tstrsplit(period_raw, "\\+")]
ddata <- data.table::melt(
   data = ddata,
   id.vars = c("species", "local"),
   measure.vars = c("period_temp_1", "period_temp_2"),
   value.name = "period",
   na.rm = TRUE
)

ddata[, ":="(
   dataset_id = dataset_id,

   year = c(1521L, 2005L)[data.table::chmatch(period, c("historical", "recent"))],

   regional = "Micronesia",
   local = c("Guam", "Palau", "Yap", "Northern Mariana Islands", "Chuuk", "Pohnpei",
             "Kosrae", "Marshall islands", "Wake")[match(
                x = local,
                table = c("GUAM", "PAL", "YAP", "CNMI", "CHU",
                          "POHN", "KOSR", "MARS", "WAKE")
             )],



   period = NULL,
   variable = NULL,
   value = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta <- merge(meta, env)
meta[, ":="(
   taxon = "Mammals",
   realm = "Terrestrial",

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review",

   alpha_grain_unit = "km2",
   alpha_grain_type = "island",
   alpha_grain_comment = "island name matched with the gift database to get coordinates and area",

   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "sum of the area of the islands",

   gamma_bounding_box = geosphere::areaPolygon(env[grDevices::chull(env[, c("longitude", "latitude")]), c("longitude", "latitude")]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "Extracted from Wiles, G. J. (2005). A checklist of the birds and mammals of Micronesia. MICRONESICA-AGANA-, 38(1), 141.
For Mammals, the authors created the first inventory for 8 islands or groups of islands of the Micronesian Archipelago. local is an island or a group of islands. Historical and recent compositions were reconstructed by considering that extinct species were only present in historical times and invasive species were only present in recent times.
Regional is the Micronesian region, local are archipelagos",
   comment_standardisation = "Non-breeding species, ie species with status S, P, V, H or M species excluded"
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
