## vernon_2013
dataset_id <- "vernon_2013"

# extracting text
txt <- pdftools::pdf_text("data/raw data/vernon_2013/vernon_2013_raw_data.pdf")[32:50]

# extracting strings of interest

species_names <- stringi::stri_extract_all_regex(
   str = txt,
   pattern = "(?<=1\n|E\n|I\n|NZ\n) *[A-Za-z` .()&\\-,]*(?=\n)|(?<=\n) *[A-Za-z .()&\\-,]*(?=var.)|(?<=\n) *[A-Za-z .()&\\-,]*(?=subsp.)") |>
   lapply(FUN = trimws) |>
   lapply(FUN = function(x) ifelse(nchar(x) > 3L, x, NA_character_)) |>
   # delete Synonyms
   lapply(FUN = function(x) ifelse(!grepl("^Syn. ", x), x, NA_character_)) |>
   lapply(na.omit)
# 2 6 10 16
species_names[[2]] <- append(x = species_names[[2]],
                             values = "Isoëtes hawaiiensis W. C. Taylor & W. H. Wagner",
                             after = 2L)
species_names[[2]] <- append(x = species_names[[2]],
                             values = "Ophioderma pendulum (L.) C. Presl",
                             after = 9L)
species_names[[4]] <- append(x = species_names[[4]],
                             values = "Dicranopteris linearis (Burm. f.) Underw.",
                             after = 7L)
species_names[[6]] <- append(x = species_names[[6]],
                             values = "Lindsaea repens (Bory) Thwaites",
                             after = 2L)
species_names[[6]] <- append(x = species_names[[6]],
                             values = "Hypolepis hawaiiensis Brownsey",
                             after = 5L)
species_names[[6]] <- append(x = species_names[[6]],
                             values = "Microlepia strigosa (Thunb.) C. Presl",
                             after = 9L)
species_names[[6]] <- append(x = species_names[[6]],
                             values = "Pteridium aquilinum (L.) Kuhn",
                             after = 11L)
species_names[[7L]] <- c("Adiantum ‘Edwinii’", species_names[[7L]])
species_names[[9L]] <- append(x = species_names[[9L]],
                              values = "Asplenium contiguum Kaulf.",
                              after = 3L)
species_names[[10L]] <- append(x = species_names[[10L]],
                               values = "Asplenium nidus L.",
                               after = 5L)
species_names[[10L]] <- append(x = species_names[[10L]],
                               values = "Asplenium peruvianum Desv.",
                               after = 7L)
species_names[[10L]] <- append(x = species_names[[10L]],
                               values = "Asplenium trichomanes L.",
                               after = 12L)
species_names[[11L]] <- append(x = species_names[[11L]],
                               values = "Cyclosorus interruptus (Willd.) H. Itô",
                               after = 5L)
species_names[[14L]] <- append(x = species_names[[14L]],
                               values = "Dryopteris crinalis (Hook. & Arn.) C. Chr.",
                               after = 1L)
species_names[[14L]] <- append(x = species_names[[14L]],
                               values = "Dryopteris fuscoatra (Hillebr.) W. J. Rob.",
                               after = 4L)
species_names[[14L]] <- append(x = species_names[[14L]],
                               values = "Dryopteris glabra (Brack.) Kuntze",
                               after = 7L)
species_names[[15L]] <- append(x = species_names[[15L]],
                               values = "Dryopteris unidentata (Hook. & Arn.) C. Chr.",
                               after = 4L)
species_names[[16L]] <- append(x = species_names[[16L]],
                               values = c("Nephrolepis falcata (Cav.) C. Chr. ‘Furcans’",
                                          "Nephrolepis hirsutula (G. Forst.) C. Presl ‘Superba’"),
                               after = 7L)
species_names[[17L]] <- append(x = species_names[[17L]],
                               values = "Adenophorus pinnatifidus Gaudich.",
                               after = 6L)
species_names[[17L]] <- append(x = species_names[[17L]],
                               values = "Adenophorus tamariscinus (Kaulf.) Hook. & Grev.",
                               after = 9L)
species_names[[17L]] <- append(x = species_names[[17L]],
                               values = "Microsorum spectrum (Kaulf.) Copel.")
species_names[[18L]] <- append(x = species_names[[18L]],
                               values = "Polypodium pellucidum Kaulf.",
                               after = 10L)

# Adding species names to variants and deleting species names with variants but without status
species_names <- data.table::as.data.table(unlist(species_names))
species_names[i = !grepl("^var.|^subsp.", x = species_names$V1),
              j = species_name := V1][
                 j = species_name := zoo::na.locf(species_name)
              ]
# For repeated species_names, paste species+var for 2nd to last (the first is species only)
species_names[i = species_names[i = species_names[j = .N,
                                                  by = species_name][N > 1L],
                                on = .(species_name),
                                j = .SD[2L:.N],
                                .SDcols = c("V1", "species_name"),
                                by = .(species_name)][
                                   j = .(V1, species_name = paste(species_name, V1))
                                ],
              on = .(V1),
              j = species := i.species_name]

species_names[i = species_names[j = .N,
                                by = species_name][N == 1L],
              on = .(species_name),
              j = species := species_name]

species_names <- na.omit(species_names$species)

status <- stringi::stri_extract_all_regex(str = txt,
                                          pattern = "\ *E\n\ *|\ *I\n\ *|\ *NZ\n\ *") |>
   unlist() |>
   trimws()
status <- status[-1L]
# status[[1L]] <- status[[1L]][-1L]
status <- append(status, values = NA_character_, after = 39L)
status <- append(status, values = "I", after = 58L)
status <- append(status, values = NA_character_, after = 108L)

distribution <- stringi::stri_extract_all_regex(txt, "(?<=Distribution: ).*(?=\n)") |>
   unlist()

ddata <- data.table::data.table(
   status = status,
   species = species_names,
   distribution = distribution)

dir.create(paste0("data/raw data/", dataset_id), showWarnings = FALSE)
base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
