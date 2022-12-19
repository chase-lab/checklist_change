## becker-scarpitta_2018

dataset_id <- "becker-scarpitta_2018"

ddata <- data.table::as.data.table(
  readxl::read_xlsx(
    path = paste("data/raw data", dataset_id, "rdata.xlsx", sep = "/"),
    sheet = 1L, skip = 4L
  )
)

base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata_historical.rds", sep = "/"))
