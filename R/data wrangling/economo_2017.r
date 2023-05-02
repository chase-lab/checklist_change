## economo_2017
dataset_id <- "economo_2017"
ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))



data.table::setnames(ddata, 1:2, c("species", "status"))

# melting sites
ddata <- data.table::melt(ddata,
  id.vars = c("species", "status"),
  variable.name = "local"
)


# recoding status in periods, splitting and melting periods
ddata[, status := c("historical+modern", "historical+modern", "historical+modern", "modern")[match(status, c("Native", "Endemic", "Pacific Tramp", "Exotic to Pacific"))]]

ddata[, paste0("tmp", 1:2) := data.table::tstrsplit(status, "\\+")]
ddata <- data.table::melt(ddata,
  id.vars = c("species", "local", "value"),
  measure.vars = paste0("tmp", 1:2),
  value.name = "period"
)

ddata <- ddata[value != 0 & !is.na(period)]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Pacific Ocean",

  year = c(1800L, 2015L)[match(period, c("historical", "modern"))],

  variable = NULL,
  period = NULL
)]

coords <- data.table::fread(file = "./data/raw data/economo_2017/coordinates.csv", encoding = "UTF-8")
coords[, c("latitude", "longitude") := parzer::parse_llstr(coords$coordinates)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Invertebrates",

  latitude = coords$latitude[match(local, coords$local)],
  longitude = coords$longitude[match(local, coords$local)],

  effort = 1L,

  alpha_grain = c(28896L, 18274L, 459L, 747L, 2831L, 308L, 122L, 1048L, 236L, 372L, 1590L, 12L, 142L, 148L, 31L, 28311L, 1049L, 260L, 850L)[match(local, c("Solomon Islands", "Fiji", "Palau", "Tonga", "Samoan Islands", "Yap", "Chuuk", "Pohnpei", "Cook Islands", "Mariana Islands", "Society Islands", "Tokelau", "Wallis and Futuna", "Austral Islands", "Gambier Islands", "Hawaii", "Marquesas Islands", "Niue Island", "Tuamotu Islands"))],
  alpha_grain_unit = "km2",
  alpha_grain_type = "island",
  alpha_grain_comment = "island or archipelago area as given by the authors in Table 1",

  gamma_sum_grains = sum(c(28896L, 18274L, 459L, 747L, 2831L, 308L, 122L, 1048L, 236L, 372L, 1590L, 12L, 142L, 148L, 31L, 28311L, 1049L, 260L, 850L)),
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "archipelago",
  gamma_sum_grains_comment = "sum of the area of the islands and archipelagos in alpha grain",

  gamma_bounding_box = geosphere::areaPolygon(coords[grDevices::chull(coords[, c("longitude", "latitude")]), c("longitude", "latitude")]) / 1000000,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  comment = "Extracted from Dryad repository (doi:10.5061/dryad.2f7b2) associated to the paper ECONOMO  et al 2017 doi:10.1111/jbi.12884. The authors aggregated ant checklists for the islands of interest: 'Our main source of data was the Global Ant Biodiversity Informatics (GABI) database[...]. Of these, ~42,000 records were available from the Pacific islands using the database version from September 2015. We first summarized these data into a checklist for each archipelago. Subsequently, each author independently checked each record for quality and plausibility, making corrections when necessary. In some cases, we supplemented these records with our own unpublished collection records.'. Species could be either Endemic, Native, Exotic or Pacific tramp: TRAMP SPECIES CONSIDERED NATIVE. Exotic species (present only in the modern period) were defined by the authors as species 'introduced into the Pacific region through human commerce.' Year is hard to infer from the paper more accurately than this commerce development pivot.",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.5061/dryad.2f7b2 | https://doi.org/10.1111/jbi.12884'
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
