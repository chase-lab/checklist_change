# Downloading gift data
if (!file.exists("./data/GIS data/giftdata.rds")) {
  base::saveRDS(
    object = data.table::fread(
      rdryad::dryad_download("10.5061/dryad.fv94v")[[1]][[2]],
      select = 1L:17L, sep = ",", header = TRUE, encoding = "UTF-8"
    ),
    file = "./data/GIS data/giftdata.rds"
  )
}
