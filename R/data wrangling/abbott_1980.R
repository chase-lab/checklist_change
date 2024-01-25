# abbott_1980
dataset_id <- "abbott_1980"

ddata <- base::readRDS(file = "data/raw data/abbott_1980/rdata.rds")

# Melting sites
ddata <- data.table::melt(
   data = ddata,
   id.vars = 1L,
   variable.name = "local",
   value.name = "year",
   na.rm = TRUE
)
ddata[, c("local", "year") := data.table::tstrsplit(year, " ")]

# Melting years
ddata[, paste0("year", 1L:4L) := data.table::tstrsplit(year, "")]
ddata <- data.table::melt(
   data = ddata,
   id.vars = c("V1", "local"),
   measure.vars = paste0("year", 1L:4L),
   value.name = "year",
   na.rm = TRUE
)
ddata <- ddata[!grepl(".", year, fixed = TRUE)]

data.table::setnames(x = ddata, old = "V1", new = "species")

# Community data
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Rottnest Island",

   year = c(1956L, 1959L, 1975L:1978L)[data.table::chmatch(year, LETTERS[1L:6L])],

   value = 1L,
   variable = NULL
)]

# Metadata
meta <- unique(ddata[, c("dataset_id", "regional", "local", "year")])
meta[i = env, j = alpha_grain := as.integer(i.alpha_grain), on = .(local)]

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   latitude = "32°00′18″S",
   longitude = "115°30′54″E",

   effort = 1L,
   data_pooled_by_authors = FALSE,

   alpha_grain_unit = "m2",
   alpha_grain_type = "functional",
   alpha_grain_comment = "islet area given by the authors",

   gamma_bounding_box = NA,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "functional",
   gamma_bounding_box_comment = "Could be a box comprising all islets and covering islands of Carnac and Rottnest",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "islet areas provided by the authors",

   comment = "Extracted from Abbott & Black 1980, Appendix 1 and 2. The authors sampled the vegetation of islets around an island 18 km off the coast of Perth, Australia. The sampling surveys happened in 1956, 1959, 1975, 1076, 1977, 1978.
FULL REFERENCE: IAN ABBOTT, ROBERT BLACK. 1980. Changes in species composition of floras on
islets near Perth, Western Austral. Journal of Biogeography 7, 399-410",
   comment_standardisation = "In appendix 1, following values 93 CR, 144 CE were replaced with: 93 CE, 111 CE.",
   doi = NA
)][, gamma_sum_grains := sum(alpha_grain), keyby = .(year)]

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
