# Wrangle raw data

dir.create("data/wrangled data", showWarnings = FALSE)
lapply(X = list.files(path = "./R/data wrangling", full.names = TRUE), base::source, local = TRUE, echo = FALSE)
