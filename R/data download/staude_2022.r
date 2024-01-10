# staude_2022
dir.create(path = "data/raw data/staude_2022", showWarnings = FALSE)

suppdata::suppdata(
   x = "https://doi.org/10.6084/m9.figshare.12514172.v1",
   from = "figshare", si = 1, dir = "data/cache/",
   save.name = "staude_2022_raw_data.csv"
) |> # R pipe, R version > 4.1
   data.table::fread(
      sep = ",", header = TRUE
   ) |>
   base::saveRDS(file = "data/raw data/staude_2022/rdata.rds")

# years and coordinates are in supplementary 1 https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fele.13937&file=ele13937-sup-0001-Supinfo.pdf But correspondence between site names and site codes is not given.
