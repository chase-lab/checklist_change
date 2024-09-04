#' Creates and stores unique data set IDs
#'
#' @param dataset_id a vector of dataset_ids. Can be `factor` or `character`.
#' @param regional a vector of dataset_ids. Can be `factor` or `character`.
#' @returns A character vector of the same length as dataset_id  and regional
#' containing unique IDs
#' @details If a data set like `sagouis_2023` already has an ID and is then split
#' into `sagouis_2023a` and `sagouis_2023b`, these data sets will receive entirely new IDs.

assign_id <- function(dataset_id, regional) {
   base::stopifnot("dataset_id and regional must have the same length" =
                      base::length(dataset_id) == base::length(regional))
   base::stopifnot("dataset_id and regional must be either character or factor" =
                      base::is.element(base::class(dataset_id), c("character","factor")) &&
                      base::is.element(base::class(regional), c("character","factor")))

   ids <- base::paste(dataset_id, regional, sep = "_")

   # read saved codes
   unique_IDs <- base::readRDS(file = "data/unique_IDs.rds")

   # if there are new datasets, create a code for them and add them to the dictionary
   new_dataset_ids <- base::setdiff(ids, unique_IDs$unique_id)

   if (length(new_dataset_ids) != 0L && !base::is.null(new_dataset_ids)) {
      unique_IDs <- base::rbind(unique_IDs, data.table::data.table(
         ## add new dataset_ids to the dictionary
         new_dataset_ids,
         ## create new ID
         (base::max(unique_IDs$ID) + 1L) + base::seq_along(new_dataset_ids)
      ), use.names = FALSE)
      ## Save new version of the dictionary
      base::saveRDS(unique_IDs, file = "data/unique_IDs.rds")
   } # end if

   # assign IDs
   ids <- unique_IDs$ID[base::match(ids, unique_IDs$unique_id)]

   return(ids)
}

# # This section shows how the dictionary was built.
# x <- data.table::fread("data/metadata.csv", select = c("dataset_id", "regional"))
# x <- unique(x)
# x[j = unique_id := paste(dataset_id, regional, sep = "_")
#    ][j = ID := .GRP,
#      keyby = .(dataset_id, regional)]
# saveRDS(x[j = .(unique_id, ID)], file = "data/unique_IDs.rds")
