# daga_2020

if (!file.exists("./data/raw data/daga_2020/rdata.rds")) {
  # downloading
  if (!file.exists("./data/cache/daga_2020_10750_2019_4145_MOESM1_ESM.docx")) {
    # suppdata::suppdata(x = "https://doi.org/10.1007/s10750-020-04307-w", si = 1)
    download.file(
      url = "https://static-content.springer.com/esm/art%3A10.1007%2Fs10750-019-04145-5/MediaObjects/10750_2019_4145_MOESM1_ESM.docx",
      destfile = "./data/cache/daga_2020_10750_2019_4145_MOESM1_ESM.docx",
      mode = "wb"
    )
  }

  # extracting from pdf and saving the extraction
  dir.create("./data/raw data/daga_2020/", showWarnings = FALSE)

  docx_document <- docxtractr::read_docx(path = "./data/cache/daga_2020_10750_2019_4145_MOESM1_ESM.docx")
  rdata <- docxtractr::docx_extract_tbl(docx = docx_document, tbl_number = 3L)
  env <- docxtractr::docx_extract_tbl(docx = docx_document, tbl_number = 1L)

  data.table::setDT(rdata)
  data.table::setDT(env)

  base::saveRDS(object = rdata, file = "./data/raw data/daga_2020/rdata.rds")
  base::saveRDS(object = env, file = "./data/raw data/daga_2020/env.rds")
}
