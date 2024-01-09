## tissot_1999a
dataset_id <- "tissot_1999a"

ddata <- readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
data.table::setnames(ddata, 1, "species")

## melting sites
ddata <- data.table::melt(data = ddata,
                          id.vars = "species",
                          variable.name = "local_year"
)

## splitting local and year
ddata[j = c("local", "year") := data.table::tstrsplit(local_year, " ")][
   j = local_year := NULL]

## excluding useless rows (species names split on two rows are kept for now)
ddata <- ddata[grepl("inner|outer", local) &
                  !grepl("ae$|Unidentified", species) &
                  species != ""]

## reconstructing long species names
for (i in which(!grepl(" ", ddata$species) & grepl("^[A-Z]", ddata$species))) {
   ddata$species[i] <- paste(ddata$species[i], ddata$species[i + 1])
}
ddata <- ddata[grepl(" ", ddata$species) & grepl("^[A-Z]", ddata$species)]

ddata <- ddata[value != "0.000"]

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Pelekane Bay",

   value = 1L
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Fish",
   realm = "Marine",

   latitude = "20° 1'42.62 N",
   longitude = "155°49'25.60 W",

   effort = c(1000L, 5400L)[data.table::chmatch(year, c("1976", "1996"))],

   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Several plots or transects pooled per year",

   alpha_grain = c(1000L, 5400L)[data.table::chmatch(year, c("1976", "1996"))],
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = c("One survey of 1000 m2", "9 surveys of 3*200m2")[data.table::chmatch(year, c("1976", "1996"))],

   gamma_sum_grains = c(1000L, 5400L)[data.table::chmatch(year, c("1976", "1996"))] * 2L,
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_comment = "sum of inner and outer sampling areas",

   gamma_bounding_box = sum(7593L, 21651L, 2758L, 4375L, 12111L),
   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "functional",
   gamma_bounding_box_comment = "area of the Pelekane Bay according to the authors in Table 2.",

   comment = "Extracted from Tissot 1999. Authors compiled previous data from 1976 sampled by Chaney and colleagues (one survey of a 1000 m2 plot) and resurveyed the same part of the bay in 1996 by identifying fish along three 50*4m transect in 9 occasions in 3 days. The authors consider the methods comparable.
Regional is Pelakane Bay, Hawaii and local are transects.
Full references: BRIAN N. TISSOT, CHANGES IN THE MARINE HABITAT AND BIOTA OF PELEKANE BAY, HAWAI’I OVER A 20-YEAR PERIOD, 1999, U. S. FISH AND WILDLIFE SERVICE PACIFIC ISLANDS OFFICE HONOLULU, HAWAI’I
Chaney, D., D. Hemmes and R. Nolan. 1977. Physiography and marine fauna of inshore and intertidal areas in Puukohala Heiau National Historic Site. Tech. Report #13, Coop. National Park Resources Study Unit, Dept. of Botany, Univ. of Hawaii, Honolulu, Hawaii. 36 pp",
   comment_standardisation = "Unidentified species excluded"
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
