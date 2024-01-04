## gido_2010
dataset_id <- "gido_2010"
ddata <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/rdata.csv"),
   skip = 1L)

## melting sites and time periods
ddata <- data.table::melt(
   data = ddata,
   id.vars = "species",
   measure.vars = c(
      "1963-1977;Lower Kansas River Basin", "1978-1990;Lower Kansas River Basin", "1991-2003;Lower Kansas River Basin",
      "1947-1962;Smoky Hill", "1963-1977;Smoky Hill", "1978-1990;Smoky Hill", "1991-2003;Smoky Hill",
      "1947-1962;Arkansas Basin", "1963-1977;Arkansas Basin", "1978-1990;Arkansas Basin", "1991-2003;Arkansas Basin"
   ),
   variable.name = "temp"
)
# splitting period and local
ddata[j = c("period", "local") := data.table::tstrsplit(temp, ";")][
   j = temp := NULL]


effort <- data.table::data.table(
   period = c("1947-1962", "1963-1977", "1978-1990", "1991-2003"),
   "Smoky Hill" = c(22, 12, 26, 147),
   "Arkansas Basin" = c(34, 23, 71, 370),
   "Lower Kansas River Basin" = c(79, 52, 64, 277)
)

effort <- data.table::melt(data = effort,
                           id.vars = "period",
                           value.name = "effort",
                           variable.name = "local")

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Kansas",

   year = substr(period, 6, 10),

   value = data.table::fifelse(
      test = as.numeric(gsub("[[:alpha:]]|\n|,", "", value)) > 0,
      yes = 1L,
      no = NA_integer_)
)]

ddata <- ddata[!is.na(value) & value > 0]

meta <- unique(ddata[, .(dataset_id, regional, local, period, year)])
meta <- merge(meta, effort, by = c("local", "period"))

meta[, ":="(
   realm = "Freshwater",
   taxon = "Fish",

   latitude = c("39.3 N", "38 N", "39.25 N")[match(local, c("Smoky Hill", "Arkansas Basin", "Lower Kansas River Basin"))],
   longitude = c("100 W", "100 W", "96 W")[match(local, c("Smoky Hill", "Arkansas Basin", "Lower Kansas River Basin"))],

   alpha_grain = c(53416L, 59752L, 22352L)[match(local, c("Smoky Hill", "Arkansas Basin", "Lower Kansas River Basin"))],
   alpha_grain_unit = "km2",
   alpha_grain_type = "watershed",
   alpha_grain_comment = "area of a rectangle roughly corresponding to the area of the watershed, station scale not available, data aggregated at the (large) watershed level",

   gamma_sum_grains = sum(53416L, 59752L, 22352L),
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "watershed",
   gamma_sum_grains_comment = "sum of the area of the 3 watersheds",

   gamma_bounding_box = 213100L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "area of the state of Kansas",

   comment = "Extracted from appendix of Retrospective analysis of fish community change during a half-century of landuse and streamflow changes. Keith B. Gido, Walter K. Dodds, and Mark E. Eberle. Journal of the North American Benthological Society 2010 29:3, 970-987.
METHODS: 'Fish collections between 1947 and 2003 included 1127 community samples (presence–absence) with 93 total species in Kansas (Table 1). Native fish were identified from historical accounts (Hay 1887, Cross 1967, Cross et al. 1986), and these data were supplemented with additional historical records (Eberle 2007). Most historical fish collection records (prior to 1991) were taken directly from field notes of Frank Cross, who began collecting in Kansas in 1951, but these data were supplemented by collection records provided by the University of Kansas Natural History Museum and Sternberg Museum of Natural History. Recent records were based primarily on surveys by the Kansas Department of Wildlife and Parks, supplemented by various collectors with other governmental agencies and universities.'
Effort is the number of fish collection per local per period
Regional is Kansas, local are whole river basins (within Kansas state borders)",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1899/09-116.1'
)]

ddata[, period := NULL]
meta[, period := NULL]

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
