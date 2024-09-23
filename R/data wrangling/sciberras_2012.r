## sciberras_2012
dataset_id <- "sciberras_2012"

ddata <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/rdata.csv"),
   skip = 2, drop = "check", header = TRUE, sep = ",")

## melting local sites
ddata <- data.table::melt(
   data = ddata,
   id.vars = "species",
   variable.name = "local",
   value.name = "period_temp",
   na.rm = TRUE
)

# melting periods
ddata[, period_temp := data.table::fcase(
   period_temp == "**", "recent",
   period_temp == "*?", "historical",
   default = "historical+recent"
)]
ddata[, c("temp1", "temp2") := data.table::tstrsplit(period_temp, split = "\\+")]

ddata <- data.table::melt(
   data = ddata,
   id.vars = c("species", "local"),
   measure.vars = c("temp1", "temp2"),
   value.name = "period",
   na.rm = TRUE
)


ddata[, ":="(
   dataset_id = dataset_id,
   regional = c(rep("Malta", 9), rep("Comino", 6), rep("Gozo", 8))[match(local, c(LETTERS[1:9], LETTERS[10:15], LETTERS[16:23]))],

   

   year = c(1930L, 1990L)[match(period, c("historical", "recent"))],
   period = NULL,
   variable = NULL
)]



# Metadata
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
env <- data.table::fread(
   file = "data/raw data/sciberras_2012/env.txt",
   sep = "\t", header = TRUE, skip = 1L, encoding = "UTF-8")
env[, ":="(latitude = parzer::parse_lat(latitude),
           longitude = parzer::parse_lon(longitude))]
env[, gamma_bounding_box := geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6]
env[, gamma_sum_grains := sum(area_m2), keyby = regional]

meta <- merge(meta, env)
data.table::setnames(meta, "area_m2", "alpha_grain")

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review for the historical communities, checklist for the recent communities",

   alpha_grain_unit = "m2",
   alpha_grain_type = "island",
   alpha_grain_comment = "area of the sampled islet measured in Google Earth",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "sum of the area of the sampled islets",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "Extracted from Sciberras et al 2012 table 1 (table extraction with tabula). The authors compiled historical inventories of plant composition of Maltese archipelago and updated checklists with more recent surveys Effort unspecified but islets were entirely explored and vegetation thoroughly checked. Historical and recent periods cover the 1930s and, 1990s and 2000s respectively.
Regional is the Maltese Archipelago, local are islets situated close to the shores of three main islands of the archipelago.
Full reference: SCIBERRAS, J., SCIBERRAS, A. & PISANI, L. (2012) Updated Checklist of Flora of the Satellite islets surrounding the Maltese Archipelago. Biodiversity Journal, 3 (4): 385-396",
   comment_standardisation = "none needed",

   source = NULL
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
