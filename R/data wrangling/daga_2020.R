# daga_2020
dataset_id <- "daga_2020"

# loading and cleaning ----
ddata <- base::readRDS(file = "data/raw data/daga_2020/rdata.rds")
env <- base::readRDS(file = "data/raw data/daga_2020/env.rds")

data.table::setnames(
   x = ddata,
   old = c("species", "historical_Southeastern Mata Atlantica",
           "recent_Southeastern Mata Atlantica","historical_Iguassu",
           "recent_Iguassu", "historical_Upper Parana",
           "recent_Upper Parana"))
ddata <- ddata[!grepl("^Class|^ORDER|^Family|^Total", species)]

# melting and splitting period and local ----
ddata <- data.table::melt(ddata, id.vars = "species", variable.name = "period")
ddata[, c("period", "local") := data.table::tstrsplit(period, "_")]
ddata <- ddata[value != ""]

# abundance data ----
ddata[, ":="(
   dataset_id = "daga_2020",
   regional = "South Brazil",

   year = c(1900L, 2007L)[match(period, c("historical", "recent"))],

   species = gsub(" \u00A7| \u2021| \u00DE", "", species), # section, double dagger and Thorn special characters
   value = 1L,

   period = NULL
)]

# metadata ----
## reservoir area

env[Ecoregion == "", Ecoregion := NA_character_][, Ecoregion := zoo::na.locf(Ecoregion, na.rm = FALSE)]
env[, Area..km2. := as.numeric(sub("< ", "", Area..km2.))]
env[, alpha_grain := sum(Area..km2.), by = Ecoregion]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[i = env,
     j = alpha_grain := i.alpha_grain,
     on = c("local" = "Ecoregion")]

meta[, ":="(
   taxon = "Fish",
   realm = "Freshwater",

   latitude = c(-25.5, -25.5, -24.5)[match(local, c("Southeastern Mata Atlantica", "Iguassu", "Upper Parana"))],
   longitude = c(-49, -52.5, -51)[match(local, c("Southeastern Mata Atlantica", "Iguassu", "Upper Parana"))],

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Past composition constructed from species status. Present composition based on samplings by the authors between 2002 and 2007",

   alpha_grain_unit = "km2",
   alpha_grain_type = "lake_pond",
   alpha_grain_comment = "sum of reservoir areas given by the authors",
   # OR AREAS OF THE WATERSHEDS

   gamma_sum_grains = sum(alpha_grain),
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "lake_pond",
   gamma_sum_grains_comment = "sum of the areas of sampled reservoirs",

   gamma_bounding_box = sum(14674L, 72000L, 186321L),
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "watershed",
   gamma_bounding_box_comment = "sum of the areas of the three sampled watersheds",

   comment = "Extracted from supplementary 1 Online resource 1 and 3 associated to article https://doi.org/10.1007/s10750-019-04145-5. Recent (or current) composition was assessed through net sampling of reservoirs several times between 2002 and 2007. Historical (or original) composition was reconstructed by the authors by including all native species contacted in the years 2000s and excluding all exotic species.
METHODS: 'Twenty reservoirs were sampled, which are located in three major freshwater ecoregions (Abell et al., 2008) in southern Brazil: Southeastern Mata Atlantica, Iguassu, and Upper Parana freshwater ecoregions[...]Fish sampling at each reservoir involved the deployment of gillnets (mesh size: 2.4 to 16 cm between opposite knots) and trammel nets (inner mesh size: 6 to 8 cm) with a length of 10 to 20 m and height of 1.5 to 4.5 m. In most of the reservoirs, the set of gillnets were deployed in three sampling sites arranged along the reservoirs[...]The gillnets were located at the surface, bottom, and margin of each sampling site and were in the water for 24 h. In addition, in the littoral areas of the reservoirs, fish were captured with a 20-m-long seine net (0.5 cm mesh size), during the day and night periods.[...]Datasets were constructed according to expert opinions and the fish sampling (species occurrence data) from all reservoirs for each time period: initial period represented the most probable ‘original’ pool of native species, and contained all native species that were recorded at least once during the 2002 to 2007 time period (i.e., species composition prior to native extirpations and nonnative introductions), and the current period that represented all native and nonnative species recorded during 2002/2003, 2004/2005, and 2006/2007.'
Regional is Southern Brazil and each local is a reservoir lake",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1007/s10750-019-04145-5'
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
