## lindholm_2019
dataset_id <- "lindholm_2019"

ddata <- base::readRDS("data/raw data/lindholm_2019/ddata.rds")
data.table::setnames(x = ddata, old = 1L, new = "localyear")

# melting species
ddata <- data.table::melt(data = ddata,
                          id.vars = "localyear",
                          variable.name = "species"
)
ddata <- ddata[value != 0L]

# splitting site and period
ddata[, c("local", "year") := data.table::tstrsplit(
   x = localyear, split = "(?<=[a-z])(?=[0-9])", perl = TRUE)]

# species names: replacement of the abbreviations
specieslong <- base::readRDS(file = "data/raw data/lindholm_2019/specieslong.rds")

ddata[, ":="(
   dataset_id = dataset_id,
   regional = base::enc2utf8("Kokemäenjoki watershed"),

   year = c(1950L, 1978L, 1993L, 2008L, 2017L)[data.table::chmatch(
      x = data.table::fifelse(
         test = year %in% c("40", "70", "90"),
         yes = paste0("19", year),
         no = paste0("20", year)),
      table = c("1940","1970","1990","2000","2010")
   )],

   species = base::enc2utf8(specieslong$Species.name[match(species, specieslong$Abbreviation)]),

   localyear = NULL
)]

## coordinates - loading and conversion
env <- base::readRDS(file = "data/raw data/lindholm_2019/env.rds")

data.table::setnames(
   x = env,
   old = c("V1", "X", "Y", "Area"),
   new = c("localyear", "longitude", "latitude", "alpha_grain"))
env[j = c("local", "year") := data.table::tstrsplit(
   x = localyear, split = "(?<=[a-z])(?=[0-9])", perl = TRUE)][
      j = year := c(1950L, 1978L, 1993L, 2008L, 2017L)[data.table::chmatch(
         x = data.table::fifelse(
            test = year %in% c("40", "70", "90"),
            yes = paste0("19", year),
            no = paste0("20", year)),
         table = c("1940","1970","1990","2000","2010"))]
   ]
sp::coordinates(env) <- ~ longitude + latitude
sp::proj4string(env) <- sp::CRS(SRS_string = "EPSG:5048") # ETRS-TM35FIN
env <- sp::spTransform(env, sp::CRS(SRS_string = "EPSG:4326"))

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta <- merge(meta, env[, c("local", "year", "alpha_grain")])
meta[, ":="(
   realm = "Freshwater",
   taxon = "Plants",

   latitude = sp::coordinates(env)[match(local, env$local), "coords.x2"],
   longitude = sp::coordinates(env)[match(local, env$local), "coords.x1"],

   effort = 1L,

   data_pooled_by_authors = TRUE,
   sampling_years = c("1947-1950", "1975-1978", "1991-1993","2005-2008", "2017")[match(year, c(1950L, 1978L, 1993L, 2008L, 2017L))],

   alpha_grain_unit = "ha",
   alpha_grain_type = "lake_pond",
   alpha_grain_comment = "areas provided by the authors in the Dryad repo",

   gamma_sum_grains = sum(alpha_grain),
   gamma_sum_grains_unit = "ha",
   gamma_sum_grains_type = "lake_pond",
   gamma_sum_grains_comment = "sum of the areas of the lakes given by the authors",

   gamma_bounding_box = 27100L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "watershed",
   gamma_bounding_box_comment = "area found online https://www.kokemaenjoki.fi/",

   comment = "Extracted from Dryad repo Lindholm, Marja; Alahuhta, Janne; Heino, Jani; Toivonen, Heikki (2021). Data from: No biotic homogenisation across decades but consistent effects of landscape position and pH on macrophyte communities in boreal lakes [Dataset]. Dryad. https://doi.org/10.5061/dryad.t1g1jwsxv . The authors sampled macrophytes from 27 boreal lakes from a Finnish watershed during the 1940s, 1970s, 1990s, 2000s and 2010s. Effort depends on the lake size: the whole lakes have been sampled at each survey and size varies from 2 10E-1 to 2 10E2. Coordinates provided by the authors.
Regional is a watershed, local are lakes.",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.1111/ecog.04757 | https://doi.org/10.5061/dryad.t1g1jwsxv"
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
