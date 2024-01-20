## chiarucci_2017
dataset_id <- "chiarucci_2017"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  download.file(
    url = "https://static-content.springer.com/esm/art%3A10.1038%2Fs41598-017-05114-5/MediaObjects/41598_2017_5114_MOESM3_ESM.xls",
    destfile = "data/cache/41598_2017_5114_MOESM3_ESM.xls", mode = "wb"
  )

  ddata <- readxl::read_xls(path = "data/cache/41598_2017_5114_MOESM3_ESM.xls", sheet = 2L)
  data.table::setDT(ddata)

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
