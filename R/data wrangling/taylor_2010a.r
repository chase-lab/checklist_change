## taylor_2010a

dataset_id <- "taylor_2010a"
ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(ddata, c("local", paste(gsub("\\.+[0-9]+", "\\.", colnames(ddata)[-1]), unlist(ddata[1])[-1])))

ddata <- ddata[-(1:2)]

# building 2000 community
ddatah <- data.table::copy(ddata)
ddatah[local == "QCI", "L. ayresii" := 0]
ddatah[local == "NorthC", c("Alosa sapidissima", "Prosopium coulterii") := 1]
ddatah[local == "CentralC", ":="("Alosa sapidissima" = 1, "Salmo salar" = 0)]
ddatah[local == "VanI", ":="("Cyprinus carpio" = 1, "Thaleichthys pacificus" = 0, "Perca flavescens" = 0)]
ddatah[local == "Columbia", ":="("A. nebulosus" = 1,
  "O. clarkii clarkii" = 0,
  "O. aguabonita" = 1,
  "Thymallus arcticus" = 1,
  "C. bairdii" = 1,
  "C. hubbsi" = 0,
  "Cottus sp. RMS" = 0,
  "Lepomis. macrochirus" = 0,
  "M. dolomieu" = 0)]
ddatah[local == "Fraser", c("A. natalis", "Salmo salar", "Perca flavescens") := 0]

# binding 2000 and 2005 communities
ddata[, year := 2005L]
ddatah[, year := 2000L]
ddata <- rbind(ddata, ddatah)

# melting species
ddata <- data.table::melt(ddata,
  id.vars = c("local", "year"),
  variable.name = "species"
)

ddata <- ddata[value != 0]


ddata[, ":="(
  dataset_id = dataset_id,
  regional = "British Columbia"
)]

env <- data.table::data.table(
  local = c("Fraser", "Columbia", "Yukon", "QCI", "VanI", "Mackenz.", "CentralC", "NorthC"),
  coords = c("49°10'40 N 123°12'45 W", "46°14'39 N 124°3'29 W", "62°35'55 N 164°48'00 W", "53°N 132°W", "49°38'N 125°42'W", "68°56'23 N 136°10'22 W", "54°8'15 N 130°5'40 W", "56° 39' 58  N 131° 49' 33  W"),
  area = c(220000L, 670000L, 832700L, 10180L, 32134L, 1805200L, (54400L + 20839L), (52000L + 28023L + 27500L))
)
env[, c("latitude", "longitude") := data.table::tstrsplit(coords, "(?<=N) ", perl = TRUE)][, c("longitude", "latitude") := parzer::parse_lon_lat(lon = longitude, lat = latitude)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  realm = "Freshwater",
  taxon = "Fish",

  latitude = env$latitude[match(local, env$local)],
  longitude = env$longitude[match(local, env$local)],

  effort = 1L,

  alpha_grain = env$area[match(local, env$local)],
  alpha_grain_unit = "km2",
  alpha_grain_type = "watershed",

  gamma_sum_grains = sum(env$area),
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "ecosystem",

  gamma_bounding_box = geosphere::areaPolygon(env[grDevices::chull(env[, c("longitude", "latitude")]), c("longitude", "latitude")]) / 10^6,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  comment = "Extracted from supplementary 1, Taylor 2010 (10.1111/j.1472-4642.2010.00670.x). Data presented here are fish inventories that the authors compiled at the watershed scale in British-Columbia, Canada. Compositional change between 2000 and 2005 is detailed in table 1. Data on Lampetra tridentata is not coherent between supp and table 1. The area of North and Central coast regions is computed as the sum of their main river watersheds.",
  comment_standardisation = "none needed"

)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
