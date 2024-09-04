# wiemers_2019
dataset_id <- "wiemers_2019"

ddata <- base::readRDS("data/raw data/wiemers_2019/ddata.rds")

# recoding, splitting and melting status
ddata[, DistributionStatus := c("historical+recent", "recent",
                                "historical")[match(
                                   x = DistributionStatus,
                                   table = c("Native", "Alien", "Extinct"))]]

ddata[, c("period1", "period2") := data.table::tstrsplit(
   DistributionStatus, split = "\\+")]

ddata <- data.table::melt(
   data = ddata,
   measure.vars = c("period1", "period2"),
   value.name = "period",
   na.rm = TRUE
)

# community data
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Europe",

   year = c(1700L, 2013L)[match(period, c("historical", "recent"))],

   period = NULL,
   variable = NULL,
   DistributionStatus = NULL
)]


# metadata
## alpha_grain
areas <- data.table::fread(
   file = "data/raw data/wiemers_2019/List_country_by_area_Wikipedia_table-1.csv",
   encoding = "UTF-8", sep = ",", header = TRUE
)
areas[, ":="(
   State = sub("\\*", "", State),
   `Total area (km2)` = as.numeric(sub(",", "", `Total area (km2)`))
)][
   match(c("Russia", "North Macedonia", "Turkey"), State, nomatch = 0),
   State := c("Russia (European part)", "Macedonia", "Turkey (European part)")
][, match_country := State %in% unique(ddata$local)]

## coordinates
coordinates <- data.table::fread(
   file = "data/raw data/wiemers_2019/coordinates.csv",
                                 skip = 1, sep = ",", header = TRUE)
coordinates[, c("latitude", "longitude") := data.table::tstrsplit(
   coordinates, split = ", ")]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   latitude = coordinates$latitude[match(local, coordinates$country)],
   longitude = coordinates$longitude[match(local, coordinates$country)],

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review",

   alpha_grain = areas$`Total area (km2)`[match(local, areas$State)],
   alpha_grain_unit = "km2",
   alpha_grain_type = "administrative",
   alpha_grain_comment = "country areas found in https://en.wikipedia.org/wiki/List_of_European_countries_by_area",

   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "administrative",
   gamma_sum_grains_comment = "sum of the European parts of all countries considered in geographical Europe",

   gamma_bounding_box = geosphere::areaPolygon(data.frame(coordinates$longitude, coordinates$latitude)[grDevices::chull(coordinates[, c("longitude", "latitude")]), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "Checklist of Butterflies species per European country: An updated checklist of the European Butterflies (Lepidoptera, Papilionoidea), Wiemers et al (https://doi.org/10.3897/zookeys.811.28712). Only the European part of Russia, Turkey, Georgia... is considered. Methodology and effort is considered comparable between countries.
We chose 1700 as the end of the historical period as it is considered the beginning of the industrialisation period.
Regional is Europe, local are countries",
   comment_standardisation = "Migrant and Uncertain species were treated as Absent",
   doi = 'https://doi.org/10.3897/zookeys.811.28712'
)]

meta[local == "Portugal: Azores", alpha_grain := 2351L][local == "Portugal: Madeira Islands", alpha_grain := 801L][local == "Spain: Canary Islands", alpha_grain := 7493L]

meta[, gamma_sum_grains := sum(areas[, `Total area (km2)`]) + sum(2351L, 801L, 7493L)]


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
