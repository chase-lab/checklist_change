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

# Tests ----
## Community data ----
testthat::test_that(desc = "no duplicates - community data", code = {
   for (i in listfiles_community) {
      testthat::expect_true(
         data.table::fread(
            file = i, sep = ",", dec = ".",
            header = TRUE, stringsAsFactors = TRUE
         )[, .N, by = .(regional, local, year, species)][, all(N == 1L)],
         info = i
      )
   }
})
testthat::test_that(desc = "no duplicates - community data", code = {
   for (i in listfiles_community) {
      testthat::expect_false(
         data.table::fread(
            file = i, sep = ",", dec = ".",
            header = TRUE, stringsAsFactors = TRUE
         ) |>
            duplicated() |>
            any(),
         info = i
      )
   }
})

## Meta data ----
testthat::test_that(desc = "no duplicates - metadata data", code = {
   for (i in listfiles_metadata) {
      testthat::expect_true(
         data.table::fread(
            file = i, sep = ",", dec = ".",
            header = TRUE, stringsAsFactors = TRUE
         )[, .N, by = .(regional, local, year)][, all(N == 1L)],
         info = i
      )
   }
})

testthat::test_that(desc = "no duplicates - metadata data", code = {
   for (i in listfiles_metadata) {
      testthat::expect_false(
         data.table::fread(
            file = i, sep = ",", dec = ".",
            header = TRUE, stringsAsFactors = TRUE
         ) |>
            duplicated() |>
            any(),
         info = i
      )
   }
})
