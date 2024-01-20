## corke_1992
dataset_id <- "corke_1992"

ddata <- data.table::fread(paste0("data/raw data/", dataset_id, "/rdata.csv"), skip = 1L, header = TRUE)
base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
