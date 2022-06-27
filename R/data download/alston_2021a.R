dataset_id <- "alston_2021a"

if (!file.exists("./data/raw data/alston_2021a/rdata.rds")) {
   # loading data
   dt <- data.table::fread(file = rdryad::dryad_download("10.5061/dryad.1g1jwstxw")[[1L]][8L],
                           drop = 9L:15L)

   dir.create("./data/raw data/alston_2021a", showWarnings = FALSE)
   saveRDS(dt, "./data/raw data/alston_2021a/rdata.rds")
}
