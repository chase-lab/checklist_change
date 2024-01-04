# Using testthat Edition 3
testthat::local_edition(3)
require(withr)
absolute_path <- rprojroot::find_rstudio_root_file()

listfiles_community <- list.files(
   path = paste0(absolute_path, "/data/wrangled data"),
   pattern = "[0-9]{4}[abc]?.csv",
   full.names = TRUE, recursive = TRUE
)

listfiles_metadata <- list.files(
   path = paste0(absolute_path, "/data/wrangled data"),
   pattern = "metadata.csv",
   full.names = TRUE, recursive = TRUE
)

# Testing column names ----
## community data ----
lst_column_names_community <- sapply(
   X = listfiles_community,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
   sep = ",", nrows = 1L, header = FALSE
)

template_community <- utils::read.table(
   file = paste0(absolute_path, "/data/template_communities.txt"),
   header = TRUE, sep = "\t")
reference_column_names_community <- template_community[, 1L]

testthat::test_that(
   desc = "only valid column names - community data - raw data",
   code = {
      for (i in listfiles_community) {
         testthat::expect_true(
            all(is.element(
               el = lst_column_names_community[[i]],
               set = reference_column_names_community)),
            info = i
         )
      }
   })



## metadata ----
lst_column_names_metadata <- sapply(
   X = listfiles_metadata,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8", sep = ",", nrows = 1L, header = FALSE
)

template_metadata <- utils::read.table(
   file = paste0(absolute_path, "/data/template_metadata.txt"),
   header = TRUE, sep = "\t")
reference_column_names_metadata <- template_metadata[, 1L]

testthat::test_that(
   desc = "only valid column names - metadata - raw data",
   code = {
      for (i in listfiles_metadata) {
         testthat::expect_true(
            all(is.element(el = lst_column_names_metadata[[i]],
                           set = reference_column_names_metadata)),
            info = i
         )
      }
   })

# Testing data dimension ----

lst_first_column_community <- sapply(
   X = listfiles_community,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
   sep = ",", select = 1L, header = FALSE, stringsAsFactors = TRUE
)

lst_first_column_metadata <- sapply(
   X = listfiles_metadata,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
   sep = ",", select = 1L, header = FALSE, stringsAsFactors = TRUE
)

testthat::test_that(
   desc = "ddata has more rows than meta - raw data",
   code = {
      testthat::expect_gte(
         sum(unlist(lapply(lst_first_column_community, length))),
         sum(unlist(lapply(lst_first_column_metadata,  length)))
      )}
)
