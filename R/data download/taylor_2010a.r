## taylor_2010a

dataset_id <- "taylor_2010a"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  download.file(
    url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fj.1472-4642.2010.00670.x&file=DDI_670_sm_AppendixS1.xls",
    destfile = "./data/cache/taylor_2010a_DDI_670_sm_AppendixS1.xls", mode = "wb"
  )
  ddata <- readxl::read_xls("./data/cache/taylor_2010a_DDI_670_sm_AppendixS1.xls", range = "2005all!A5:CI15")
  data.table::setDT(ddata)

  dir.create(paste("data/raw data", dataset_id, sep = "/"), showWarnings = FALSE)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
# path <- suppdata::suppdata(x = '10.1111/j.1472-4642.2010.00670.x',
#                             si = 1,
#                             from = 'wiley',
#                             dir = './data/cache',
#                             cache = TRUE)
