# Wrangle raw data

dir.create("data/wrangled data", showWarnings = FALSE)
for (i in list.files(path = "./R/data wrangling", full.names = TRUE)) {
   source(file = i, local = TRUE, echo = FALSE)
}
