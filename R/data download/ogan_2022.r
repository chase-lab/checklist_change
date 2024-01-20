# ogan_2022
dataset_id <- "ogan_2022"

ddata <- readxl::read_xlsx(
   path = rdryad::dryad_download(dois = "10.5061/dryad.tqjq2bw1t")[[1]][1],
   sheet = 1L
)
data.table::setDT(ddata)

species_list <- grep(pattern = "[A-Z][a-z]{0,2}_[a-z]*$", x = colnames(ddata), value = TRUE)
selected_columns <- c(
   "dataset", "name_site", "year", "area", "Lat", "Long",
   species_list
)

ddata[, (species_list) := lapply(.SD, as.integer), .SDcols = species_list]

dir.create(path = "data/raw data/ogan_2022/", showWarnings = FALSE)
base::saveRDS(object = ddata[, ..selected_columns],
              file = "data/raw data/ogan_2022/rdata.rds"
)
