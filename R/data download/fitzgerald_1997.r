## fitzgerald_1997
dataset_id <- "fitzgerald_1997"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  if (FALSE) { # extracting species names from pictures
    lst <- list.files(paste0("./data/raw data/", dataset_id, "/OCR/"), full.names = TRUE)
    txt <- lapply(lst, tesseract::ocr, "eng")
    txt <- lapply(txt, strsplit, split = "\n")

    write.csv(
      data.frame(
        species = unlist(txt),
        local = c(
          rep("Laurel Creek", sum(sapply(1:2, function(i) length(txt[[i]][[1]])))),
          rep("Canagagigue Creek", sum(sapply(3:5, function(i) length(txt[[i]][[1]])))),
          rep("Caroll Creek", sum(sapply(6:7, function(i) length(txt[[i]][[1]]))))
        )
      ),
      paste0("./data/raw data/", dataset_id, "/species.csv"),
      row.names = FALSE
    )
  }

  check <- FALSE
  if (check) {
    rdata <- data.table::fread(paste0("./data/raw data/", dataset_id, "/rdata1.csv"), skip = 2)
    comm <- rdata[, ":="(species = NULL, regional = NULL)]
    total <- read.csv(paste0("./data/raw data/", dataset_id, "/rdata1.csv"), skip = 1, nrows = 1, h = F)[-(1:2)]
    colnames(comm)[!apply(comm, 2, sum, na.rm = T) == total]

    # The authors give a richness of 15 for Laurel D 76 but their shading shows 18. For 95 D, they write 11 but show 17. For 95 E, they write 21 but show 22.

    rdata <- data.table::fread(paste0("./data/raw data/", dataset_id, "/rdata2.csv"), skip = 2)
    comm <- rdata[, ":="(species = NULL, regional = NULL)]
    total <- read.csv(paste0("./data/raw data/", dataset_id, "/rdata2.csv"), skip = 1, nrows = 1, h = F, sep = ",")[-(1:2)]
    colnames(comm)[!apply(comm, 2, sum, na.rm = T) == total]

    # The authors give a richness of 18 for Canagagigue Creek B 66 but their shading shows 17.

    rdata <- data.table::fread(paste0("./data/raw data/", dataset_id, "/rdata3.csv"), skip = 2)
    comm <- rdata[, ":="(species = NULL, regional = NULL)]
    total <- read.csv(paste0("./data/raw data/", dataset_id, "/rdata3.csv"), skip = 1, nrows = 1, h = F, sep = ",")[-(1:2)]
    colnames(comm)[!apply(comm, 2, sum, na.rm = T) == total]
  }

  rdata1 <- data.table::fread(paste0("./data/raw data/", dataset_id, "/rdata1.csv"), skip = 2L)
  rdata2 <- data.table::fread(paste0("./data/raw data/", dataset_id, "/rdata2.csv"), skip = 2L)
  rdata3 <- data.table::fread(paste0("./data/raw data/", dataset_id, "/rdata3.csv"), skip = 2L)

  ddata <- list(rdata1, rdata2, rdata3)

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
