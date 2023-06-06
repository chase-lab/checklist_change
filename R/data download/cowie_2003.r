## cowie_2003
dataset_id <- "cowie_2003"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  ddata <- data.table::rbindlist(
    lapply(
      tabulizer::extract_tables("./data/cache/Cowie and Robinson 2003 (data in Table).pdf", pages = 5:7),
      function(page) as.data.frame(page[-(1:3), ])
    )
  )
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
