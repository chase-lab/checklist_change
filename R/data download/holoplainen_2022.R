# holoplainen_2022

if (!file.exists("data/raw data/holoplainen_2022/rdata.rds")) {
   if (!file.exists("data/cache/holoplainen_2022_dataS1.zip")) {
      download.file(
         url = "https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.3962&file=ecy3962-sup-0001-dataS1.zip",
         destfile = "data/cache/holoplainen_2022_dataS1.zip",
         mode = "wb")
   }

   utils::unzip(
      zipfile = "data/cache/holoplainen_2022_dataS1.zip",
      files = "FIN Pheno Plant.txt", exdir = "data/cache/holoplainen_2022")

   base::dir.create("data/raw data/holoplainen_2022", showWarnings = FALSE)

   base::saveRDS(
      object = unique(data.table::fread(file = "data/cache/holoplainen_2022/FIN Pheno Plant.txt",
                                 sep = "\t", dec = ".", na.strings = "n/a",
                                 stringsAsFactors = TRUE, encoding = "Latin-1",
                                 select = c("Year","Date","Lat","Long","Site","Species"))),
      file = "data/raw data/holoplainen_2022/rdata.rds")
}
