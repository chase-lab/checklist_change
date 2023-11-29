## carlson_2004


dataset_id <- "carlson_2004"

ddata <- data.table::fread(paste0("data/raw data/", dataset_id, "/rdata.csv"), skip = 1, drop = "V21")

# melting sites
ddata <- data.table::melt(ddata,
  id.vars = c("species"),
  value.name = "value",
  variable.name = "local"
)
ddata <- ddata[!is.na(value) & value > 0 & !is.na(species)]

# melting 123 values
ddata[, value := gsub(" |m|,", "", value)]
ddata[, paste0("Temp", 1:3) := data.table::tstrsplit(value, "")]
ddata <- data.table::melt(ddata,
  id.vars = c("local", "species"),
  measure.vars = paste0("Temp", 1:3),
  value.name = "period",
  variable.name = "Temp",
  na.rm = TRUE
)


ddata[, ":="(
  dataset_id = dataset_id,
  regional = "New-York state",
  year = c(1940L, 1987L, 2004L)[match(period, c("1", "2", "3"))],

  value = 1L,

  period = NULL,
  Temp = NULL
)]

env <- data.frame(
  local = c("Allegheny", "Chemung", "Susquehanna", "Delaware", "Erie-Niagara", "Genesee", "Lake Ontario", "Oswego", "Black", "Oswegatchie", "Raquette", "St. Lawrence", "St. Lawrence Canada", "Lake Champlain", "Upper Hudson", "Mohawk", "Lower Hudson", "Newark Bay", "Long Island"),
  alpha_grain = c(1920, 1740, 4520, 2390, 2280, 2373, 2460, 5070, 1920, 1590, 1253, (5600 - (1590 + 1253)) / 2, (5600 - (1590 + 1253)) / 2, 3050, 4620, 3460, (4982 + 220), 211, 1650),
  alpha_grain_unit = "mile2",
  alpha_grain_type = "watershed",
  alpha_grain_comment = "Oswegatchie, Raquette, St. Lawrence and St. Lawrence Canada together constitute the St. Lawrence watershed as defined by NY state Department of Environment Conservation. Oswegatchie and Raquette areas found on Wikipedia. The rest of the St. Lawrence watershed (NY state DEC) is divided between St. Lawrence and St. Lawrence Canada. As a consequence, St. Lawrence grain is overestimated and St. Lawrence Canada is underestimated. See https://www.dec.ny.gov/lands/26561.html"
)

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta <- merge(meta, env)

meta[, ":="(
  taxon = "Fish",
  realm = "Freshwater",

  latitude = "43.00N",
  longitude = "76.00W",

  data_pooled_by_authors = TRUE,
  data_pooled_by_authors_comment = "checklist",
  sampling_years = c("pre-1940","1941-1987","1988-2004")[match(year, c(1940L, 1987L, 2004L))],

  effort = 1L,



  gamma_sum_grains = sum(1920, 1740, 4520, 2390, 2280, 2373, 2460, 5070, 1920, 1590, 1253, (5600 - (1590 + 1253)) / 2, (5600 - (1590 + 1253)) / 2, 3050, 4620, 3460, (4982 + 220), 211, 1650),
  gamma_sum_grains_unit = "mile2",
  gamma_sum_grains_type = "watershed",
  gamma_sum_grains_comment = "sum of the sampled watersheds",

  gamma_bounding_box = 141300L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "area of New-York state",


  comment = "Extracted from Carlson et al 2004 Supplementary (table extraction, Mix of several Tabula extractions, some saved, some copy pasted because more complete than the whole document extraction). The authors aggregated freshwater fish checklists from collections and state agencies. Regional is New-York state. local are lake watersheds or river basins (sometimes, basins are truncated by state border or several small river basins are merged into one large such as around Lake Ontario cf fig1). years correspond to the end of each period (before 1940, 1940-1987, after 1987). Scientific names of fish species follow Nelson et al. (2004)",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.1674/0003-0031(2004)152[0104:SOFINY]2.0.CO;2'
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
