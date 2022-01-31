dataset_id <- "wiles_2005"
# raw data is the pdf article, extractions are stored in ./data/cache/wiles_2005
dir.create("./data/raw data/wiles_2005", showWarnings = FALSE)

if (!file.exists(paste0("./data/raw data/", dataset_id, "/birds_raw.rds"))) {
  birds_raw <- tabulizer::extract_tables(file = "./data/cache/wiles_2005 - Micronesia birds (data in appendix; do not include marine birds).pdf", pages = 35:46, encoding = "UTF-8")
  base::saveRDS(birds_raw, file = paste0("./data/raw data/", dataset_id, "/birds_raw.rds"))
}

if (!file.exists(paste0("./data/raw data/", dataset_id, "/mammals_raw.rds"))) {
  mammals_raw <- tabulizer::extract_tables(file = "./data/cache/wiles_2005 - Micronesia birds (data in appendix; do not include marine birds).pdf", pages = 47:49, encoding = "UTF-8")
  base::saveRDS(mammals_raw, file = paste0("./data/raw data/", dataset_id, "/mammals_raw.rds"))
}
