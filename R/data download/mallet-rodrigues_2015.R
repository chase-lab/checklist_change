# mallet-rodrigues_2015

if (!file.exists("./data/raw data/mallet-rodrigues_2015/rdata.rds")) {
  pdf_extraction <- lapply(
    tabulizer::extract_tables(
      file = "./data/cache/mallet-rodrigues_2015 AO188_39.pdf",
      pages = 8L:18L, method = "stream" # output = "data.frame" messes with colnames
    ),
    as.data.frame
  )

  dir.create("./data/raw data/mallet-rodrigues_2015", showWarnings = FALSE)
  base::saveRDS(pdf_extraction, "./data/raw data/mallet-rodrigues_2015/rdata.rds")
} else {
  pdf_extraction <- base::readRDS("./data/raw data/mallet-rodrigues_2015/rdata.rds")
}

for (i in seq_along(pdf_extraction)) {
  data.table::setDT(pdf_extraction[[i]])
  data.table::setnames(
    pdf_extraction[[i]],
    c(1, (ncol(pdf_extraction[[i]]) - 2L):ncol(pdf_extraction[[i]])),
    c("species", "Bocaina", "Itatiaia", "Orgaos")
  )
  pdf_extraction[[i]][, c("V3", "V4") := NULL]
}

ddata <- data.table::rbindlist(pdf_extraction, use.names = TRUE, fill = TRUE)

# Correcting data
ddata <- rbind(
  ddata,
  data.table::data.table(
    species = c("Egretta caerulea (Linnaeus, 1758)", "Chondrohierax uncinatus (Temminck, 1822)", "Elanoides forficatus (Linnaeus, 1758)", "Elanus leucurus (Vieillot, 1818)", "Phacellodomus ferrugineigula (Pelzeln, 1858)", "Estrilda astrild (Linnaeus, 1758)", "Passer domesticus (Linnaeus, 1758)"),
    Bocaina = c("0-50", "100", "0-400", NA, NA, "0-100", "0-100"),
    Itatiaia = c(NA, "2000", NA, "400-1,300", "600", "400", "400"),
    Orgaos = c(NA, "1000", NA, "1000", NA, "100-1,100", "100-1,100"),
    V2 = c(NA, NA, NA, "I", "E", "Int", "Int")
  )
)

base::saveRDS(ddata, "./data/raw data/mallet-rodrigues_2015/ddata.rds")
