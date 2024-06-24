# opedal_2020
dataset_id <- "opedal_2020"

if (!base::file.exists("data/cache/opedal_2020_zenodo_repository_ArchipelagoPlants-1.0.zip")) {
   curl::curl_download(
      url = "https://zenodo.org/record/3712825/files/oysteiop/ArchipelagoPlants-1.0.zip?download=1",
      destfile = "data/cache/opedal_2020_zenodo_repository_ArchipelagoPlants-1.0.zip",
      mode = "wb"
   )

   utils::unzip(zipfile = "data/cache/opedal_2020_zenodo_repository_ArchipelagoPlants-1.0.zip",
                exdir = paste0("data/cache/", dataset_id))
}

# 3 Using the table with colonisation and extinction columns
ddata <- data.table::data.table(
   data.table::fread(
      file = paste0("data/cache/", dataset_id, "/oysteiop-ArchipelagoPlants-ec4b1e9/colext_nospace/Y.csv")),
   local = data.table::fread(
      file = paste0("data/cache/", dataset_id, "/oysteiop-ArchipelagoPlants-ec4b1e9/colext_nospace/dfPi.csv"), select = 1L)
)

base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))

## Coordinates

crs <- sf::st_crs("+proj=tmerc +lat_0=0 +lon_0=21 +k=1 +x_0=1500000 +y_0=0 +ellps=intl +towgs84=-96.062,-82.428,-121.753,4.801,0.345,-1.376,1.496 +units=m +no_defs")

coords <- read.csv(file = paste0("data/cache/", dataset_id, "/oysteiop-ArchipelagoPlants-ec4b1e9/colext_nospace/xy.csv")) |>
   sf::st_as_sf(coords = c("X_manif", "Y_manif"),
                crs = crs) |>
   sf::st_transform(crs = sf::st_crs("+proj=longlat +datum=WGS84"))

data.table::setDT(coords)
coords[j = ":="(
   longitude = sf::st_coordinates(geometry)[, "X"],
   latitude = sf::st_coordinates(geometry)[, "Y"],
   geometry = NULL
   )]

env <- data.table::data.table(
   data.table::fread(
      file = paste0("data/cache/", dataset_id, "/oysteiop-ArchipelagoPlants-ec4b1e9/colext_nospace/dfPi.csv"), select = 1L),
   coords,
   data.table::fread(
      file = paste0("data/cache/", dataset_id, "/oysteiop-ArchipelagoPlants-ec4b1e9/colext_nospace/X.csv"),
      select = "area") |>
      base::exp()
)

base::saveRDS(object = env,
              file = paste("data/raw data", dataset_id, "env.rds", sep = "/"))

if (FALSE) {
   # 1 Historical occurrences
   ddata_hist <- data.table::fread(paste0("data/raw data/", dataset_id, "/histocc/Y.csv"))

   # 2 historical and modern occurrences together
   ddata_hm <- data.table::fread(paste0("data/raw data/", dataset_id, "/colext_nospace/oldnewY.csv"))
   ddata_hm[, ":="(
      local = rep(data.table::fread(paste0("data/raw data/", dataset_id, "/colext_nospace/dfPi.csv"))$V1, 2),
      period = rep(c("historical", "modern"), each = 471)
   )]

   ## Checking coherency with historical occurrences
   ddata_hist2 <- ddata_hm[period == "historical"]
   cols_chosen <- colnames(ddata_hist2)[!apply(ddata_hist2, 2, function(column) all(column == 0))]
   ddata_hist2 <- ddata_hist2[, ..cols_chosen]
   # There are 40 species more in ddata_hist2 than ddata_hist...
   cols_chosen <- !colnames(ddata_hist2) %in% c("local", "period")
   sum(ddata_hist2[, ..cols_chosen])
   # ddata_hist2 has as many records as there are historical records in ddata
}

