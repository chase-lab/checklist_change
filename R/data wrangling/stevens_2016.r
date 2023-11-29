# stevens_2016
dataset_id <- "stevens_2016"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
data.table::setnames(ddata, new = c("local", "species", "1968", "2013"))
ddata[local == "", local := NA_character_][, local := zoo::na.locf(local)]

ddata <- data.table::melt(ddata,
                          measure.vars = c("1968", "2013"),
                          value.name = "value",
                          variable.name = "year"
)
ddata <- ddata[value != 0]

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Sheffield",

   value = 1L
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(

   realm = "Terrestrial",
   taxon = "Plants",

   latitude = '53° 23` 0" N',
   longitude = '1° 28` 0" W',

   effort = c(196L, 259L)[match(local, c("Acid", "Calcareous"))],

   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "many sites per habitat type, one sampling per site per sampling period",
   sampling_years = c("1965-1968", "2012-2013")[match(year, c(1968, 2013))],

   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "sum of 1m2 quadrats sampled per habitat type",

   gamma_sum_grains = 196L + 259L,
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "quadrat",

   gamma_bounding_box = 2400L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "functional",
   gamma_bounding_box_comment = "The survey focused on a 2400 km2 area around Sheffield encompassing a large part of the Peak District National Park.",

   comment = "Extracted from Stevens, C.J., Ceulemans, T., Hodgson, J.G., Jarvis, S., Grime, J.P. and Smart, S.M. (2016), Drivers of vegetation change in grasslands of the Sheffield region, northern England, between 1965 and 2012/13. Appl Veg Sci, 19: 187-195. https://doi.org/10.1111/avsc.12206. Data extracted from supplementary Excel file. Authors resurveyed the exact same sites as Lloyd in 1965-68 to analyse structuring factors of plant communities.
Regional is the area covering all sampling sites, given by the authors, local are two habitat types sampled in many locations throughout the regional area. The number of quadrats per habitat is given as effort.",
   comment_standardisation = "All quadrats were pooled together by period and habitat type",
   doi = 'https://doi.org/10.1111/avsc.12206'
)][, alpha_grain := effort]

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
