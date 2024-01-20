# bruelheide_2020

if (!file.exists("data/raw data/bruelheide_2020/rdata.rds")) {
  dir.create("data/raw data/bruelheide_2020/", showWarnings = FALSE)
  base::saveRDS(
    object = data.table::fread(
      file = rdryad::dryad_download("10.5061/dryad.mw6m905vj")[[1]],
      header = TRUE,
      drop = c("Occ_change", "Year_subsequent_survey")
    ),
    file = "data/raw data/bruelheide_2020/rdata.rds"
  )
}
