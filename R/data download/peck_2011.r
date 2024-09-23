## peck_2011
dataset_id <- "peck_2011"

   # extracting text
   txt <- pdftools::pdf_text(paste0("data/raw data/", dataset_id, "/peck_2011 - CDF_Checklist cockroaches, mantids.pdf"))
   txt <- txt[2:5]
   txt <- lapply(txt, base::gsub, pattern = "\\(|\\)", replacement = "")

   # extracting strings of interest
   species_names <- stringi::stri_extract_all_regex(
      str = txt,
      pattern = "(?<=\n {3}[0-9]{1,3}\\. {2}).+(?=\n)|(?<=^[0-9]{1,3}\\. ).+(?=\n)") |>
      lapply(FUN = base::trimws) |>
      lapply(FUN = base::gsub, pattern = " [A-Z].*$", replacement = "")

   status <- stringi::stri_extract_all_regex(txt, "(?<=Origin: ).*(?=.\n)")

   distribution <- stringi::stri_extract_all_regex(
      str = txt,
      pattern = "(?<=Galapagos Distribution: ).*(?=\\.\n)")

   # cleaning
   status[[3]] <- status[[3]] |>
      base::append(NA_character_, 3L) |>
      base::append(rep(NA_character_, 2L), 5L)

   status[[4]] <- c(NA_character_, status[[4]])

   distribution[[1L]] <- distribution[[1L]] |>
      base::append(
         values = "Fernandina, Floreana, Isabela, San Cristóbal, Santa Cruz, Santiago, Unknown",
         after = 3L)
   distribution[[2L]] <- distribution[[2L]] |>
      base::append(
         values = "Española, Fernandina, Floreana, Genovesa, Isabela, Marchena, Pinta, San Cristóbal, Santa Cruz, Santiago, Unknown",
         after = 5L)


   # sum(sapply(species_names, length))
   # sum(sapply(status, length))
   # sum(sapply(distribution, length))

   ddata <- data.table::data.table(
      species = unlist(species_names),
      status = unlist(status),
      distribution = unlist(distribution)
   )

   base::saveRDS(object = ddata,
                 file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
