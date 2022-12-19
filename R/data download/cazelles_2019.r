## cazelles_2019

if (!file.exists("./data/raw data/cazelles_2019/McCannLab-HomogenFishOntario-b08469d/data/sf_bsm_ahi.rda")) {
  download.file(
    url = "https://zenodo.org/record/3383237/files/McCannLab/HomogenFishOntario-v1.0.0.zip?download=1",
    destfile = "data/cache/McCannLab-HomogenFishOntario-b08469d.zip", mode = "wb"
  )

  dir.create("./data/raw data/cazelles_2019", showWarnings = FALSE)
  unzip(
    zipfile = "./data/cache/McCannLab-HomogenFishOntario-b08469d.zip",
    files = c("McCannLab-HomogenFishOntario-b08469d/data/sf_bsm_ahi.rda", "McCannLab-HomogenFishOntario-b08469d/data/df_species_info.rda"),
    exdir = "./data/raw data/cazelles_2019"
  )
}
