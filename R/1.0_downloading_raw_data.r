# Downloading raw data
for (script_path in list.files(path = "./R/data download", full.names = TRUE)) {
   unique_env <- new.env()
   base::source(file = script_path, local = unique_env, echo = FALSE)
}
