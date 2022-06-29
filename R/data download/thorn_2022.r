# thorn_2022
dataset_id <- "thorn_2022"

if (!file.exists("./data/raw data/thorn_2022/rdata.rds")) {
   # suppdata::suppdata(x = "10.6084/m9.figshare.19697279.v1", from = "figshare", si = 1, dir = "./data/cache", save.name = "rsbl20220055_si_002.csv") # rsbl20220055_si_002.csv
   if (!file.exists("./data/cache/rsbl20220055_si_002.csv")) download.file(
      url = "https://rs.figshare.com/ndownloader/files/34985258",
      destfile = "./data/cache/rsbl20220055_si_002.csv"
   )

   dir.create("./data/raw data/thorn_2022", showWarnings = FALSE)
   base::saveRDS(
      object = data.table::fread(file = "./data/cache/rsbl20220055_si_002.csv"),
      file = "./data/raw data/thorn_2022/rdata.rds"
   )
}
