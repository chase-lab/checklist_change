## castro_2020

dataset_id <- "castro_2020"

ddata <- base::readRDS(paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(ddata, 1L, "species")

# melting sites (watersheds)
ddata <- data.table::melt(ddata,
                          id.vars = "species",
                          value.name = "value",
                          variable.name = "local",
                          na.rm = TRUE
)

# cleaning, splitting and melting periods
ddata[, value := stringi::stri_extract_first_regex(value, "[01],[01]")]
ddata[, c("historical", "current") := data.table::tstrsplit(value, ",")]
ddata <- data.table::melt(ddata,
                          id.vars = c("species", "local"),
                          measure.vars = c("historical", "current"),
                          variable.name = "period"
)
ddata <- ddata[value == "1"]

# data
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Chile",
   species = gsub(x = species, pattern = "[A-Z/]+$", replacement = ""),

   year = c(1535L, 2017L)[match(period, c("historical", "current"))],

   period = NULL,
   value = NULL
)]

# metadata
env <- data.table::as.data.table(
   readxl::read_xlsx(paste0("data/raw data/", dataset_id, "/pone.0238767.s002.xlsx"),
                     sheet = 1L)[, 1:2]
)
data.table::setnames(env, new = c("local", "alpha_grain"))

coordinates <- data.table::fread(file = "data/raw data/castro_2020/coordinates.csv",
                                 header = TRUE, sep = ",", dec = ".")

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[i = env, on = "local"]
meta[i = coordinates,
     j = ":="(latitude = i.latitude,
              longitude = i.longitude),
     on = "local"]


meta[, ":="(
   taxon = "Fish",
   realm = "Freshwater",

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review",

   alpha_grain_unit = "km2",
   alpha_grain_type = "watershed",
   alpha_grain_comment = "area of the watershed",

   gamma_sum_grains = sum(as.numeric(env$alpha_grain)),
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "watershed",
   gamma_sum_grains_comment = "sum of the sampled watersheds",

   gamma_bounding_box = 756096.3,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "area of Chile",

   comment = "Data extracted from the supplementary material associated with the article 'Partitioning β-diversity reveals that invasions and extinctions promote the biotic homogenization of Chilean freshwater fish fauna' by Castro et al in 2020 in plos one.
The authors built checklists of fish species per watershed and considered pre-European (samples from early 20th century) and post-European (current) assemblages.
METHODS: 'Through a complete bibliographical review and authors’ personal records (Irma Vila and Evelyn Habit), we compiled a database with fish occurrence for each basin, distinguishing both native as exotic species. We labelled ‘native’ species as those that occur historically in a basin previous to the European colonization that started in mid-16th century, and whose distribution is a result of eco-evolutionary processes in Chilean basins. In turn, ‘exotic’ species were those non-native species introduced since 1535, which currently show naturalized populations (i.e., established species) in a given Chilean basin.'",
comment_standardisation = "none needed",
doi = 'https://doi.org/10.1371/journal.pone.0238767'
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
