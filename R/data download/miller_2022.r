# miller_2022

if (!file.exists("data/raw data/miller_2022/rdata.rds")) {
   ddata <- read.csv(
      file = unz(
         description = suppdata::suppdata(x = "https://doi.org/10.6084/m9.figshare.17009027", from = "figshare", dir = "data/cache/", save.name = "miller_2022_figshare_repo.zip", si = 1L, zip = TRUE),
         filename = "2_Species occurrence.csv", encoding = "UTF-8")
   )
   data.table::setDT(ddata)


   coords <- read.csv(
      file = unz(
         description = suppdata::suppdata(x = "https://doi.org/10.6084/m9.figshare.17009027", from = "figshare", dir = "data/cache/", save.name = "miller_2022_figshare_repo.zip", si = 1L, zip = TRUE),
         filename = "1_Location_Topography.csv", encoding = "UTF-8")
   )
   data.table::setDT(coords)

   # merging data.table style
   ddata <- ddata[coords[, .(PlotKey, Visit, Latitude, Longitude)], on = c("PlotKey","Visit")]


   dir.create(path = "data/raw data/miller_2022/", showWarnings = FALSE)
   base::saveRDS(object = ddata, file = "data/raw data/miller_2022/rdata.rds")
}
