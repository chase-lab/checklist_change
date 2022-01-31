## economo_2017
dataset_id <- "economo_2017"

if (!file.exists(file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  ddata <- readxl::read_xlsx(path = rdryad::dryad_download("10.5061/dryad.2f7b2")[[1]][1], skip = 2L)
  data.table::setDT(ddata)

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
