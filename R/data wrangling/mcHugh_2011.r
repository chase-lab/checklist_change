## mcHugh_2011


dataset_id <- "mcHugh_2011"

ddata <- data.table::fread(paste0("data/raw data/", dataset_id, "/rdata.csv"), skip = 1L)

## melting sites and time periods
ddata <- data.table::melt(ddata,
                          id.vars = "species",
                          measure.vars = c("historic BB", "historic WB", "modern BB", "modern WB"),
                          variable.name = "temp"
)

# splitting period and local
ddata[, c("period", "local") := data.table::tstrsplit(temp, " ")][
   ,
   temp := NULL
]

effort <- data.table::data.table(
   period = c("historic", "modern"),
   "BB" = c(
      2 * 46 + 2 * 60 + 2 * 33,
      5 * 19 + 6 * 20 + 5 * 20 + 6 * 20 + 5 * 20 + 6 * 20
   ),
   "WB" = c(
      2 * 52 + 4 * 43 + 6 * 77 + 75 + 3 * 63 + 2 * 45 + 30 + 2 * 25 + 2 * 32 + 30,
      7 * 20 + 5 * 20 + 6 * 20 + 6 * 20 + 6 * 20 + 6 * 20
   )
)
effort <- data.table::melt(effort, id.vars = "period", value.name = "effort", variable.name = "local")
ddata <- merge(ddata, effort, by = c("local", "period"))

ddata <- ddata[!is.na(value) & value > 0]


ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Western English Channel",
   local = c("Bigbury Bay", "Whitsand Bay")[data.table::chmatch(local, c("BB", "WB"))],

   year = c(1922L, 2009L)[data.table::chmatch(period, c("historic", "modern"))],

   value = 1L,
   period = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year, effort)])
meta[, ":="(
   taxon = "Fish",
   realm = "Marine",

   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "several trawls per year, several years per period",
   sampling_years = c("1913-1922", "2008-2009")[match(year, c(1922L, 2009L))],

   latitude = c("50°15'N", "50°20'N")[data.table::chmatch(local, c("Bigbury Bay", "Whitsand Bay"))],
   longitude = c("04°05’W", "04°15’W")[data.table::chmatch(local, c("Bigbury Bay", "Whitsand Bay"))],

   alpha_grain = c(2.76, 2.83)[data.table::chmatch(local, c("Bigbury Bay", "Whitsand Bay"))],
   alpha_grain_unit = "km2",
   alpha_grain_type = "box",
   alpha_grain_comment = "area of the boxes encompassing all trawls of the resurvey for Bigbury and Whitsand bays as given by the authors",

   gamma_sum_grains = sum(2.76, 2.83),
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "box",

   gamma_bounding_box = 120L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "area of a box roughly covering the three sampling zones",

   comment = "Extracted from mcHugh et al 2011 table 3 (table extraction). Authors compiled fish community composition and trawling effort from historical records and resurveyed the same areas with methodological and effort consistency in mind. Regional is the Western English Channel, near Plymouth, local are two bays, years correspond to the last year of two sampling periods (1913-1922, 2008-2009). Effort is the sum of trawling hours per site per campaign see table 1. CPUEs are given by the authors but only presence absence is used here.",
   comment_standardisation = "none needed"
)]

ddata[, effort := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
