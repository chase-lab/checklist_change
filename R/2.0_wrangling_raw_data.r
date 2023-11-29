# Wrangle raw data

dir.create("data/wrangled data", showWarnings = FALSE)

for (script_path in list.files(path = "R/data wrangling", full.names = TRUE)) {
   unique_env <- new.env()
   base::source(file = script_path, local = unique_env, echo = FALSE)
}
