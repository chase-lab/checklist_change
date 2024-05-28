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
testthat::test_that(desc = "data quality check - community data", code = {
   for (i in listfiles_community) {
      X <-  data.table::fread(file = i, sep = ",", dec = ".",
                              header = TRUE, stringsAsFactors = TRUE)
      testthat::expect_true(
         all(data.table::between(X$year, 1300L, 2023L)),
         info = paste("Year range", i))
      # testthat::expect_true(
      # all(X$value) == 1L, info = paste("Positive values", i))
      testthat::expect_equal(nlevels(X$dataset_id), 1L)
   }
})

## Meta data ----
testthat::test_that(desc = "data quality check - metadata data", code = {
   for (i in listfiles_metadata) {
      X <- data.table::fread(file = i, sep = ",", dec = ".",
                             header = TRUE, stringsAsFactors = TRUE)
      testthat::expect_true(
         all(data.table::between(X$year, 1300L, 2023L)),
         info = paste("Year range", i))
      testthat::expect_equal(nlevels(X$dataset_id), 1L)
      testthat::expect_equal(nlevels(X$taxon), 1L)
      testthat::expect_equal(nlevels(X$realm), 1L)
      testthat::expect_true(
         nlevels(X$alpha_grain_unit) == 1L ||
            nlevels(X$alpha_grain_unit) == 0L,
         info = paste("alpha_grain_unit is unique", i))
      testthat::expect_true(
         nlevels(X$alpha_grain_type) == 1L ||
            nlevels(X$alpha_grain_type) == 0L ||
            nlevels(X$alpha_grain_type) == 2L, # rosenblad a and b have two.
         info = paste("alpha_grain_type is unique", i))
      testthat::expect_true(
         nlevels(X$gamma_bounding_box_type) == 1L ||
            nlevels(X$gamma_bounding_box_type) == 0L,
         info = paste("gamma_bounding_box_type is unique", i))
      testthat::expect_true(
         nlevels(X$gamma_sum_grains_type) == 1L ||
            nlevels(X$gamma_sum_grains_type) == 0L,
         info = paste("gamma_sum_grains_type is unique", i))

      checkmate::expect_choice(
         x = levels(X$taxon),
         choices = c("Fish", "Invertebrates", "Plants", "Birds", "Mammals",
                     "Herpetofauna", "Marine plants"),
         info = paste("taxon is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$realm),
         choices = c("Terrestrial","Freshwater","Marine"),
         info = paste("realm is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$alpha_grain_type),
         choices = c("island", "plot", "sample", "lake_pond", "archipelago",
                     "watershed", "functional", "box",
                     "quadrat","administrative"),
         info = paste("alpha_grain_type is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$alpha_grain_unit),
         choices = c("acres", "mile2", "ha", "km2", "m2", "cm2"),
         info = paste("alpha_grain_unit is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$gamma_sum_grains_type),
         choices = c("archipelago", "sample", "lake_pond", "plot", "quadrat",
                     "transect", "functional", "box", "administrative",
                     "watershed"),
         info = paste("gamma_sum_grains_type is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$gamma_bounding_box_type),
         choices = c("administrative", "island", "functional", "convex-hull",
                     "watershed", "box", "buffer", "ecosystem",
                     "shore", "lake_pond"),
         info = paste("gamma_bounding_box_type is correct", i), null.ok = TRUE)
   }
})

# Testing ID uniqueness
testthat::test_that("ID is unique for each dataset_id/region combinaison", {
   meta <- data.table::fread(file = paste0(absolute_path, "/data/metadata.csv"),
                             header = TRUE, sep = ",", encoding = "UTF-8",
                             select = c("dataset_id","regional","ID"))
   testthat::expect_true(meta[
      j = data.table::uniqueN(ID),
      by = .(dataset_id, regional)
   ][j = all(V1)])
})

# Testing ID consistency
testthat::test_that("ID is consistent over time", {
meta <- data.table::fread(file = paste0(absolute_path, "/data/metadata.csv"),
                          header = TRUE, sep = ",", encoding = "UTF-8",
                          select = c("dataset_id","regional","ID"))
testthat::expect_equal(meta[
   i = dataset_id == "baiser_2017" & regional == "Antartic",
   j = unique(ID)], expected = 2L)
})
