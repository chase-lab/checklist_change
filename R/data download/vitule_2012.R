## vitule_2012

dataset_id <- "vitule_2012"
if (!file.exists(paste("data/raw data", dataset_id, "ddata_historical.rds", sep = "/"))) {
  download.file(
    url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fj.1472-4642.2011.00821.x&file=DDI_821_sm_AppS1.xls",
    destfile = "data/cache/vitule_2012_DDI_821_sm_AppS1.xls", mode = "wb"
  )
  ddata <- readxl::read_xls(path = "data/cache/vitule_2012_DDI_821_sm_AppS1.xls", sheet = 1, skip = 1)
  data.table::setDT(ddata)

  dir.create("data/raw data/vitule_2012", showWarnings = FALSE)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata_historical.rds", sep = "/"))
}
