## vernon_2013
dataset_id <- "vernon_2013"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  # extracting text
  txt <- pdftools::pdf_text("data/cache/vernon_2013_raw_data.pdf")
  txt <- txt[32:50]

  # extracting strings of interest
  species_names <- lapply(stringi::stri_extract_all_regex(txt, "\r\n\ *([a-zA-Z]-?’?)+\ ([a-zA-Z]-?’?)+\ "), trimws)
  status <- lapply(stringi::stri_extract_all_regex(txt, "\ *E\r\n\ *|\ *I\r\n\ *|\ *NZ\r\n\ *"), trimws)
  distribution <- lapply(stringi::stri_extract_all_regex(txt, "Distribution: ([A-Z]{1}[a-z]?.?)*\ *\r\n"), gsub, replacement = "", pattern = "Distribution: |\r\n")
  distribution <- lapply(stringi::stri_extract_all_regex(txt, "Distribution: .*\ *\r\n"), gsub, replacement = "", pattern = "Distribution: |\r\n")

  # Cleaning
  species_names[[1]] <- species_names[[1]][-(1:2)]
  status[[1]] <- status[[1]][-1]

  species_names[[2]][c(1:4, 10)] <- c("Lycopodium venustulum venustulum", "Lycopodium venustulum verticale", "Isoetes hawaiiensis", "Selaginella arbuscula", "Ophioderma pendulum falcatum")
  species_names[[2]] <- c(species_names[[2]], "Ophioderma pendulum pendulum")

  status[[4]] <- append(status[[4]], NA, 7)

  species_names[[6]][c(5, 7)] <- c("Hypolepis hawaiiensis hawaiiensis", "Microlepia strigosa mauiensis")
  species_names[[6]] <- append(species_names[[6]], "Hypolepis hawaiiensis mauiensis", 5)
  species_names[[6]] <- append(species_names[[6]], "Microlepia strigosa strigosa", 8)
  status[[6]] <- c(status[[6]][-5], "I", "E")

  species_names[[7]] <- c("Adiantum ‘Edwinii’", species_names[[7]])

  species_names[[9]][4] <- "Asplenium contiguum contiguum"
  species_names[[9]] <- append(species_names[[9]], "Asplenium contiguum hirtulum", 5)

  status[[10]] <- append(status[[10]], NA, 6)

  species_names[[14]][c(2:4)] <- c("Dryopteris crinalis crinalis", "Dryopteris fuscoatra fuscoatra", "Dryopteris glabra alboviridis")
  species_names[[14]] <- append(species_names[[14]], "Dryopteris crinalis podorosa", 2)
  species_names[[14]] <- append(species_names[[14]], "Dryopteris fuscoatra lamoureuxii", 5)
  species_names[[14]] <- append(species_names[[14]], c("Dryopteris glabra flynii", "Dryopteris glabra glabra", "Dryopteris glabra hobdyana", "Dryopteris glabra nuda", "Dryopteris glabra pusilla", "Dryopteris glabra soripes"), 6)

  species_names[[15]][5] <- "Dryopteris unidentata palaecea"
  species_names[[15]] <- append(species_names[[15]], "Dryopteris unidentata unidentata", 5)

  species_names[[16]] <- species_names[[16]][-1]

  species_names[[17]][7:8] <- c("Adenophorus pinnatifidus pinnatifidus", "Adenophorus tamariscinus montanus")
  species_names[[17]] <- append(species_names[[17]], "Adenophorus pinnatifidus rockii", 7)
  species_names[[17]] <- append(species_names[[17]], "Adenophorus tamariscinus tamariscinus", 9)
  species_names[[17]] <- species_names[[17]][-length(species_names[[17]])]

  species_names[[18]] <- species_names[[18]][-4]
  species_names[[18]] <- c("Microsorum spectrum pentadactylum", "Microsorum spectrum spectrum", species_names[[18]])
  species_names[[18]][length(species_names[[18]])] <- "Polypodium pellucidum acuminatum"
  species_names[[19]] <- c("Polypodium pellucidum pellucidum", "Polypodium pellucidum vulcanicum", species_names[[19]])

  # data.frame(species = sapply(species_names, length), status = sapply(status, length), distribution = sapply(species_names, length))
  # apply(data.frame(species = sapply(species_names, length), status = sapply(status, length), distribution = sapply(distribution, length)), 2, sum)

  ddata <- data.table::data.table(status = unlist(status), species = unlist(species_names), distribution = unlist(distribution))

  dir.create(paste0("data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))

  turn_into_subsp <- function(x, species, subsp) {
    species_position <- which(x == species)
    x[species_position] <- paste(species, subsp[1])
    for (i in 2:length(subsp)) x <- append(x, paste(species, subsp[i]), species_position)
    return(x)
  }
}
