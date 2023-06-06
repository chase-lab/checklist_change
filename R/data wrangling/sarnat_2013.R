dataset_id <- "sarnat_2013"

ddata <- base::readRDS(file = "./data/raw data/sarnat_2013/rdata.rds")

# Status data: recreating the historical community without exotic species
ddata[, species := gsub(" x .*$", "", species)]
status <- data.table::fread(file = "./data/raw data/sarnat_2013/status.csv", sep = ",", encoding = "UTF-8", skip = 1, header = TRUE)
status[, species := gsub("\\*", "", species)]
ddata <- data.table::rbindlist(
  list(
    historical = ddata[!species %in% status$species],
    recent = ddata
  ),
  idcol = TRUE
)
data.table::setnames(ddata, ".id", "period")


# Environment data
env <- data.table::fread(file = "./data/raw data/sarnat_2013/env.csv", sep = ",", encoding = "UTF-8", header = TRUE)
env[coordinates != "", c("latitude", "longitude") := parzer::parse_llstr(coordinates)]

# Community data
## Excluding archipelagos
ddata[, grep(" IS.", colnames(ddata), ignore.case = TRUE) := NULL]

## melting sites
ddata <- data.table::melt(ddata,
  id.var = c("period", "species"),
  variable.name = "local",
  na.rm = TRUE
)

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Solomon Islands",

  year = c(1568L, 2000L)[match(period, c("historical", "recent"))],


  species = gsub("*", "", species, fixed = TRUE),
  period = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Invertebrates",
  realm = "Terrestrial",

  latitude = env$latitude[match(local, env$local)],
  longitude = env$longitude[match(local, env$local)],

  effort = 1L,

  alpha_grain = env$alpha_grain[match(local, env$local)],
  alpha_grain_unit = "km2",
  alpha_grain_type = "island",
  alpha_grain_comment = "area of the island found online or google Earth",

  gamma_sum_grains = sum(env$alpha_grain, na.rm = TRUE), #
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "archipelago",
  gamma_sum_grains_comment = "sum of the area of the islands",

  gamma_bounding_box = geosphere::areaPolygon(env[grDevices::chull(env[, c("longitude", "latitude")]), c("longitude", "latitude")]) / 1000000,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  comment = "Extracted from supp material 3 from sarnat_2013 mostly by hand. Methods: 'In order to compile a comprehensive and accurate inventory of ant species recorded from the Solomon Islands, we researched taxonomic names that were associated with the region in the literature. We reviewed the names of all taxa that were originally described from Solomons, reviewed specimen records from Antweb.org, reviewed the species list for the Solomon Islands presented on Antwiki <http://www.antwiki.org Solomon_Islands>, searched the Formis database (Porter and Wojcik 2012) for all relevant literature containing the term ‘Solomon’, and reviewed relevant taxonomic and regional literature. We also reviewed a dataset of ca. 1,040 specimen records of identified ants collected in the Solomon Islands that are deposited at the ANIC (Australian National Insect Collection, Canberra). We used the Bolton (2012) catalog to determine the valid names of all the species on the list. The Bolton (2012) catalog does not recognize the synonymy of Cryptopone with Pachycondyla, as implicitly proposed by Mackay & Mackay (2010), and the name is retained here as valid.' The historical community was reconstructed by excluding the exotic species from the present community.",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.3897/zookeys.257.4156'
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
