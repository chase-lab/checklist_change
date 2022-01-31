## peck_2012
dataset_id <- "peck_2012"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  # extracting text
  txt <- pdftools::pdf_text(paste0("./data/raw data/", dataset_id, "/peck_2012 - CDF_Checklist cockroaches, mantids.pdf"))
  txt <- txt[2:6]
  txt <- lapply(txt, gsub, pattern = "\\(|\\)", replacement = "")

  # extracting strings of interest
  species_names <- lapply(stringi::stri_extract_all_regex(txt, "(?<=\r\n[0-9]{1,3}\\. ).+(?=\r\n)|(?<=^[0-9]{1,3}\\. ).+(?=\r\n)"),
    gsub,
    pattern = " [A-Z].*$|ined.", replacement = ""
  )
  status <- stringi::stri_extract_all_regex(txt, "(?<=\r\n {1,15}Origin: ).*(?=.\r\n)")
  txtEOL <- lapply(tabulizer::extract_text(paste0("./data/raw data/", dataset_id, "/peck_2012 - CDF_Checklist cockroaches, mantids.pdf"), pages = 2:6, encoding = "UTF-8"),
    gsub,
    pattern = "\r\n", replacement = "_"
  )
  distribution <- lapply(stringi::stri_extract_all_regex(txtEOL, "(?<=Galapagos Distribution: ).*?(?=\\. *_)"),
    gsub,
    pattern = "_", replacement = " "
  )


  # cleaning
  status[[2]] <- c("Introduced, Accidental", status[[2]])

  # sum(sapply(species_names, length))
  # sum(sapply(status, length))
  # sum(sapply(distribution, length))

  ddata <- data.table::data.table(
    species = unlist(species_names),
    status = unlist(status),
    distribution = unlist(distribution)
  )

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
