## merging Wrangled data.frames

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

lst <- lapply(listfiles, data.table::fread, integer64 = "character", encoding = "UTF-8")
dt <- data.table::rbindlist(lst, fill = TRUE)

template_metadata <- utils::read.csv("data/template_metadata.txt", header = TRUE, sep = "\t")
column_names_template_metadata <- template_metadata[, 1L]

lst_metadata <- lapply(listfiles_metadata,
                       data.table::fread,
                       integer64 = "character",
                       encoding = "UTF-8", sep = ",")
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
if (any(is.na(dt$year))) warning(paste("missing _year_ value in ", unique(dt[is.na(year), dataset_id]), collapse = ", "))
if (any(is.na(meta$year))) warning(paste("missing _year_ value in ", unique(meta[is.na(year), dataset_id]), collapse = ", "))
if (any(dt[, .(is.na(regional) | regional == "")])) warning(paste("missing _regional_ value in ", unique(dt[is.na(regional) | regional == "", dataset_id]), collapse = ", "))
if (any(dt[, .(is.na(local) | local == "")])) warning(paste("missing _local_ value in ", unique(dt[is.na(local) | local == "", dataset_id]), collapse = ", "))
if (any(dt[, .(is.na(species) | species == "")])) warning(paste("missing _species_  value in ", unique(dt[is.na(species) | species == "", dataset_id]), collapse = ", "))
if (any(dt[, .(is.na(value) | value == "" | value <= 0)])) warning(paste("missing _value_  value in ", unique(dt[is.na(value) | value == "" | value <= 0, dataset_id]), collapse = ", "))

## Counting the study cases ----
dt[j = .(nsites = data.table::uniqueN(local)),
   keyby = dataset_id][order(nsites, decreasing = TRUE)]

# Ordering ----
# data.table::setcolorder(dt, intersect(column_names_template, colnames(dt)))
data.table::setorder(dt, dataset_id, regional, local, year, species)

# Deleting special characters in regional and local ----
# dt[, ":="(
#   local = iconv(local, from = "UTF-8", to = "ASCII")
# )]

# Standardisation of timepoints ----
# dt[, timepoints := as.integer(gsub('T', '', timepoints))]

# Checks
## checking values ----
if (dt[, any(value != 1L)]) warning(paste("Non integer values in", paste(dt[value != 1L, unique(dataset_id)], collapse = ", ")))

## checking timepoints ----
# if (!all(dt[, (check = which.max(year) == which.max(timepoints)), by = .(dataset_id, regional, local)]$check)) warning('dt timepoints order has to be checked')

## checking species names ----
for (i in seq_along(lst)) if (is.character(lst[[i]]$species)) if (any(!unique(Encoding(lst[[i]]$species)) %in% c("UTF-8", "unknown"))) warning(paste0("Encoding issue in ", listfiles[i]))

### adding GBIF matched names by Dr. Wubing Xu ----
corrected_species_names <- data.table::fread(
   file = "data/requests to taxonomy databases/manual_checklist_change_species_filled_20240104.csv",
   select = c("dataset_id", "species", "species_new"),
   header = TRUE, sep = ",")
dt[i = corrected_species_names,
   j = ":="(
      species = i.species_new,
      species_original = species
   ),
   on = .(dataset_id, species)]
dt[is.na(species), species := species_original]


# Metadata ----
meta <- merge(meta, unique(dt[, .(dataset_id, regional, local, year)]), all.x = TRUE)

# Checking metadata
unique(meta$taxon)
unique(meta$realm)

# Standardisation of period ----
# meta[ timepoints == 1L, period := 'first']
# meta[, ismax := timepoints == max(timepoints), by = .(dataset_id, regional, local)][ (ismax), period := 'last'][, ismax := NULL]
# meta[ !period %in% c('first','last'), period := 'intermediate']
# if (!all(meta[, (check = which.max(year) == which.max(timepoints)), by = .(dataset_id, regional, local)]$check)) warning('meta timepoints order has to be checked')


# Converting alpha grain and gamma extent units ----
meta[, alpha_grain := as.numeric(alpha_grain)][,
                                               alpha_grain := data.table::fcase(
                                                  alpha_grain_unit == "mile2", alpha_grain / 0.00000038610,
                                                  alpha_grain_unit == "km2", alpha_grain * 10^6,
                                                  alpha_grain_unit == "acres", alpha_grain * 4046.856422,
                                                  alpha_grain_unit == "ha", alpha_grain * 10^4,
                                                  alpha_grain_unit == "cm2", alpha_grain / 10^4,
                                                  alpha_grain_unit == "mm2", alpha_grain / 10^6,
                                                  alpha_grain_unit == "m2", alpha_grain
                                               )
][, alpha_grain_unit := NULL]

meta[, gamma_sum_grains := as.numeric(gamma_sum_grains)][,
                                                         gamma_sum_grains := data.table::fcase(
                                                            gamma_sum_grains_unit == "m2", gamma_sum_grains / 10^6,
                                                            gamma_sum_grains_unit == "mile2", gamma_sum_grains * 2.589988,
                                                            gamma_sum_grains_unit == "ha", gamma_sum_grains / 100,
                                                            gamma_sum_grains_unit == "acres", gamma_sum_grains * 0.004046856422,
                                                            gamma_sum_grains_unit == "km2", gamma_sum_grains
                                                         )
][, gamma_sum_grains_unit := NULL]

meta[, gamma_bounding_box := as.numeric(gamma_bounding_box)][,
                                                             gamma_bounding_box := data.table::fcase(
                                                                gamma_bounding_box_unit == "m2", gamma_bounding_box / 10^6,
                                                                gamma_bounding_box_unit == "mile2", gamma_bounding_box * 2.589988,
                                                                gamma_bounding_box_unit == "ha", gamma_bounding_box / 100,
                                                                gamma_bounding_box_unit == "acres", gamma_bounding_box * 0.004046856422,
                                                                gamma_bounding_box_unit == "km2", gamma_bounding_box
                                                             )
][, gamma_bounding_box_unit := NULL]

data.table::setnames(meta, c("alpha_grain", "gamma_bounding_box", "gamma_sum_grains"), c("alpha_grain_m2", "gamma_bounding_box_km2", "gamma_sum_grains_km2"))

meta[is.na(alpha_grain_m2), unique(dataset_id)]
meta[is.na(gamma_sum_grains_km2) & is.na(gamma_bounding_box_km2), unique(dataset_id)]

# Converting coordinates into a common format with parzer ----
unique_coordinates <- unique(meta[, .(latitude, longitude)])
unique_coordinates[, ":="(
   lat = parzer::parse_lat(latitude),
   lon = parzer::parse_lon(longitude)
)]
unique_coordinates[is.na(lat) | is.na(lon)]
meta <- merge(meta, unique_coordinates, by = c("latitude", "longitude"))
meta[, c("latitude", "longitude") := NULL]
data.table::setnames(meta, c("lat", "lon"), c("latitude", "longitude"))

# Coordinate scale ----
meta[, is_coordinate_local_scale := length(unique(latitude)) != 1L && length(unique(longitude)) != 1L, by = .(dataset_id, regional)]
# sort(meta[(!is_coordinate_local_scale) & (!checklist), unique(dataset_id)])

# Checks ----

## checking duplicated rows ----
if (anyDuplicated(meta)) warning("Duplicated rows in metadata")

## checking taxon ----
if (any(meta[, length(unique(taxon)), by = dataset_id]$V1 != 1L)) warning(paste0("several taxa values in ", paste(meta[, length(unique(taxon)), by = dataset_id][V1 != 1L, dataset_id], collapse = ", ")))
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
if (length(unique(meta$comment)) != length(unique(meta$dataset_id))) warning("Redundant comment values")

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
data.table::setcolorder(meta, base::intersect(column_names_template_metadata, colnames(meta)))



# Checking that all data sets have both community and metadata data ----
if (length(base::setdiff(unique(dt$dataset_id), unique(meta$dataset_id))) > 0L) warning("Incomplete community or metadata tables")
if (nrow(meta) != nrow(unique(meta[, .(dataset_id, regional, local, year)]))) warning("Redundant rows in meta")
if (nrow(meta) != nrow(unique(dt[, .(dataset_id, regional, local, year)]))) warning("Discrepancies between dt and meta")

# Saving data products ----
## Saving dt ----
data.table::setcolorder(dt, c("dataset_id", "regional", "local", "year", "species", "species_original", "value"))
# data.table::fwrite(dt, "data/communities.csv", row.names = FALSE)
base::saveRDS(object = dt, file = "data/communities.rds")
if (file.exists("data/references/homogenisation_dropbox_folder_path.rds")) {
   path_to_homogenisation_dropbox_folder <- base::readRDS(file = "data/references/homogenisation_dropbox_folder_path.rds")
   data.table::fwrite(dt, paste0(path_to_homogenisation_dropbox_folder, "/_data_extraction/checklist_change_communities.csv"), row.names = FALSE)
}

## Saving meta ----
data.table::setcolorder(meta, "alpha_grain_m2", before = "alpha_grain_type")
data.table::setcolorder(meta, "gamma_sum_grains_km2", before = "gamma_sum_grains_type")
data.table::setcolorder(meta, "gamma_bounding_box_km2", before = "gamma_bounding_box_type")
# data.table::fwrite(meta, "data/metadata.csv", sep = ",", row.names = FALSE)
base::saveRDS(object = meta, file = "data/metadata.rds")
if (file.exists("data/references/homogenisation_dropbox_folder_path.rds"))
   data.table::fwrite(meta, paste0(path_to_homogenisation_dropbox_folder, "/_data_extraction/checklist_change_metadata.csv"), sep = ",", row.names = FALSE)
