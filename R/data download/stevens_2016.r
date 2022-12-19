## stevens_2016

dataset_id <- "stevens_2016"
if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  download.file(
    url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Favsc.12206&file=avsc12206-sup-0002-AppendixS1.csv",
    destfile = "./data/cache/stevens_2016_avsc12206-sup-0002-AppendixS1.csv"
  )

  dir.create(paste0("data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(
    object = data.table::fread(
      file = "./data/cache/stevens_2016_avsc12206-sup-0002-AppendixS1.csv",
      skip = 1, header = TRUE, select = 1L:4L
    ),
    file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/")
  )
}
