## tirvengadum_1985
dataset_id <- "tirvengadum_1985"

if (FALSE) { # extracting species names from pictures
  lst <- list.files(paste0("data/raw data/", dataset_id, "/OCR/"), full.names = TRUE)
  txt <- lapply(lst, tesseract::ocr, "eng")
  txt <- lapply(txt, strsplit, split = "\n")

  write.csv(
    data.frame(species = unlist(txt)),
    paste0("data/raw data/", dataset_id, "/species.csv"),
    row.names = FALSE
  )
}
