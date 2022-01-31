## jimenez-uzcategui_2014
dataset_id <- "jimenez-uzcategui_2014"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  # extracting text
  txt <- pdftools::pdf_text(paste0("./data/raw data/", dataset_id, "/jimenez-uzcategui_2014 - 2014Jan24_Jimenez-Uzcategui_et_al_Galapagos_Mammalia_Checklist.pdf")) # all text extraction should be based on tabulizer
  txt <- txt[3:15]
  # txt <- tabulizer::extract_text(paste0('./data/raw data/', dataset_id, '/jimenez-uzcategui_2014 - 2014Jan24_Jimenez-Uzcategui_et_al_Galapagos_Mammalia_Checklist.pdf'), pages = 1:26, encoding = 'UTF-8')
  txt <- lapply(txt, gsub, pattern = "\\(|\\)", replacement = "")

  # extracting strings of interest
  species_names <- lapply(stringi::stri_extract_all_regex(txt, "(?<=\r\n[0-9]{1,3}\\. ).+(?=\r\n)|(?<=^[0-9]{1,3}\\. ).+(?=\r\n)"),
    gsub,
    pattern = " [A-Z].*$|ined.", replacement = ""
  )
  status <- stringi::stri_extract_all_regex(txt, "(?<=\r\n {1,15}Origin: ).*(?=, [A-Za-z]*\\.\r\n)")
  distribution <- stringi::stri_extract_all_regex(txt, "(?<= {1,15}Galapagos Distribution: ).*?(?=\\. *)")

  # cleaning strings
  species_names[[13]] <- NULL

  distribution[[5]] <- append(distribution[[5]], "Española, Floreana, Isabela, Marchena, Pinta, San Cristóbal, Santa Cruz, Santa Fé, Santiago", 1)
  distribution[[11]] <- append(distribution[[11]], "Fernandina, Floreana, Isabela, Marchena, Pinzón, San Cristóbal, Santa Cruz, Santiago", 2)
  distribution[[12]] <- c(distribution[[12]], "Española, Fernandina, Floreana, Isabela, Pinta, San Cristóbal, Santa Cruz, Santa Fé, Santiago")

  ddata <- data.table::data.table(
    species = unlist(species_names),
    status = unlist(status),
    distribution = unlist(distribution)
  )

  ddata[species %in% c("Aegialomys galapagoensis", "Megaoryzomys curioi", "Megaoryzomys sp. 1", "Nesoryzomys darwini", "Nesoryzomys indefessus", "Nesoryzomys sp. 1", "Nesoryzomys sp. 2", "Nesoryzomys sp. 3"), status := "NativeExtinct"]


  # Excluding marine mammals:
  ddata <- ddata[!species %in% c("Balaenoptera acutorostrata", "Balaenoptera borealis", "Balaenoptera edeni", "Balaenoptera musculus", "Balaenoptera physalus", "Delphinus delphis", "Feresa attenuata", "Globicephala macrorhynchus", "Grampus griseus", "Hyperoodon planifrons", "Indopacetus pacificus", "Kogia breviceps", "Kogia sima", "Lagenodelphis hosei", "Megaptera novaeangliae", "Mesoplodon densirostris", "Mesoplodon ginkgodens", "Mesoplodon peruvianus", "Orcinus orca", "Peponocephala electra", "Physeter macrocephalus", "Pseudorca crassidens", "Stenella coeruleoalba", "Stenella longirostris", "Steno bredanensis", "Tursiops truncatus", "Ziphius cavirostris")]

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
