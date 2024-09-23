# brito_2020
dataset_id <- "brito_2020"

ddata <- data.table::fread(
   file = "data/raw data/brito_2020/rdata.csv", encoding = "UTF-8",
   select = c(1L, 3L:6L), skip = 1L, header = TRUE
)
data.table::setnames(ddata, 1L, "species")

# melting sites
ddata <- data.table::melt(ddata,
                          id.vars = "species",
                          variable.name = "local",
                          value.name = "status"
)

# recoding, splitting and melting status
ddata[, status := c("historical&recent", "historical",
                    "recent", "recent")[data.table::chmatch(status, c("N", "NE",
                                                        "NNT", "NNE"))]][
   j = c("status", "status2") := data.table::tstrsplit(status, "&")]
ddata <- data.table::melt(
   data = ddata,
   id.vars = c("species", "local"),
   value.name = "period",
   na.rm = TRUE
)

# data
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Semiarid Brazil",

   year = c(1930L, 2017L)[data.table::chmatch(period, c("historical", "recent"))],

   species = gsub(" \\*| \u00A7| \u2051| \u2021", "", species),
   

   period = NULL,
   variable = NULL
)]


env <- data.table::data.table(
   local = c("Region I", "Region II", "Region III", "Region IV"),
   latitude = c(
      "8°14'S",
      "5.08°S",
      paste(mean(c(-5.74, parzer::parse_lat(c("7°10'S", "8°20'S")), -9.57)), "N"),
      paste(mean(c(-12, -10.56, parzer::parse_lat("19°49'S"))), "N")
   ),
   longitude = c(
      "43°6'W",
      "39.65°W",
      paste(mean(c(-36.55, parzer::parse_lon(c("36°50 W", "37°48'W")), -36.55)), "E"),
      paste(mean(c(-41, -37.36, parzer::parse_lon("43°57'W"))), "E")
   ),
   alpha_grain = c(
      251529.186,
      146348.3,
      sum(52796.791, 56584.6, 98311.616, 27767.7),
      sum(565733, 21910.4, 586528.29)
   )
)[, ":="(latitude = parzer::parse_lat(latitude),
         longitude = parzer::parse_lon(longitude))]

# metadata
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Fish",
   realm = "Freshwater",

   latitude = env$latitude[match(local, c("Region I", "Region II",
                                                        "Region III", "Region IV"))],
   longitude = env$longitude[match(local, c("Region I", "Region II",
                                                          "Region III", "Region IV"))],

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review",

   alpha_grain = env$alpha_grain[match(local, c("Region I", "Region II",
                                                              "Region III", "Region IV"))],
   alpha_grain_unit = "km2",
   alpha_grain_type = "administrative",
   alpha_grain_comment = "area of the administrative state",

   gamma_bounding_box = geosphere::areaPolygon(env[grDevices::chull(env[, c("longitude", "latitude")]), c("longitude", "latitude")]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates obtained from Wikipedia",

   gamma_sum_grains = sum(env$alpha_grain),
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "administrative",
   gamma_sum_grains_comment = "sum of the area of the states",


   comment = "Data were extracted by hand from Supp 1 (Brito, M.F.G., Daga, V.S. & Vitule, J.R.S. Fisheries and biotic homogenization of freshwater fish in the Brazilian semiarid region. Hydrobiologia 847, 3877–3895 (2020). https://doi.org/10.1007/s10750-020-04236-8) to a csv file. Areas and coordinates were retrieved from Wikipedia.
METHODS: 'We evaluated species records and fisheries through the technical reports compiled for 108 dams, spatially separated into four regions according to Brazilian states boundaries, following the DNOCS protocol, based on their location in the Brazilian states: Region I (Paui state), Region II (Ceara state), Region III (Rio Grande do Norte, Parai´ba, Pernambuco and Alagoas states), and Region IV (Bahia, Sergipe and Minas Gerais states)[...]Fish assemblages were sampled monthly at each dam, using gillnets, cast nets, and fish hooks. This represents a 64-year time period at the Inter-region scale (considering dams in all regions) (Table 1), and a 49-year time period at the Intra-region scale (considering dams within each region), except for Regions I and IV, which were only represented by 47-year and 31-year time periods, respectively (Table 1).'
The date 1930 was chosen as it is the year of the first reported introduction. Pre-1930 is thus theoretically invasive-fish-species-free. We assume no extinction appeared between 1930 and 1948.
Regional is 'Semiarid Brazil' and local are regions determined by the authors.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1007/s10750-020-04236-8'
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
