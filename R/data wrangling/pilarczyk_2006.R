## pilarczyk_2006

dataset_id <- "pilarczyk_2006"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
env <- read.csv(
   file = paste0("data/raw data/", dataset_id, "/", dataset_id, "_table_1.csv"),
   skip = 1L, h = F)[-1L, ]
env <- data.table::data.table(
   local = substr(stringi::stri_extract_first_regex(pattern = "[0-9]{5}", str = env), 4L, 5L),
   regional = data.table::fcase(
      grepl(" C ", env), "Choctawhatchee",
      grepl(" Y ", env), "Yellow",
      grepl(" C-E ", env), "Conecuh-Escambia"
   ),
   latitude = substr(env, nchar(env) - 23L, nchar(env) - 13L),
   longitude = substr(env, nchar(env) - 11L, nchar(env))
)
env[, ":="(
   latitude = sub("o", "°", latitude),
   longitude = sub("o", "°", longitude)
)]

## melting sites and time periods
ddata <- data.table::melt(
   data = ddata,
   id.vars = "species",
   variable.name = "temp",
   na.rm = TRUE
)
# splitting period and local
ddata[, c("local", "year") := data.table::tstrsplit(temp, " ")][, temp := NULL]

ddata <- ddata[value > 0 & value != ""]

ddata <- ddata[
   i = !ddata[
      j = .(nyear = data.table::uniqueN(year)),
      keyby = local][nyear < 2L],
   on = "local"]

ddata[i = env, j = regional := i.regional, on = .(local)]

ddata[, ":="(
   dataset_id = dataset_id,
   year = c(1999L, 2004L)[data.table::chmatch(year, c("1990s", "2004"))],

   species = sub("\\*", "", species),

   value = 1L
)]


meta <- unique(ddata[, .(dataset_id, local, regional, year)])
ddata[i = env,
      j = ":="(latitude = i.latitude,
               longitude = i.longitude),
      on = .(local)]

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

   gamma_bounding_box = c(2208L, 6608L, 9000L)[data.table::chmatch(regional, c("Yellow", "Choctawhatchee", "Conecuh-Escambia"))],
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "watershed",
   gamma_bounding_box_comment = "area of the three watersheds given by the authors",

   comment = "Extracted from Pilarczyk et al 2006 ( Megan M. Pilarczyk, Paul M. Stewart, Douglas N. Shelton, Holly N. Blalock-Herod, and James D. Williams 'Current and Recent Historical Freshwater Mussel Assemblages in the Gulf Coastal Plains,' Southeastern Naturalist 5(2), 205-226, (26 October 2006). https://doi.org/10.1656/1528-7092(2006)5[205:CARHFM]2.0.CO;2 ()) table 1 (table extraction with [tabulizer]). Effort seems to vary a lot between the 90s and 2004 but the authors committed to be exhaustive in both cases. In the 90s, there were several samplings between 1991 and 1999. The authors sampled at least 400 meter long stream stretches and we assumed they were on average 5 meter wide.
Regional are 3 river basins, close to each other, ending up in the gulf of Mexico, local are river segments.",
   comment_standardisation = "Abundances from recent samples were converted into presence-absence. Sites for which we have only historical or modern data were excluded.",
   doi = "https://doi.org/10.1656/1528-7092(2006)5[205:CARHFM]2.0.CO;2"
)][, gamma_sum_grains := sum(alpha_grain),
   keyby = .(regional, year)]
ddata[, c("latitude", "longitude") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
   row.names = FALSE
)

data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
   row.names = FALSE, sep = ","
)
