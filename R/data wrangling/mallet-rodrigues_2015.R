# mallet-rodrigues_2015
dataset_id <- "mallet-rodrigues_2015"

ddata <- base::readRDS("data/raw data/mallet-rodrigues_2015/ddata.rds")

# melting sites ----
for (j in 1:ncol(ddata)) data.table::set(
   x = ddata,
   i = which(ddata[[j]] == ""),
   j = j,
   value = NA_character_)

ddata <- data.table::melt(
   data = ddata,
   id.vars = c("species", "V2"),
   variable.name = "local",
   na.rm = TRUE
)

# reconstructing past community ----
## recoding invasion status into period ----
ddata[i = is.na(V2) | V2 == "",
      j = V2 := stringi::stri_extract_last_regex(str = species, pattern = "I$|Int$")][
         i = !V2 %in% c("Int", "I"),
         j = period := "historical&recent"][
            i = V2 %in% c("Int", "I"),
            j = period := "recent"]

## splitting and melting period ----
ddata[, c("period", "period2") := data.table::tstrsplit(period, "&")]
ddata <- data.table::melt(
   data = ddata,
   id.vars = c("species", "local"),
   measure.vars = c("period", "period2"),
   value.name = "period",
   na.rm = TRUE
)

# community data ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Rio de Janeiro, Brazil",

   year = c(1700L, 2011L)[match(period, c("historical", "recent"))],

   species = gsub("A$|E$|E, A$|I$|VS$", "", species),


   period = NULL,
   variable = NULL
)][local == "Orgaos",
   local := "Órgãos"][, local := base::enc2utf8(as.character(local))]

ddata <- unique(ddata[!is.na(species)])

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])

meta[, ":="(
   realm = "Terrestrial",
   taxon = "Birds",

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "samples pooled",

   alpha_grain = c(104000L, 28084L, 10527L)[data.table::chmatch(local,
                                                                c("Bocaina", "Itatiaia", "Órgãos"))],
   alpha_grain_unit = "ha",
   alpha_grain_type = "administrative",
   alpha_grain_comment = "area of the national parks",

   gamma_bounding_box = 43696L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "area of State of Rio de Janeiro",

   gamma_sum_grains = sum(c(104000L, 28084L, 10527L)),
   gamma_sum_grains_unit = "ha",
   gamma_sum_grains_type = "administrative",
   gamma_sum_grains_comment = "sum of the area of the 3 national parks",

   comment = "Extracted from Article Mallet-Rodrigues et al 2015, Data in table 1. Historical community was constructed by considering only native species from recent lists.
1700 was chosen as the end of the historical period as it was the beginning of the industrialisation period.
Regional is State of Rio de Janeiro, local are national parks.
FULL REFERENCE: Mallet-Rodrigues, F., Parrini, R. & Rennó, B. (2015). Bird species richness and composition along three elevational gradients in southeastern Brazil. Atualidades Ornitológicas, 188, 39–58.",
   comment_standardisation = "none needed",
   doi = NA
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
