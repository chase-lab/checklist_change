## tirvengadum_1985

dataset_id <- "tirvengadum_1985"

ddata <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/rdata.csv"),
   skip = 1, encoding = "Latin-1", header = TRUE, sep = ",")

# Deleting marine turtles and snake species
ddata <- ddata[!species %in% c("Chelonia mydas (Linné) (green turtle)",
                               "Dermochelys coriacea (Vandelli) (lute)",
                               "Eretmochelys imbricata (Linné) (Hawk's bill)",
                               "Pelamis platucus (Linné) (sea-snake)")]

# melting sites
ddata <- data.table::melt(data = ddata,
                          id.vars = "species",
                          value.name = "period_temp",
                          variable.name = "local",
                          na.rm = TRUE
)

# Converting codes and melting periods
ddata[, period_temp := data.table::fcase(
   period_temp == "e", "historical",
   period_temp == "a", "historical+recent",
   default = NA_character_)]

ddata[, c("temp1", "temp2") := data.table::tstrsplit(period_temp, "\\+")]

ddata <- data.table::melt(data = ddata,
                          id.vars = c("species", "local"),
                          measure.vars = c("temp1", "temp2"),
                          value.name = "period",
                          na.rm = TRUE
)

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Mascarene",
   local = enc2utf8(as.character(local)),

   species = enc2utf8(sub("\"\"", "", species)),




   year = c(1680L, 1980L)[match(period, c("historical", "recent"))],

   period = NULL,
   variable = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
latitudes <- parzer::parse_lat(c("21°06`52S", "20.02° S", "19°43`S", "19.850037°S"))
longitudes <- parzer::parse_lon(c('55°31`57"E', "57.5° E", "63°25`E", "57.783333°E"))

meta[, ":="(
   local = enc2utf8(as.character(local)),
   taxon = "Herpetofauna",
   realm = "Terrestrial",

   latitude = latitudes[match(local, c("La Réunion", "Mauritius",
                                       "Rodrigues", "Round Island"))],
   longitude = longitudes[match(local, c("La Réunion", "Mauritius",
                                         "Rodrigues", "Round Island"))],

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review for Mauritius and Reunion and checklist by the authors for Rodrigues and Round Island",

   alpha_grain = c(2511, 2040, 108, 1.69)[match(local, c("La Réunion", "Mauritius",
                                                         "Rodrigues", "Round Island"))],
   alpha_grain_unit = "km2",
   alpha_grain_type = "island",
   alpha_grain_comment = "area of the islands of La Reunion, Round Island, Mauritius and Rodrigues",

   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitudes, latitudes)[grDevices::chull(longitudes, latitudes), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   gamma_sum_grains = 4660.69,
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "sum of the areas the four islands",

   comment = "Extracted from Tirvengadum & Bour 1985 table 1 (species names extracted by OCR and pa written by hand).
Realm: even though realm is considered Terrestrial, freshwater frogs are included. Marine turtles and snakes were excluded.
METHODS: 'Reports from various sources in Mauritius and Reunion and a survey carried out by the authors in Rodrigues and in Round Island in 1980.'
Regional is the Mascarene Archipelago, local are 4 large islands. 'year' is inferred from the paper, written in 1980 and stating: 'Over the past three centuries with the advent of man followed by large settlement, the reptile populations of these islands [...] have suffered considerably'.
Full reference: Tirvengadum, DD. and Bour, R., Checklist of the herpetofauna of the Mascarene Islands, 1985, Atoll Research Bulletin 292: 49-60
",
   comment_standardisation = "Deleting marine turtles and snake species"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
   row.names = FALSE, bom = TRUE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
   row.names = FALSE, bom = TRUE
)
