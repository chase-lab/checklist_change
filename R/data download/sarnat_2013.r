## sarnat_2013

# Community data. Extracted by hand from Appendix 3
rdata <- data.table::fread(file = "data/raw data/sarnat_2013/hand_extraction.csv", sep = ",", encoding = "UTF-8", skip = 0, header = TRUE)
## adding genus names
source("R/functions/extending_genus_names.r")
rdata[, genus := data.table::fifelse(grepl(" ", species), NA_character_, species)
      ][, genus := zoo::na.locf(genus)
        ][, species := extend_genus_names(species), by = genus
          ][, genus := NULL]

## deleting genus names
rdata <- rdata[grepl(" ", species)]

base::saveRDS(rdata, file = "data/raw data/sarnat_2013/rdata.rds")
