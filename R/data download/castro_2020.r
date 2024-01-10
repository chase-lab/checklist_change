## castro_2020
dataset_id <- "castro_2020"

ddata <- readxl::read_xlsx(path = paste0("data/raw data/", dataset_id, "/pone.0238767.s003.xlsx"), sheet = 1L)
data.table::setDT(ddata)

base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
