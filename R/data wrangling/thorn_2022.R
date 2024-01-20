# thorn_2022
dataset_id <- "thorn_2022"

ddata <- base::readRDS(file = "data/raw data/thorn_2022/rdata.rds")

# Melting species ----
## replace all 0 values by NA
ddata[, names(ddata) := lapply(.SD, function(column) replace(column,
                                                             column == 0L,
                                                             NA_integer_))]
ddata <- data.table::melt(
   data = ddata,
   id.vars = c("plot","year","grassland"),
   variable.name = "species",
   value.name = "value",
   na.rm = TRUE
)

# Community data ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Bavaria",

   local = as.factor(stringi::stri_extract_first_regex(str = plot,
                                                       pattern = "(?<=_).*$")),

   value = 1L,

   plot = NULL,
   grassland = NULL
)][year == 1980L, year := 1988L]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   latitude = "50°01′N",
   longitude = "10°30′E",

   effort = 1L,
   data_pooled_by_authors = FALSE,

   alpha_grain = 2.6,
   alpha_grain_unit = "ha",
   alpha_grain_type = "functional",
   alpha_grain_comment = "mean area of the grasslands given by the authors",

   gamma_sum_grains_unit = "ha",
   gamma_sum_grains_type = "functional",
   gamma_sum_grains_comment = "sum of the areas of the grasslands given by the authors",

   gamma_bounding_box = 950L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "area of Hassberge in northern Bavaria",

   comment = "Extracted from repository doi:10.6084/m9.figshare.c.5976644 associated to article Thorn S, König S, Fischer-Leipold O, Gombert J, Griese J, Thein J. 2022 Temperature preferences drive additive biotic homogenization of Orthoptera assemblages. Biol. Lett. 18: 20220055. https://doi.org/10.1098/rsbl.2022.0055 .
METHODS: 'Orthoptera surveys were conducted once per plot and year between mid-July and mid-September under sunny weather conditions without rain and strong wind. All visual and acoustic observations of orthopterans were recorded. We identified stridulating males in field to species level via their species-specific songs [18,24]. Sweep netting and capture by direct search were additionally used to record species restricted to specific microhabitats, such as Tetrix spp. Morphological determination of non-stridulating species followed Fischer et al. [25]. Depending on the respective size of the study plot, we spent between 15 and 90 min (30 min on average) to survey the plot. Surveys were either conducted by one or two observers and completed once the entire area of a grassland has been examined. All study sites were sampled in 1988, 2004 and 2019.'
The authors used 198 sites: probably those that were sampled 3 times and excluded the 3 sites that were sampled only twice.
Regional is the Hassberge region in Northern Bavaria, Germany and local are grasslands.",
   comment_standardisation = "All abundances were equal to 1 except a few species from 4 locations in 2019 that had an abundance of 2. All abundances were turned into 1.",
   doi = "https://doi.org/10.6084/m9.figshare.19697279.v1 | https://doi.org/10.1098/rsbl.2022.0055"
)][, gamma_sum_grains := sum(alpha_grain), keyby = year]

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
