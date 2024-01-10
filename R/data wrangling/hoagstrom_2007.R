## hoagstrom_2007

dataset_id <- "hoagstrom_2007"
ddata <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/rdata.csv"),
   skip = 1L
)

## melting sites
ddata <- data.table::melt(data = ddata,
                          id.vars = "species",
                          variable.name = "local"
)

# recoding, splitting and melting period
ddata[, temp := data.table::fifelse(
   grepl("e", value) & !grepl("1|2", value), "1850+1990",
   data.table::fifelse(
      grepl("e", value) & grepl("1|2", value), "1990",
      data.table::fifelse(grepl("1|2", value), "1990+2004", "1850+1990+2004")
   )
)]

ddata[, paste0("tmp", 1L:3L) := data.table::tstrsplit(temp, "\\+")][, temp := NULL]

ddata <- data.table::melt(data = ddata,
                          id.vars = c("species", "local", "value"),
                          measure.vars = paste0("tmp", 1L:3L),
                          value.name = "year"
)

ddata <- ddata[!value %in% c("", "*", "*q") & !is.na(year)]

# environment data from Jones 2019 thesis
env <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/Jones_et_al_2019_Table1-1.csv"),
   skip = 1L, header = TRUE, encoding = "Latin-1", sep = ",")
env <- unique(env[i = !grepl("T", block),
                  j = .(coord = downstream[.N], latitude, longitude),
                  by = local # coordinates of the most downstream site on the main tributary only
][, ":="(
   local = data.table::fifelse(grepl("Creek|Valley", local), local, paste(local, "River")),
   latitude = data.table::fifelse(latitude == "", substr(coord, 1L, 8L), latitude),
   longitude = data.table::fifelse(longitude == "", substr(coord, 10L, 20L), longitude)
)])[, ":="(
   latitude = parzer::parse_lat(latitude),
   longitude = parzer::parse_lon(longitude)
)]
env[, gamma_sum_grains := geosphere::areaPolygon(env[grDevices::chull(env[, c("longitude", "latitude")]), c("longitude", "latitude")]) / 10^6]

# community data
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "South Dakota",
   species = trimws(gsub(";.*|white crappie 2", "", species)),

   value = 1L,

   variable = NULL
)]



## GIS for grain computation
# done once,
# if (!file.exists("data/cache/hydrologic_units_WBDHU8_sd_3896517_01/hydrologic_units/wbdhu8_a_sd.prj")) unzip(zipfile = path.expand("data/GIS data/hydrologic_units_WBDHU8_sd_3896517_01.zip"),
#       exdir = "data/cache/hydrologic_units_WBDHU8_sd_3896517_01"
#       )
# watersheds <- rgdal::readOGR("data/cache/hydrologic_units_WBDHU8_sd_3896517_01/hydrologic_units",
#                layer = "wbdhu8_a_sd")
# unz(path.expand("data/GIS data/hydrologic_units_WBDHU8_sd_3896517_01.zip"), filename = "/hydrologic_units/wbdhu8_a_sd.shp")


# Metadata
alpha_grain <- as.data.frame(matrix(c(
   "Bois de Sioux River", 2875.05,
   "Upper Minnesota River", 5515.24,
   "Big Sioux River", 4229.55 + 8854.54, # upper + lower
   "Vermillion River", 5487.52,
   "James River", 11583.36 + 9603.80 + 9428.56, # upper + middle + lower
   "Missouri Valley (lower)", NA_character_,
   "Niobrara River", 10753.28 + 9809.29, # upper + middle
   "Ponca Creek", 2137.02,
   "White River", 6301.74 + 5455.13 + 9801.58, # Middle + lower + upper
   "Crow Creek", 3019.35,
   "Bad River", 8225.90,
   "Cheyenne River", 4088.64 + 5499.86 + 4197.75, # Middle Cheyenne-Elk + Middle Cheyenne-Spring + Lower Cheyenne
   "Moreau River", 4061.28 + 6884.46, # upper + lower
   "Grand River", 6207.50,
   "Missouri Valley (upper)", NA_character_,
   "Little Missouri River", 8994.32 # upper
), byrow = TRUE, ncol = 2))
alpha_grain[is.na(alpha_grain)] <- mean(as.numeric(alpha_grain[, 2]), na.rm = TRUE)


meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Fish",
   realm = "Freshwater",

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review",

   latitude = env$latitude[match(local, env$local)],
   longitude = env$longitude[match(local, env$local)],

   alpha_grain = as.numeric(alpha_grain[, 2])[match(local, alpha_grain[, 1])],
   alpha_grain_unit = "km2",
   alpha_grain_type = "watershed",
   alpha_grain_comment = "extracted of hydrologic_units_WBDHU8_sd_3896517_01.zip provided by the USDA Geospatial Data Gateway",

   gamma_sum_grains = sum(as.numeric(alpha_grain[, 2])),
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "watershed",
   gamma_sum_grains_comment = "sum of the individual watersheds",

   gamma_bounding_box = env$gamma_sum_grains[1L],
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "Extracted from  Christopher W. Hoagstrom, Steven S. Wall, Jason G. Kral, Brian G. Blackwell, and Charles R. Berry 'ZOOGEOGRAPHIC PATTERNS AND FAUNAL CHANGE OF SOUTH DAKOTA FISHES,' Western North American Naturalist 67(2), 161-184, (1 April 2007). https://doi.org/10.3398/1527-0904(2007)67[161:ZPAFCO]2.0.CO;2
Extraction with tabulizer and modification by hand in excel.
Checklist of 16 river catchments. Authors aggregated data through a literature review:
METHODS: 'We used literature to determine fish species presence in 14 river drainages and 2 sections of the Missouri River valley in South Dakota'. Coordinates (extracted from Jones 2019 thesis from Table 1-1) of the most downstream site on the main tributary only. Scale and time coverage differ between jones_2019 and hoagstrom_2007. Even sites and times that seem to overlap have different composition.
Regional is South Dakota state, local are major tributaries to the Missouri River.",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.3398/1527-0904(2007)67[161:ZPAFCO]2.0.CO;2"
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
