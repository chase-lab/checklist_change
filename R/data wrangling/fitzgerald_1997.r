## fitzgerald_1997
dataset_id <- "fitzgerald_1997"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

ddata <- lapply(ddata, data.table::melt,
                id.vars = c("species", "regional"),
                measure.name = "value",
                variable.name = "temp"
)

for (i in 1:3) {
   ddata[[i]][, c("year", "local") := data.table::tstrsplit(temp, " ")]
}

ddata <- data.table::rbindlist(ddata)

ddata <- ddata[!is.na(value) & value > 0 & !is.na(species)]

ddata[, ":="(
   dataset_id = dataset_id,
   local = paste("Site ", local),

   year = as.integer(paste0("19", year)),

   temp = NULL
)]


meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Fish",
   realm = "Freshwater",

   latitude = c(43.645323, 43.578413, 43.480123)[match(regional, c("Carroll Creek", "Canagagigue Creek", "Laurel Creek"))],
   longitude = c(-80.459583, -80.502675, -80.586401)[match(regional, c("Carroll Creek", "Canagagigue Creek", "Laurel Creek"))],

   effort = "checklist",

   alpha_grain = 3L,
   alpha_grain_unit = "km2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "sampling by electrofishing or seine netting of essentially wadeable streams so 1km is a theoretical maximum and an average 3m river width is assumed.",

   gamma_bounding_box = 200L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "roughly estimated area of boxes covering the 3 small watersheds (they belong to a larger watershed of roughly 18 552 km2)",

   comment = "Extracted from Fitzgerald 1997 table 2 and 3 (species extracted by OCR with tesseract, pa entered by hand). The authors aggregated historical data from literature and recent data from their samples.
METHODS: 'Historical fish community descriptions were based on a variety of sources that included scientific papers, technical reports, university theses, and personal communications from recognized authorities. Recent fish community surveys are based on collections made during 1994 and 1995 within each of the three streams. Sampling stations were selected at a priori distances upstream and downstream of the various stream modifications'.
Regional is the river and local are stream sections. Effort is unknown.",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.1023/A:1009976923490"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
   row.names = FALSE
)
