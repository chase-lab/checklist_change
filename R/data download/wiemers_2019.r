# wiemers_2019

if (!file.exists("data/raw data/wiemers_2019/ddata.rds")) {
  # downloading supplementary files
  path_to_S1 <- "data/cache/wiemers_2019_zookeys-081-009-s001.xlsx"
  if (!file.exists(path_to_S1)) {
    download.file(
      url = "https://zookeys.pensoft.net/article/28712/download/suppl/31/",
      destfile = path_to_S1,
      mode = "wb"
    )
  }

  path_to_S2 <- "data/cache/wiemers_2019_zookeys-081-009-s002.xls"
  if (!file.exists(path_to_S2)) {
    download.file(
      url = "https://zookeys.pensoft.net/article/28712/download/suppl/32/",
      destfile = path_to_S2,
      mode = "wb"
    )
  }

  # building ddata
  country_list <- unlist(
    readxl::read_xlsx(
      path = path_to_S1,
      range = "Checklist!B1:AU2"
    )
  )

  synonyms <- readxl::read_xls(
    path = path_to_S2,
    range = "AcceptedSpecies!A1:K497"
  )
  data.table::setDT(synonyms)

  ddata <- readxl::read_xls(
    path = path_to_S2,
    sheet = "Distribution"
  )
  data.table::setDT(ddata)


  ddata[, ":="(
    local = names(country_list)[match(DistributionElement, country_list)],
    species = paste(synonyms$Genus, synonyms$SpeciesEpithet)[match(AcceptedTaxonID, synonyms$AcceptedTaxonID)],

    AcceptedTaxonID = NULL,
    DistributionElement = NULL,
    StandardInUse = NULL
  )]
  ddata <- ddata[!DistributionStatus %in% c("Absent", "Migrant", "Uncertain")]


  dir.create("data/raw data/wiemers_2019", showWarnings = FALSE)
  base::saveRDS(ddata, "data/raw data/wiemers_2019/ddata.rds")
}
