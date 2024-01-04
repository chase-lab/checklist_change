# Using testthat Edition 3
testthat::local_edition(3)
require(withr)
absolute_path <- rprojroot::find_rstudio_root_file()

## raw data ----
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


indispensable_variables <- sapply(X = c(
   paste0(absolute_path, "/data/template_communities.txt"),
   paste0(absolute_path, "/data/template_metadata.txt")),
   function(x) {
      tmp <- data.table::fread(
         file = x,
         sep = "\t", header = TRUE, stringsAsFactors = FALSE) |>
         _[i = (necessary), j = `variable name`]
   }, USE.NAMES = TRUE, simplify = FALSE)



# Tests ----
### Community data ----
testthat::test_that(
   desc = "no NA values - community data",
   code = {
      variables <- indispensable_variables[[paste0(
         absolute_path, "/data/template_communities.txt")]]

      for (i in listfiles_community) {
         testthat::expect_false(
            data.table::fread(
               file = i, sep = ",", dec = ".",
               header = TRUE, stringsAsFactors = TRUE
            )[j = lapply(.SD, checkmate::anyMissing),
              .SDcols = variables] |>
               base::any(),
            info = i
         )
      }
   })


### Meta data ----
testthat::skip()
testthat::test_that(
   desc = "no NA values - metadata",
   code = {
      variables <- indispensable_variables[[paste0(
         absolute_path, "/data/template_metadata.txt")]]

      for (i in listfiles_metadata) {
         testthat::expect_false(
            data.table::fread(
               file = i, sep = ",", dec = ".",
               header = TRUE, stringsAsFactors = TRUE
            )[j = lapply(.SD, checkmate::anyMissing),
              .SDcols = variables] |>
               base::any(),
            info = i
         )
      }
   })
