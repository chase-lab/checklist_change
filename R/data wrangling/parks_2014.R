dataset_id <- "parks_2014"

# Extracting data from pdf ----
if (!file.exists("data/raw data/parks_2014/table_list.rds")) {
   table_list <- tabulizer::extract_tables(
      file = "data/cache/parks_2014_AmMidNat_2014_Parks_historical_changes.pdf",
      pages = 8:13, method = "decide"
   )
   dir.create("data/raw data/parks_2014", showWarnings = FALSE)
   base::saveRDS(table_list, file = "data/raw data/parks_2014/table_list.rds")
} else {
   table_list <- readRDS("data/raw data/parks_2014/table_list.rds")
}

ddata <- data.table::rbindlist(
   lapply(table_list, data.table::as.data.table)
)

ddata <- ddata[, -1L]
ddata <- ddata[V2 != ""]
data.table::setnames(ddata, c(
   "species",
   paste(rep(c("Cedar", "Des Moines", "Iowa", "Maquoketa", "Wapsipinicon"), each = 2L),
         rep(c("H", "R"), 5),
         sep = "_"
   )
))

# Melting sites and periods ----
ddata <- data.table::melt(ddata, id.var = "species")

# Splitting sites and periods ----
ddata[, c("local", "period") := data.table::tstrsplit(variable, "_")]
ddata[, value := data.table::fifelse(
   test = value %in% c("â€”", "0(0.0)"),
   yes = NA_character_,
   no = value)]
ddata <- ddata[!is.na(value) & species != "Scientific name"]

# ddata table ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Iowa",


   year = c(1969L, 2011L)[match(period, c("H", "R"))],

   period = NULL,
   variable = NULL,
   value = NULL
)]

# metadata table ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])

latitudes <- parzer::parse_lat(c("40.38003N", "41.16005N", "41.72943N",
                                 "41.72943N", "42.18872N"))
longitudes <- parzer::parse_lon(c("91.42204W", "91.02379W", "90.31946W",
                                  "90.31946W", "90.30899W"))

meta[, ":="(
   taxon = "Fish",
   realm = "Freshwater",

   latitude = latitudes[match(local, c("Des Moines", "Iowa", "Cedar", "Wapsipinicon", "Maquoketa"))],
   longitude = longitudes[match(local, c("Des Moines", "Iowa", "Cedar", "Wapsipinicon", "Maquoketa"))],

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review",

   alpha_grain = c(37141.9, 32429.9, 20050.5, 6479.6, 4808.6)[match(local, c("Des Moines", "Iowa", "Cedar", "Wapsipinicon", "Maquoketa"))],
   alpha_grain_unit = "km2",
   alpha_grain_type = "watershed",
   alpha_grain_comment = "given by the authors in Table 1",

   gamma_sum_grains = sum(c(37141.9, 32429.9, 20050.5, 6479.6, 4808.6)),
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "watershed",
   gamma_sum_grains_comment = "sum of the areas of the sub watersheds",

   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitudes, latitudes)[grDevices::chull(longitudes, latitudes), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "Extracted from pdf article Timothy P Parks 'Historical Changes in Fish Assemblage Structure in Midwestern Nonwadeable Rivers', The American Midland Naturalist 171(1), 27-53, (1 January 2014). https://doi.org/10.1674/0003-0031-171.1.27. Authors aggregated historical (1884-1969) and recent (1990-2011) data from literature and databases: Fish data from 1884–2011 were gathered from a variety of sources and databases Historical and recent data were acquired from the Iowa GAP (IAGAP) database (Loan-Wilsey et al., 2005), which is the most comprehensive source of historical fish specie distribution data for Iowa’s streams and rivers. Additional fish occurrence data were acquired from Wilton (2004), Gelwicks (2006), Neebling and Quist (2010), and additional sampling completed by the authors during the summers of 2010 and 2011.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1674/0003-0031-171.1.27'
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
