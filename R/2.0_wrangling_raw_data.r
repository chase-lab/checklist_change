# Wrangle raw data

dir.create("data/wrangled data", showWarnings = FALSE)
lapply(X = list.files(path = "./R/data wrangling", full.names = TRUE), base::source, local = TRUE, echo = FALSE)
# parallel::mclapply(list.files(path = "./R/data wrangling", full.names = TRUE), base::source, local = TRUE, echo = FALSE) # fread and fwrite are parallelized already, maybe that slows things down well several sessions are running at once
