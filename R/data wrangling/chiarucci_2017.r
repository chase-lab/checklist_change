## chiarucci_2017


dataset_id <- "chiarucci_2017"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

ddata[, ":="(
  "Life Form" = NULL,
  "Alien / Native" = NULL
)]
data.table::setnames(ddata, c("species", paste(colnames(ddata)[-1], unlist(ddata[1])[-1], sep = "+")))

# melting sites and periods
ddata <- data.table::melt(ddata,
  id.vars = c("species"),
  value.name = "value",
  variable.name = "local"
)
ddata <- ddata[value == 1]

# splitting local and period names
ddata[, c("local", "period") := data.table::tstrsplit(local, "\\+")]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Mediterranean",
  local = gsub("\\.{3}[0-9]*$", "", local),
  year = c(1950L, 2015L)[match(period, c("1830-1950", "1951-2015"))],
  period = NULL
)]

env <- data.table::fread(paste0("./data/raw data/", dataset_id, "/env.csv"), skip = 1, sep = "\t")
data.table::setnames(env, c("local", "latitude", "longitude", "area"))
env[, local := data.table::fifelse(
  local == "Monte Argentario", "Argentario",
  data.table::fifelse(
    local == "Isolotto Porto Ercole", "Isolotto Porto ercole",
    data.table::fifelse(
      local == "Formica di Burano", "Fobu",
      local
    )
  )
)]
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Plants",
  realm = "Terrestrial",

  latitude = env$latitude[match(local, env$local)],
  longitude = env$longitude[match(local, env$local)],

  effort = 1L,

  data_pooled_by_authors = TRUE,
  data_pooled_by_authors_comment = "'All available published papers and some unpublished sources (such as masters’ theses and doctoral dissertations and technical reports) dealing with the plants of the Tuscan archipelago were searched and compiled by the botanical team of the University of Florence'",
  sampling_years = c("1830-1950", "1951-2015")[match(year, c(1950L, 2015L))],

  alpha_grain = env$area[match(local, env$local)],
  alpha_grain_unit = "km2",
  alpha_grain_type = "island",
  alpha_grain_comment = "provided by the authors",

  gamma_bounding_box = geosphere::areaPolygon(env[grDevices::chull(env[, c("longitude", "latitude")]), c("longitude", "latitude")]) / 1000000,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  gamma_sum_grains = sum(env[local %in% unique(meta$local), "area"]),
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "archipelago",
  gamma_sum_grains_comment = "sum of the area of the sampled islands",


  comment = "Extracted from the supplementary material from chiarucci et al 2017. Effort is unknown but extensive: checklist. 'All available published papers and some unpublished sources (such as masters’ theses and doctoral dissertations and technical reports) dealing with the plants of the Tuscan archipelago were searched and compiled by the botanical team of the University of Florence [...]. These references were checked to extract occurrence records for all those species reported as spontaneous on at least one of the studied islands. [...] Overall, we assembled the existing data on plant species occurrences on 16 islands (7 major islands, Monte Argentario fossil island, and 8 islets) in two main periods: from 1830 to 1950 and from 1951 to 2015.[...] We used 1950–1951 as a pivotal shift date because of the major changes in the human presence and activities on the islands from the 1950s, when most of the archipelago’s economy shifted from traditional agriculture to tourism.'",
  comment_standardisation = "none needed"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
