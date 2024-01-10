## whillans_1979
dataset_id <- "whillans_1979"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  ex <- tabulizer::extract_tables(
    file = "data/cache/Whillans 1979 (data in various tables for 3 bays).pdf",
    pages = 10:11,
    method = "stream"
  )

  # Correcting species written on several lines
  ex[[1]][3, 6] <- "Salvelinus namaycush x fontinalis"
  ex[[1]][4, 6] <- ""

  ex[[2]][7, 1] <- "Coreogonus cylindraceum"
  ex[[2]][6, 3] <- "Moxostoma macrolepidum"
  ex[[2]][10, 3] <- "Etheostoma microperca"
  diag(ex[[2]][c(8, 7, 11), c(1, 3, 3)]) <- ""

  ex[[3]][10, 1] <- "Moxostoma macrolepidum"
  ex[[3]][10, 6] <- "Percopsis omiscomaycus"
  ex[[3]][11, c(1, 6)] <- ""

  # Deleting extra rows and columns
  ex[c(1, 3)] <- lapply(ex[c(1, 3)], function(x) x[-(1:2), -c(2, 4, 5, 7)])
  ex[[2]] <- ex[[2]][-(1:3), -4]

  ex[[2]] <- apply(ex[[2]], 2, function(x) trimws(gsub("[0-9]", "", x)))

  ddata <- data.table::rbindlist(lapply(ex, as.data.frame), idcol = TRUE)

  colnames(ddata) <- c("local", "historical", "all", "contemporary")

  dir.create(paste("data/raw data", dataset_id, sep = "/"), showWarnings = FALSE)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
