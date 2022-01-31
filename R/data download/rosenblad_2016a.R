## rosenblad_2016a
dataset_id <- "rosenblad_2016a"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  ddata <- readxl::read_xlsx(rdryad::dryad_download("10.5061/dryad.c9s61")[[1]], sheet = "Plants")
  data.table::setDT(ddata)

  dir.create(paste0("data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
