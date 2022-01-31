# dataset_id <- "hamstead_2019"
#
# ddata <- readRDS(file = "./data/raw data/hamstead_2019/extracted_data.rds")
#
# data.table::setnames(ddata, c("species","East Fork_1988/TS","East Fork_1988/Q","East Fork_2010/TS","East Fork_2010/Q", "delete_me","delete_me"))
# ddata[, delete_me := NULL][, delete_me := NULL]
#
# # melting and splitting sites, year and method
# ddata[species == "", species := NA_character_][, species := c(NA_character_, zoo::na.locf(species))]
# ddata <- data.table::melt(ddata,
#                           id.vars = "species",
#                           variable.name = "site")
#
# ddata[, c("site", "year") := data.table::tstrsplit(site, "_")]
# ddata[, c("year", "method") := data.table::tstrsplit(year, "/")]
#
# ddata <- ddata[grepl(pattern = "n = ", x = value, fixed = TRUE)][, value := as.integer(gsub("n = ", "", value))]
#
# # standardisation: pooling both methods together
# ddata <- ddata[, .(value = sum(value)), by = .(species, site, year)]
#
#
#
#
# ddata[, ':='(
#    dataset_id = dataset_id,
#    regional = 'Pas de Calais, France',
#
#    metric = 'abundance',
#    unit = 'count',
#
#    
# )]
