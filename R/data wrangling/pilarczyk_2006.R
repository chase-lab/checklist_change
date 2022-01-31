## pilarczyk_2006

dataset_id <- "pilarczyk_2006"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
env <- read.csv(paste0("data/raw data/", dataset_id, "/", dataset_id, "_table_1.csv"), skip = 1L, h = F)[-1L, ]
env <- data.table::data.table(
  local = substr(stringr::str_extract(pattern = "[0-9]{5}", string = env), 4L, 5L),
  regional = data.table::fifelse(
    grepl(" C ", env), "Choctawhatchee",
    data.table::fifelse(grepl(" Y ", env), "Yellow", "Conecuh-Escambia")
  ),
  latitude = substr(env, nchar(env) - 23L, nchar(env) - 13L),
  longitude = substr(env, nchar(env) - 11L, nchar(env))
)
env[, ":="(
  latitude = gsub("o", "°", latitude),
  longitude = gsub("o", "°", longitude)
)]

## melting sites and time periods
ddata <- data.table::melt(ddata,
  id.vars = "species",
  variable.name = "temp",
  na.rm = TRUE
)
# splitting period and local
ddata[, c("local", "year") := data.table::tstrsplit(temp, " ")][
  ,
  temp := NULL
]

ddata <- ddata[value > 0 & value != ""]

ddata <- ddata[ddata[, .(nyear = length(unique(year))), by = local][nyear == 2L][, local], on = "local"]

ddata <- merge(ddata, env[, .(local, regional)], by = "local", all.x = TRUE)


ddata[, ":="(
  dataset_id = dataset_id,
  year = as.numeric(gsub("s", "", year)),

  species = gsub("\\*", "", species),

  value = 1L

)]


meta <- unique(ddata[, .(dataset_id, local, year)])
meta <- merge(meta, env, by = "local")
meta[, ":="(
  realm = "Freshwater",
  taxon = "Invertebrates",

  effort = 1L,

  alpha_grain = 2000L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "400 meter minimal length of stream sampled according to the authors multiplied by 5 assumed to be the average width of the streams",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of sampled stream stretch areas per region and per year",

  gamma_bounding_box = c(2208L, 6608L, 9000L)[match(regional, c("Yellow", "Choctawhatchee", "Conecuh-Escambia"))],
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "watershed",
  gamma_bounding_box_comment = "area of the three watersheds given by the authors",

  comment = "Extracted from Pilarczyk et al 2006 table 1 (table extraction with [tabulizer]). Regional are 3 river basins, close to each other, ending up in the gulf of Mexico, local are river segments. Effort seems to vary a lot between the 90s and 2004 but the authors committed to be exhaustive in both cases. In the 90s, there were several samplings between 1991 and 1999. The authors sampled at least 400 meter long stream stretches and we assumed they were on average 5 meter wide. ",
  comment_standardisation = "Provided abundances for recent samples were converted into presence-absence. Sites for which we have only historical or modern data were excluded."
)][, gamma_sum_grains := 2000L * length(unique(local)), by = .(regional, year)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
