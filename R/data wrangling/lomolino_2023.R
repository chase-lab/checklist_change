dataset_id <- "lomolino_2023"

ddata <- base::readRDS(file = "data/raw data/lomolino_2023/rdata.rds")

# Melting sites
## Replacing all empty strings with NA by reference
ddata[j = (colnames(ddata)) := lapply(
   X = .SD,
   FUN = function(x) base::replace(
      x = x,
      list = stringi::stri_isempty(x),
      values = NA_character_))]

data.table::setnames(ddata, old = ".id", new = "regional")

## Melting
ddata <- data.table::melt(
   data = ddata,
   id.vars = c("regional","species"),
   variable.name = "local",
   variable.factor = TRUE,
   na.rm = TRUE
)

# Reconstructing communities
## Removing two problematic observations, cf. comment_standardisation
ddata <- ddata[!(species == "Isolobodon portoricensis" & value == "p")]
## Recoding species status
ddata[, value := c("past"," past", "past",
                   "past+present", "present")[data.table::chmatch(
                      x = value, table = c("b", "ae", "as", "p", "i"))]]

## Splitting periods
ddata[, paste0("tmp", 1:2) := data.table::tstrsplit(value, "+", fixed = TRUE)]

# Melting periods
ddata <- data.table::melt(
   data = ddata,
   id.vars = c("regional", "local", "species"),
   measure.vars = paste0("tmp", 1:2),
   value.name = "period",
   na.rm = TRUE
)
## Turning periods into years
source(file = "data/raw data/lomolino_2023/env.R")
ddata[i = env,
      j = year := i.year,
      on = .(local, period)]

# Community data
ddata[, ":="(
   dataset_id = dataset_id,

   value = 1L,

   period = NULL,
   variable = NULL
)]
ddata <- ddata[!base::is.element(el = local, set = c("Isabela", "Santa Cruz"))]

# Metadata
meta <- unique(ddata[, c("dataset_id", "regional", "local", "year")])
meta[i = env,
     j = alpha_grain := i.alpha_grain,
     on = .(local)]
meta[i = env,
     j = c("latitude", "longitude") := parzer::parse_llstr(i.coordinates),
     on = .(local)]

meta[, ":="(
   taxon = "Mammals",
   realm = "Terrestrial",

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review",

   alpha_grain_unit = "km2",
   alpha_grain_type = "island",
   alpha_grain_comment = "retrieved from Wikipedia",

   gamma_bounding_box = NA,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "functional",
   gamma_bounding_box_comment = "",

   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "sum of island areas",

   comment = "Data were extracted from Appendix 1, tables extracted with package tabulizer. The authors listed mammal species from 37 islands in 5 groups. The status of each species can be one of:' b = species extinct before hominids (‘natural extinctions’); ae = species extinct after early hominid arrival; as = species extinct after Homo sapiens arrival; p = native species present today; i = introduced species.'. We considered that past communities date from before European contact and recent communities date from 2023 the year of publishing. Introduced species are present only in recent communities.",
   comment_standardisation = "Data from Isabela and Santa Cruz islands from the Galapagos archipelago were removed as they are already included in Jimenez-Uzcategui 2014. Madagascar was not included as it is the only island from the Indian Ocean. In Porto Rico and Hispaniola, the species Isolobodon portoricensis was considered `as` and `p` at the same time. Since it is considered as `as` by IUCN, we removed the `p` rows.",
   doi = "https://doi.org/10.21425/F5FBG59967"
)][, gamma_sum_grains := sum(alpha_grain), by = .(year)]

# Pressing northward from their base in Panay, the Spaniards first
# set foot in the island of Mindoro in April, 1570.
# n the medieval period, after over a century of European incursions and attempts at conquest, the island of Gran Canaria was conquered on April 29, 1483, by the Crown of Castile
#
# Delete Isabela y santa cruz
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
