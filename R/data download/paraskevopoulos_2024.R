# paraskevopoulos_2024
if (!file.exists("data/raw data/paraskevopoulos_2024/rdata.rds")) {
   # rdryad::dryad_download(dois = "10.5061/dryad.2fqz612x4")
   if (!file.exists("data/cache/paraskevopoulos_2024_Gregory_Canyon_Ant_Data.csv")) {
      curl::curl_download(url = "https://datadryad.org/stash/downloads/file_stream/2934832",
                          destfile = "data/cache/paraskevopoulos_2024_Gregory_Canyon_Ant_Data.csv")
      curl::curl_download(url = "https://datadryad.org/stash/downloads/file_stream/2934835",
                          destfile = "data/cache/paraskevopoulos_2024_readme.md")
   }

   base::dir.create(path = "data/raw data/paraskevopoulos_2024", showWarnings = FALSE)
   base::saveRDS(
      object = data.table::fread(
         file = "data/cache/paraskevopoulos_2024_Gregory_Canyon_Ant_Data.csv",
         drop = c("Project","Date","DOY","Time","Aspect Initials","Aspect","Timeframe",
                  "Elevation (m)", "Air Temp.","Surface Temp.","Collection method",
                  "Surface Forager?", "Genus","Sp.","Occurrence")),
      file = "data/raw data/paraskevopoulos_2024/rdata.rds")
}
