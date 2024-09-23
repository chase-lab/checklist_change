## rosenblad_2016a
dataset_id <- "rosenblad_2016a"
ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(x = ddata, old = "Scientific name", new = "species")

ddata <- unique(data.table::melt(
   data = ddata,
   variable.name = "local",
   measure.vars = 2:ncol(ddata),
   measure.name = "value",
   na.rm = TRUE
))

ddata[, c("local", "period") := data.table::tstrsplit(local, ": ")]

ddata[, ":="(
   dataset_id = dataset_id,

   regional = "global",
   local = c("New Zealand", "Northern Line Islands", "Tristan da Cunha", "Nauru",
             "Pitcairn Island", "Norfolk Island", "Lord Howe Island",
             "Hawaiian Islands", "Christmas Island", "Cocos (Keeling) Islands",
             "Easter Island")[match(local, c("New Zealand", "Northern Line",
                                             "Tristan da Cunha", "Nauru",
                                             "Pitcairn", "Norfolk", "Lord Howe",
                                             "Hawaii", "Christmas", "Cocos", "Easter"))],

   year = c(1500L, 2016L)[match(period, c("present initially", "present currently"))],

   period = NULL,
   value = NULL
)]


local_names <- c("Ascension Island", "Chatham Islands", "Christmas Island",
                 "Cocos (Keeling) Islands", "Cook Islands", "Easter Island",
                 "Fiji", "Galapagos Islands", "Guam", "Hawaiian Islands",
                 "Lord Howe Island", "Marquesas Islands", "Mauritius", "Nauru",
                 "New Zealand", "Norfolk Island", "Northern Line Islands", "
                 Pitcairn Island", "Reunion", "Rodrigues", "Saint Helena",
                 "Samoa", "Society Islands", "Tonga", "Tristan da Cunha")
latitudes <- parzer::parse_lat(c("7°56`S", "44°02`S", '10°25`18"S', '12°11`13"S',
                                 "21°12`S", "27°7`S", "18°10`S", "0°40`S", "13°30 N",
                                 "21° N", '31°33`15"S', "9.7812° S", "20.2°S",
                                 "0°32`S", "41°18`S", "29.03°S", "4°N", '25°04`00"S',
                                 '21°06`52"S', "19°43`S", "15°56`S", "-14.266667 N",
                                 "17°32`S", "21°08`S", "37°4`S"))
longitudes <- parzer::parse_lon(c("14°25`W", "176°26`W", '105°40`41"E', '96°49`42"E',
                                  "159°46`W", "109°22`W", "178°27`E", "90°33`W",
                                  "144°48 E", "157° W", '159°05`06"E', "139.0817° W",
                                  "57.5°E", "166°55`E", "174°47`E", "167.95°E",
                                  "160°W", '130°06`00"W', '55°31`57"E', "63°25`E",
                                  "05°43`W", "-171.2 E", "149°50`W", "175°12`W",
                                  "12°19`W"))

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   latitude = latitudes[match(local, local_names)],
   longitude = longitudes[match(local, local_names)],

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review",

   alpha_grain = c(88, 966, 135, 14, 236.7, 163.6, 18274, 7880, 540, 16636, 14.55,
                   1049.3, 2040, 21, 268021, 34.6, sum(4, 9.55, 33.73, 388.39),4.6,
                   2511, 108, 121, 3030, 1590, 748, 207)[match(local, local_names)],
   alpha_grain_unit = "km2",
   alpha_grain_type = data.table::fifelse(
      test = local %in% c("Ascension Island", "Christmas Island", "Easter Island",
                          "Guam", "Lord Howe Island", "Mauritius", "Nauru",
                          "Norfolk Island", "Pitcairn Island", "Reunion",
                          "Rodrigues", "Saint Helena"),
      yes = "island",
      no = "archipelago"),
   alpha_grain_comment = "area of the sampled islands and for archipelagos: sum of the areas of the islands",

   gamma_sum_grains = sum(c(88, 966, 135, 14, 236.7, 163.6, 18274, 7880, 540, 16636,
                            14.55, 1049.3, 2040, 21, 268021, 34.6,
                            sum(4, 9.55,33.73, 388.39), 4.6, 2511, 108, 121, 3030,
                            1590, 748, 207)),
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "Sum of the areas of the islands",

   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitudes, latitudes)[grDevices::chull(longitudes, latitudes), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "Extracted from Rosenblad, Kyle C.; Sax, Dov F. (2016). Data from: A new framework for investigating biotic homogenization and exploring future trajectories: oceanic island plant and bird assemblages as a case study [Dataset]. Dryad. https://doi.org/10.5061/dryad.c9s61.
Sampling 'year' is not provided by the authors and historical times are considered to be before human influence and recent period after human influence.
Regional is global, local are islands or archipelagos.",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.5061/dryad.c9s61 | https://doi.org/10.1111/ecog.02652"
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
