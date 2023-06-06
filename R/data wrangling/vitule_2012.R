## vitule_2012


dataset_id <- "vitule_2012"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata_historical.rds"))

data.table::setnames(
  ddata, c("Species"),
  c("species")
)

ddata <- data.table::melt(ddata,
  id.vars = c("species"),
  measure.vars = 2:8,
  measure.name = "value",
  variable.name = "local",
  na.rm = TRUE
)
ddata <- ddata[value > 0 & !is.na(species)]

ddata <- ddata[local %in% c("LBTI", "LATI", "UBIJ", "UATI")]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Parana river basin",

  local = data.table::fifelse(grepl("L", local), "Lower Parana", "Upper Parana"),
  year = data.table::fifelse(grepl("B", local), 1980L, 2000L),

  value = 1L
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Fish",
  realm = "Freshwater",

  latitude = data.table::fifelse(grepl("L", local), "30°37'44.43 S", "21°31'21.68 S"),
  longitude = data.table::fifelse(grepl("L", local), "59°40'12.54 W", "51°43'59.78 W"),

  effort = 1L,

  alpha_grain = data.table::fifelse(grepl("L", local), 1700000L, 900000L),
  alpha_grain_unit = "km2",
  alpha_grain_type = "watershed",
  alpha_grain_comment = "area of upper and lower parana given by the authors",

  gamma_sum_grains = 2600000L,
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "watershed",
  gamma_sum_grains_comment = "sum of both local watersheds",

  comment = "Extracted from Vitule et al 2012 Supplementary (https://doi.org/10.1111/j.1472-4642.2011.00821.x). Fish composition of the different regions and periods were compiled from various literature resources. Regional is the Parana River basin, local are large river stretches upper and lower a natural barrier (falls) that was flooded after a dam construction, and then not a barrier any more allowing fish fauna homogenization. The dam was finished in 1982 hence allowing homogenisation over the falls. For Upper Parana River basin community before introduction, data by Julio et al 2009 was used.",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.1111/j.1472-4642.2011.00821.x'
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
