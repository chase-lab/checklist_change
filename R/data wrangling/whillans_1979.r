## whillans_1979
dataset_id <- "whillans_1979"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

ddata <- rbind(
   ddata[, .(
      species = c(historical, all),
      period = "historical"
   ), keyby = local],
   ddata[, .(
      species = c(contemporary, all),
      period = "contemporary"
   ), keyby = local]
)
ddata <- ddata[species != ""]

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Great Lakes",
   local = c("Toronto Bay", "Burlington Bay", "Inner Bay")[match(local, c(1:3))],

   value = 1L,

   year = c(1800L, 1975L)[match(period, c("historical", "contemporary"))],
   period = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Fish",
   realm = "Freshwater",

   latitude = c('43°37`57.43"N', '43°17`20.57"N',
                '42°40`3.49"N')[match(local,
                                      c("Toronto Bay", "Burlington Bay",
                                        "Inner Bay"))],
   longitude = c('79°22`0.58"W', '79°48`22.97"W',
                 '80°12`38.35"W')[match(local,
                                        c("Toronto Bay", "Burlington Bay",
                                          "Inner Bay"))],

   effort = 1L,

   alpha_grain = c(10.7, 29.1, 28)[match(local, c("Toronto Bay", "Burlington Bay",
                                                  "Inner Bay"))],
   alpha_grain_unit = "km2",
   alpha_grain_type = "ecosystem",
   alpha_grain_comment = "area of the bay given by the authors",

   gamma_sum_grains = sum(10.7, 29.1, 28),
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "ecosystem",
   gamma_sum_grains_comment = "sum of the areas of the 3 bays given by the authors",

   gamma_bounding_box = data.table::fifelse(
      local %in% c("Toronto Bay", "Burlington Bay"), 19000L, 25667L),
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "area of the Ontario and Erie lakes",

   comment = "Extracted from Whillans et al 1979 table 2, 3 & 4 (table extraction with [tabulizer]). The authors compiled the fish species compositional changes over time. We reconstructed historical and recent communities by considering that extinct species were only present in historical time and alien species only appeared in recent time. Regional is the lake in which the bay is located: Ontario for Toronto and Burlington bays, and Lake Erie for Inner Bay.
Regional is the great lake region, local are bays inside Lake Ontario or Lake Erie.
Full reference: T.H. Whillans, Historic Transformations of Fish Communities in Three Great Lakes Bays, Journal of Great Lakes Research, 5-2, 1979, 195-215, https://doi.org/10.1016/S0380-1330(79)72146-0",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.1016/S0380-1330(79)72146-0"
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
