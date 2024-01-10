# cowie_2003

dataset_id <- "cowie_2003"

ddata <- base::readRDS(paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(ddata, c("V1", "V4", "V5"), c("species", "1965", "1994"))

# excluding family names and unidentified species
ddata <- ddata[grepl(" ", species) & !grepl("sp\\.", species)]
ddata[, c("V2", "V3", "V6", "V7") := NULL]

# melting periods
ddata <- data.table::melt(ddata,
                          id.vars = "species",
                          value.name = "local",
                          variable.name = "year"
)

# splitting and melting sites
ddata[, paste0("tmp", 1:4) := data.table::tstrsplit(local, ", ")]

ddata <- data.table::melt(ddata,
                          id.vars = c("species", "year"),
                          value.name = "local",
                          measure.vars = paste0("tmp", 1:4)
)
ddata[, local := gsub(
   pattern = "[0-9]*$| |Not recorded|Nty [0-9]*|Nly [0-9]*|y|<",
   replacement = "", x = local)]
ddata <- ddata[!is.na(local) & local != ""]


ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Samoa",
   local = c("Upolu", "Savaii")[data.table::chmatch(local, c("U", "S"))],

   value = 1L,
   variable = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   latitude = c("13°35`S", "13°55`S")[data.table::chmatch(local, c("Savaii", "Upolu"))],
   longitude = c("172°25`W", "171°45`W")[data.table::chmatch(local, c("Savaii", "Upolu"))],

   effort = 1L,

   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "each station was sampled only once per period",
   sampling_years = c("1965", "1992-1994")[match(year, c("1965", "1994"))],

   alpha_grain = c(1694L, 1125L)[data.table::chmatch(local, c("Savaii", "Upolu"))],
   alpha_grain_unit = "km2",
   alpha_grain_type = "island",
   alpha_grain_comment = "area of the island",

   gamma_sum_grains = 2819L,
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "sum of the area of both sampled islands",

   comment = "Extracted from table 1 in Cowie et al 2003 - https://doi.org/10.1016/S0006-3207(02)00176-3. Pre-1965 data were excluded.
METHODS: 'Surveys were undertaken in 1992–1994 with the primary purpose of generating species inventories at each station as a means of evaluating overall species distributions. All sites identified as 'grade 1' by Park et al. (1992), that is, good quality, relatively undisturbed, low land rainforest, were sampled formally, as were a number of additional lowland and upland (above 450 m elevation) stations, resulting in 14 lowland and four upland stations on Savai‘i, eight lowland and four upland stations on ‘Upolu, and one station each on Nu‘utele and Nu‘ulua; a total of 32 formally sampled stations.' Here, only Savai‘i and 'Upolu were considered. Resurvey: 'At each formally sampled station, sampling took place at intervals along a transect line and was by hand collecting of specimens in the field, both from vegetation and from the litter.' Exact locations and gamma_bounding_box are unknown.
Regional is the archipelago, local are islands.",
   comment_standardisation = "Unidentified taxa and 'Not recorded' sites excluded",
   doi = 'https://doi.org/10.1016/S0006-3207(02)00176-3'
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
