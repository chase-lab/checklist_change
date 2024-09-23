## merging Wrangled data.frames
library(dplyr)

# Merging ----
listfiles <- list.files("data/wrangled data",
                        pattern = "[[:digit:]](a|b)?\\.csv",
                        full.names = TRUE, recursive = TRUE
)
listfiles_metadata <- list.files("data/wrangled data",
                                 pattern = "_metadata.csv",
                                 full.names = TRUE, recursive = TRUE
)
if (length(listfiles) != length(listfiles_metadata)) stop()
template <- utils::read.csv("data/template_communities.txt", header = TRUE, sep = "\t")
column_names_template <- template[, 1]

lst <- lapply(listfiles, data.table::fread,
              integer64 = "character",
              encoding = "UTF-8",
              colClasses = c(dataset_id = "factor",
                             regional = "factor",
                             local = "factor"))
dt <- data.table::rbindlist(lst, fill = TRUE)

template_metadata <- utils::read.csv("data/template_metadata.txt", header = TRUE, sep = "\t")
column_names_template_metadata <- template_metadata[, 1L]

lst_metadata <- lapply(X = listfiles_metadata,
                       FUN = data.table::fread,
                       integer64 = "character",
                       encoding = "UTF-8", sep = ",",
                       colClasses = c(dataset_id = "factor",
                                      regional = "factor",
                                      local = "factor",
                                      taxon = "factor",
                                      realm = "factor",
                                      alpha_grain_type = "factor",
                                      alpha_grain_comment = "factor",
                                      gamma_bounding_box_type = "factor",
                                      gamma_bounding_box_comment = "factor",
                                      gamma_sum_grains_type = "factor",
                                      gamma_sum_grains_comment = "factor",
                                      comment = "factor",
                                      comment_standardisation = "factor",
                                      doi = "factor"))
meta <- data.table::rbindlist(lst_metadata, fill = TRUE)

# Checking data ----
check_indispensable_variables <- function(dt, indispensable_variables) {
   na_variables <- apply(dt[, ..indispensable_variables], 2, function(variable) any(is.na(variable)))
   if (any(na_variables)) {
      na_variables_names <- indispensable_variables[na_variables]

      for (na_variable in na_variables_names) {
         warning(paste0("The variable -", na_variable, "- has missing values in the following datasets: ", paste(unique(dt[c(is.na(dt[, ..na_variable])), "dataset_id"]), collapse = ", ")))
      }
   }
}

# check_indispensable_variables(dt, column_names_template[as.logical(template[, 2])])
# check_indispensable_variables(meta, column_names_template_metadata[as.logical(template_metadata[, 2])])
if (anyDuplicated(dt)) stop(paste(
   "duplicated rows in",
   paste(dt[duplicated(dt),unique(dataset_id)],
         collapse = ", ")))
if (anyNA(dt$year)) warning(paste("missing _year_ value in ", unique(dt[is.na(year), dataset_id]), collapse = ", "))
if (anyNA(meta$year)) warning(paste("missing _year_ value in ", unique(meta[is.na(year), dataset_id]), collapse = ", "))
if (any(dt[j = .(is.na(regional) | regional == "")])) warning(paste("missing _regional_ value in ", unique(dt[is.na(regional) | regional == "", dataset_id]), collapse = ", "))
if (any(dt[, .(is.na(local) | local == "")])) warning(paste("missing _local_ value in ", unique(dt[is.na(local) | local == "", dataset_id]), collapse = ", "))
if (any(dt[, .(is.na(species) | species == "")])) warning(paste("missing _species_  value in ", unique(dt[is.na(species) | species == "", dataset_id]), collapse = ", "))
# if (any(dt[, .(is.na(value) | value == "" | value <= 0)])) warning(paste("missing _value_  value in ", unique(dt[is.na(value) | value == "" | value <= 0, dataset_id]), collapse = ", "))

## Counting the study cases ----
dt |>
   group_by(dataset_id) |>
   reframe(nsites = n_distinct(local)) |>
   arrange(-nsites)

# Ordering ----
# data.table::setcolorder(dt, intersect(column_names_template, colnames(dt)))
data.table::setorder(dt, dataset_id, regional, local, year, species)

# Deleting special characters in regional and local ----
# dt[, ":="(
#   local = iconv(local, from = "UTF-8", to = "ASCII")
# )]

# Checks
## checking species names ----
for (i in seq_along(lst)) if (is.character(lst[[i]]$species)) if (any(!unique(Encoding(lst[[i]]$species)) %in% c("UTF-8", "unknown"))) warning(paste0("Encoding issue in ", listfiles[i]))

### adding GBIF matched names by Dr. Wubing Xu ----
corrected_species_names <- data.table::fread(
   file = "data/requests to taxonomy databases/manual_checklist_change_species_filled_20240104.csv",
   colClasses = c(dataset_id = "factor",
                  species = "character",
                  species_new = "character",
                  corrected = "NULL",
                  checked = "NULL"),
   header = TRUE, sep = ",")

dt <- dt |>
   dtplyr::lazy_dt(immutable = FALSE) |>
   left_join(corrected_species_names,
             join_by(dataset_id, species)) |>
   mutate(species_original = species,
          species = NULL) |>
   rename(species = species_new) |>
   mutate(species = if_else(
      is.na(species),
      species_original,
      species)) |>
   data.table::as.data.table()


# Metadata ----
meta <- meta |>
   left_join(y = dt |>
                select(dataset_id, regional, local, year) |>
                distinct(),
             join_by(dataset_id, regional, local, year))

# Checking metadata
unique(meta$taxon)
unique(meta$realm)

# Standardisation of period ----
# meta[ timepoints == 1L, period := 'first']
# meta[, ismax := timepoints == max(timepoints), by = .(dataset_id, regional, local)][ (ismax), period := 'last'][, ismax := NULL]
# meta[ !period %in% c('first','last'), period := 'intermediate']
# if (!all(meta[, (check = which.max(year) == which.max(timepoints)), by = .(dataset_id, regional, local)]$check)) warning('meta timepoints order has to be checked')


# Converting alpha grain and gamma extent units ----
meta <- meta |>
   dtplyr::lazy_dt(immutable = FALSE) |>
   mutate(alpha_grain = as.numeric(alpha_grain),
          gamma_sum_grains = as.numeric(gamma_sum_grains),
          gamma_bounding_box = as.numeric(gamma_bounding_box)) |>
   mutate(
      alpha_grain = case_match(alpha_grain_unit,
                               "mile2" ~ alpha_grain / 0.00000038610,
                               "km2" ~ alpha_grain * 10^6,
                               "acres" ~ alpha_grain * 4046.856422,
                               "ha" ~ alpha_grain * 10^4,
                               "cm2" ~ alpha_grain / 10^4,
                               "mm2" ~ alpha_grain / 10^6,
                               "m2" ~ alpha_grain),
      alpha_grain_unit = NULL,
      gamma_sum_grains = case_match(gamma_sum_grains_unit,
                                    "m2" ~ gamma_sum_grains / 10^6,
                                    "mile2" ~ gamma_sum_grains * 2.589988,
                                    "ha" ~ gamma_sum_grains / 100,
                                    "acres" ~ gamma_sum_grains * 0.004046856422,
                                    "km2" ~ gamma_sum_grains),
      gamma_sum_grains_unit = NULL,
      gamma_bounding_box = case_match(gamma_bounding_box_unit,
                                      "m2" ~ gamma_bounding_box / 10^6,
                                      "mile2" ~ gamma_bounding_box * 2.589988,
                                      "ha" ~ gamma_bounding_box / 100,
                                      "acres" ~ gamma_bounding_box * 0.004046856422,
                                      "km2" ~ gamma_bounding_box),
      gamma_bounding_box_unit = NULL) |>
   rename(alpha_grain_m2 = alpha_grain,
          gamma_bounding_box_km2 = gamma_bounding_box,
          gamma_sum_grains_km2 = gamma_sum_grains) |>
   data.table::as.data.table()

meta[is.na(alpha_grain_m2), unique(dataset_id)]
meta[is.na(gamma_sum_grains_km2) & is.na(gamma_bounding_box_km2), unique(dataset_id)]

# Converting coordinates into a common format with parzer ----
meta <- left_join(
   x = meta,
   y = unique(meta[, .(latitude, longitude)]) |>
      mutate(lat = parzer::parse_lat(latitude),
             lon = parzer::parse_lon(longitude)),
   join_by(latitude, longitude)) |>
   mutate(latitude = NULL,
          longitude = NULL) |>
   rename(latitude = lat, longitude = lon)

# Coordinate scale ----
meta <- meta |>
   dtplyr::lazy_dt(immutable = FALSE) |>
   group_by(dataset_id, regional) |>
   mutate(is_coordinate_local_scale = n_distinct(latitude) != 1L &&
             n_distinct(longitude) != 1L) |>
   data.table::as.data.table()

# Checks ----

## checking duplicated rows ----
if (anyDuplicated(meta)) warning("Duplicated rows in metadata")

## checking taxon ----
if (any(meta[, n_distinct(taxon), by = dataset_id]$V1 != 1L)) warning(paste0("several taxa values in ", paste(meta[, n_distinct(taxon), by = dataset_id][V1 != 1L, dataset_id], collapse = ", ")))
if (any(!unique(meta$taxon) %in% c("Fish", "Invertebrates", "Plants", "Multiple taxa", "Birds", "Mammals", "Herpetofauna", "Marine plants"))) warning(paste0("Non standard taxon category in ", paste(unique(meta[!taxon %in% c("Fish", "Invertebrates", "Plants", "Multiple taxa", "Birds", "Mammals", "Herpetofauna", "Marine plants"), .(dataset_id), by = dataset_id]$dataset_id), collapse = ", ")))

## checking encoding ----
for (i in seq_along(lst_metadata)) if (any(!unlist(unique(apply(lst_metadata[[i]][, c("local", "regional", "comment")], 2L, Encoding))) %in% c("UTF-8", "unknown"))) warning(paste0("Encoding issue in ", listfiles[i]))

## checking year range homogeneity among regions ----
if (any(meta[, length(unique(paste(range(year), collapse = "-"))), by = .(dataset_id, regional)]$V1 != 1L)) warning("all local scale sites were not sampled for the same years and timepoints has to be consistent with years")

## checking effort ----
unique(meta[effort == "unknown" | is.na(effort), .(dataset_id, effort)])
# all(meta[(checklist), effort] == 1)

## checking data_pooled_by_authors ----
meta[is.na(data_pooled_by_authors), data_pooled_by_authors := FALSE]
# if (any(meta[(data_pooled_by_authors), is.na(sampling_years)])) warning("Missing sampling_years values")
if (any(meta[(data_pooled_by_authors), is.na(data_pooled_by_authors_comment)])) warning(paste("Missing data_pooled_by_authors_comment values in", meta[(data_pooled_by_authors) & is.na(data_pooled_by_authors_comment), paste(unique(dataset_id), collapse = ", ")]))


## checking comment ----
if (anyNA(meta$comment)) warning("Missing comment value")
if (n_distinct(meta$comment) != n_distinct(meta$dataset_id)) warning("Redundant comment values")

## checking comment_standardisation ----
if (anyNA(meta$comment_standardisation)) warning("Missing comment_standardisation value")

## checking alpha_grain_type ----
# meta[(!checklist), .(lterm = diff(range(year)), taxon = taxon, realm = realm, alpha_grain_type = alpha_grain_type), by = .(dataset_id, regional)][lterm >= 10L][taxon == "Fish" & realm == "Freshwater" & grep("lake",alpha_grain_type), unique(dataset_id)]
if (any(!unique(meta$alpha_grain_type) %in% c("island", "plot", "administrative", "watershed", "sample", "lake_pond", "archipelago", "trap", "transect", "ecosystem", "functional", "box", "quadrat"))) warning(paste("Invalid alpha_grain_type value in", paste(unique(meta[!alpha_grain_type %in% c("island", "plot", "administrative", "watershed", "sample", "lake_pond", "archipelago", "trap", "transect", "ecosystem", "functional", "box", "quadrat"), dataset_id]), collapse = ", ")))

## checking gamma_sum_grains_type & gamma_bounding_box_type ----
if (any(!na.omit(unique(meta$gamma_sum_grains_type)) %in% c("archipelago", "administrative", "watershed", "sample", "lake_pond", "plot", "quadrat", "transect", "ecosystem", "functional", "box"))) warning(paste("Invalid gamma_sum_grains_type value in", paste(unique(meta[!is.na(gamma_sum_grains_type) & !gamma_sum_grains_type %in% c("archipelago", "administrative", "watershed", "sample", "lake_pond", "plot", "quadrat", "transect", "ecosystem", "functional", "box"), dataset_id]), collapse = ", ")))

if (any(!na.omit(unique(meta$gamma_bounding_box_type)) %in% c("administrative", "island", "functional", "convex-hull", "watershed", "box", "buffer", "ecosystem", "shore", "lake_pond"))) warning(paste("Invalid gamma_bounding_box_type value in", paste(unique(meta[!is.na(gamma_bounding_box_type) & !gamma_bounding_box_type %in% c("administrative", "island", "functional", "convex-hull", "watershed", "box", "buffer", "ecosystem", "shore", "lake_pond"), dataset_id]), collapse = ", ")))

# Ordering metadata ----
data.table::setorder(meta, dataset_id, regional, local, year)
data.table::setcolorder(
   meta,
   base::intersect(column_names_template_metadata, colnames(meta))
)

# Adding a unique ID ----
source(file = "R/functions/assign_id.R")
meta <- meta |>
   mutate(ID =  assign_id(dataset_id, regional))
dt <- dt |>
   mutate(ID =  assign_id(dataset_id, regional))

# Checking that all data sets have both community and metadata data ----
if (length(base::setdiff(unique(dt$dataset_id), unique(meta$dataset_id))) > 0L) warning("Incomplete community or metadata tables")
if (nrow(meta) != nrow(unique(meta[, .(dataset_id, regional, local, year)]))) warning("Redundant rows in meta")
if (nrow(meta) != nrow(unique(dt[, .(dataset_id, regional, local, year)]))) warning("Discrepancies between dt and meta")

# Saving data products ----
## Saving dt ----
data.table::setcolorder(dt, c("ID", "dataset_id", "regional", "local", "year",
                              "species", "species_original"))
# data.table::fwrite(dt, "data/communities.csv", row.names = FALSE)
base::saveRDS(object = dt, file = "data/communities.rds")
if (file.exists("data/references/homogenisation_dropbox_folder_path.rds")) {
   path_to_homogenisation_dropbox_folder <- base::readRDS(file = "data/references/homogenisation_dropbox_folder_path.rds")
   data.table::fwrite(
      x = dt,
      file = paste0(path_to_homogenisation_dropbox_folder, "/_data_extraction/checklist_change_communities.csv"),
      row.names = FALSE,
      sep = ",",
      encoding = "UTF-8")
}

## Saving meta ----
data.table::setcolorder(meta, "ID", neworder = 1L)
data.table::setcolorder(meta, "alpha_grain_m2",
                        before = "alpha_grain_type")
data.table::setcolorder(meta, "gamma_sum_grains_km2",
                        before = "gamma_sum_grains_type")
data.table::setcolorder(meta, "gamma_bounding_box_km2",
                        before = "gamma_bounding_box_type")
# data.table::fwrite(meta, "data/metadata.csv", sep = ",", row.names = FALSE)
base::saveRDS(object = meta, file = "data/metadata.rds")
if (file.exists("data/references/homogenisation_dropbox_folder_path.rds"))
   data.table::fwrite(
      x = meta,
      file = paste0(path_to_homogenisation_dropbox_folder, "/_data_extraction/checklist_change_metadata.csv"),
      sep = ",",
      row.names = FALSE,
      encoding = "UTF-8")
