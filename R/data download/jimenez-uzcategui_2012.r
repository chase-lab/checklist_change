## jimenez-uzcategui_2012
dataset_id <- "jimenez-uzcategui_2012"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  # extracting text
  txt <- pdftools::pdf_text(paste0("./data/raw data/", dataset_id, "/jimenez-uzcategui_2012_CDF_Checklist_of_Galapagos_Bird (data buried in descriptions).pdf")) # all text extraction should be based on tabulizer
  txt <- txt[1:26]
  # txt <- tabulizer::extract_text(paste0('./data/raw data/', dataset_id, '/jimenez-uzcategui_2012_CDF_Checklist_of_Galapagos_Bird (data buried in descriptions).pdf'), pages = 1:26, encoding = 'UTF-8')
  txt <- lapply(txt, gsub, pattern = "\\(|\\)", replacement = "")

  # extracting strings of interest
  # species_names <- lapply(stringi::stri_extract_all_regex(txt, '\r\n[0-9]+\\. *([a-zA-Z]-?’?)+\ ([a-zA-Z]-?’?)+\ ([a-zA-Z]-?’?)+, [0-9]{4}\r\n'), trimws)
  species_names <- lapply(
    stringi::stri_extract_all_regex(txt, "(?<=\r\n[0-9]{1,3}\\. ).+(?=, [0-9]{4}\r\n)"),
    function(x) trimws(gsub("[A-Za-z]+$", "", x))
  ) # should match one name with a capial name and then only names without capital letter
  status <- stringi::stri_extract_all_regex(txt, "(?<=\r\n {1,15}Origin: ).*(?=, [A-Za-z]*\\.\r\n)")
  txtEOL <- lapply(tabulizer::extract_text(paste0("./data/raw data/", dataset_id, "/jimenez-uzcategui_2012_CDF_Checklist_of_Galapagos_Bird (data buried in descriptions).pdf"), pages = 1:26, encoding = "UTF-8"),
    gsub,
    pattern = "\r\n", replacement = "_"
  )
  distribution <- lapply(stringi::stri_extract_all_regex(txtEOL, "(?<=_ {1,15}Galapagos Distribution: ).*?(?=\\. *_)"),
    gsub,
    pattern = "_", replacement = " "
  )

  ddata <- data.table::data.table(
    species = unlist(species_names),
    status = unlist(status),
    distribution = append(unlist(distribution)[-1], values = "Fernandina, Floreana, Isabela, San Cristóbal, Santa Cruz, Santa Fé, Santiago", 44)
  )

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
