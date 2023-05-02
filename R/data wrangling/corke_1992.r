## corke_1992


dataset_id <- "corke_1992"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
data.table::setnames(ddata, "Species", "species")

# melting sites
ddata <- data.table::melt(ddata,
  id.vars = c("species"),
  value.name = "period",
  variable.name = "local"
)
ddata <- ddata[period != "" & !grepl("Total|Tota l|To ta l|endemics", species)]

# recoding presence absence
ddata[, period := trimws(gsub("\\([0-9]\ ?\\)", "", period))][, period := data.table::fifelse(
  period %in% c("-", "- -", ".", ". ."), "",
  data.table::fifelse(
    period %in% c("*", ":~", "~", "~:", "+", "t"), "historical+present",
    data.table::fifelse(grepl("\\[|\\{", period), "historical", "present")
  )
)]

# melting historical and present values
ddata[, c("period1", "period2") := data.table::tstrsplit(period, "\\+")]
ddata <- data.table::melt(ddata,
  id.vars = c("local", "species"),
  measure.vars = c("period1", "period2"),
  value.name = "period"
)
ddata <- ddata[!is.na(period)]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Windward Islands",
  year = c(1900, 1992)[match(period, c("historical", "present"))],

  value = 1L,

  variable = NULL,
  period = NULL
)]


ddata[, species := gsub(" {2,}", "_", species)][, species := gsub(" {1}", "", species)][, species := gsub("\\._", "\\. ", species)][, species := gsub("\\(seetext\\)", "", species)][, species := gsub("\\.([[:alpha:]])", "\\. \\1", species)][, species := gsub("_", " ", species)][, species := gsub("^,4", "A", species)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])

env <- data.table::fread(paste0("./data/raw data/", dataset_id, "/env.csv"), skip = 0, header = TRUE, encoding = "Latin-1")
env[, c("latitude", "longitude") := data.table::tstrsplit(coordinates, " ")]
# env[, ':='(
#    latitude = parzer::parse_lat(env$latitude),
#    longitude = parzer::parse_lon(env$longitude)
# )]

meta <- merge(meta, env[, .(local, latitude, longitude)])

meta[, ":="(
  taxon = "Herpetofauna",
  realm = "Terrestrial",

  effort = 1L,

  alpha_grain = env$area[match(local, env$local)],
  alpha_grain_unit = "km2",
  alpha_grain_type = "island",
  alpha_grain_comment = "area of the island",

  gamma_bounding_box = geosphere::areaPolygon(env[grDevices::chull(env[, c("longitude", "latitude")]), c("longitude", "latitude")]) / 1000000,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  gamma_sum_grains = sum(env[local %in% unique(meta$local), "area"]),
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "archipelago",
  gamma_sum_grains_comment = "sum of the areas of the sampled islands.",


  comment = "Extracted from the article with tabulizer and hand copy. Freshwater, Terrestrial and marine species sampled. The authors made a review of the literature to assess the historical compositions. 'The status summaries for St Lucia, St Vincent and some of the Grenadines are based on my own field observations carried out during 1989 with previous visits to St Lucia and satellites in 1983 and 1986.[...]The current checklist for the West Indian herpetofauna is Schwartz and Henderson (1988).' Species that were noted as extinct in the main island but still present in islets were considered extinct for this study.",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.1016/0006-3207(92)91151-H'
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
