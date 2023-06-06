# lindholm_2019

if (!file.exists("./data/raw data/lindholm_2019/ddata.rds")) {
  dir.create("./data/raw data/lindholm_2019")
  base::saveRDS(
    object = data.table::fread(
      rdryad::dryad_download(dois = "10.5061/dryad.t1g1jwsxv")[[1]][2],
      header = TRUE, sep = ";"
    ),
    file = "./data/raw data/lindholm_2019/ddata.rds"
  )

  base::saveRDS(
    object = read.table(rdryad::dryad_download(dois = "10.5061/dryad.t1g1jwsxv")[[1]][3],
      header = TRUE, skip = 46, nrows = 66, encoding = "latin-1", sep = "\t"
    ),
    file = "./data/raw data/lindholm_2019/specieslong.rds"
  )

  base::saveRDS(
    object = data.table::fread(
      file = rdryad::dryad_download(dois = "10.5061/dryad.t1g1jwsxv")[[1]][1],
      header = TRUE, dec = ","
    ),
    file = "./data/raw data/lindholm_2019/env.rds"
  )
}
