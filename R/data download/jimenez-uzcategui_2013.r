## jimenez-uzcategui_2013
dataset_id <- "jimenez-uzcategui_2013"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  # extracting text
  txt <- pdftools::pdf_text(paste0("data/raw data/", dataset_id, "/jimenez-uzcategui_2013 - CDF_Checklist_of_Galapagos_Reptiles (data buried in descriptions).pdf")) # all text extraction should be based on tabulizer
  txt <- txt[2:15]
  # txt <- tabulizer::extract_text(paste0('data/raw data/', dataset_id, '/jimenez-uzcategui_2013 - CDF_Checklist_of_Galapagos_Reptiles (data buried in descriptions).pdf'), pages = 1:26, encoding = 'UTF-8')
  txt <- lapply(txt, gsub, pattern = "\\(|\\)", replacement = "")

  # extracting strings of interest
  # species_names <- lapply(stringi::stri_extract_all_regex(txt, '\r\n[0-9]+\\. *([a-zA-Z]-?’?)+\ ([a-zA-Z]-?’?)+\ ([a-zA-Z]-?’?)+, [0-9]{4}\r\n'), trimws)
  species_names <- lapply(stringi::stri_extract_all_regex(txt, "(?<=\r\n[0-9]{1,3}\\. ).+(?=\r\n)"),
    gsub,
    pattern = " [A-Z].*$|ined.", replacement = ""
  ) # can be improved by using the alternative in j-u_2014
  status <- stringi::stri_extract_all_regex(txt, "(?<=\r\n {1,15}Origin: ).*(?=, [A-Za-z]*\\.\r\n)")
  distribution <- stringi::stri_extract_all_regex(txt, "(?<= {1,15}Galapagos Distribution: ).*?(?=\\. *)")

  # cleaning strings
  species_names[[5]] <- c("Chelonoidis hoodensis", species_names[[5]])
  species_names[[8]] <- c("Chelonoidis vicina", species_names[[8]])
  species_names[[9]] <- c("Conolophus sp. 1", species_names[[9]])
  species_names[[11]] <- c("Microlophus delanonis", species_names[[11]])
  species_names[[14]] <- species_names[[14]][-4]

  status[[14]] <- c("Introduced", status[[14]])

  distribution[[1]] <- c(distribution[[1]], "Española, Fernandina, Floreana, Isabela, Marchena, San Cristóbal, Santa Cruz, Santa Fé, Santiago")
  distribution[[2]] <- append(distribution[[2]], "Española, Fernandina, Floreana, Genovesa, Isabela, San Cristóbal, Santa Cruz, Santiago", 3)

  ddata <- data.table::data.table(
    species = unlist(species_names),
    status = unlist(status),
    distribution = unlist(distribution)
  )

  # extinction status
  ddata[species %in% c("Chelonoidis abingdoni", "Chelonoidis nigra", "Chelonoidis phantastica", "Chelonoidis sp. 1", "Chelonoidis wallacei", "Conolophus sp. 1", "Phyllodactylus sp. 1"), status := "NativeExtinct"]

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
