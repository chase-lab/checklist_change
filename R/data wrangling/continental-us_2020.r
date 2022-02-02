## continental-us_2020
dataset_id <- "continental-us_2020"

# Loading the list of US states ----
state_dictionnary <- data.table::fread("./data/raw data/continental-us_2020/state dictionnary.csv", skip = 1, header = TRUE)
data.table::setnames(state_dictionnary, c("Name of region", "ANSI"), c("long", "short")) # warning is OK
state_dictionnary[long == "District of Columbia", long := "Washington DC"]
state_dictionnary[, Location := gsub("^.*/ \\?", "", Location)][, c("latitude", "longitude") := data.table::tstrsplit(Location, " ")]

state_area <- data.table::fread("./data/raw data/continental-us_2020/state area.csv", skip = 1, header = TRUE)
data.table::setnames(state_area, c(1L, 4L), c("long", "area")) # warning is OK
state_area[long == "District of Columbia", long := "Washington DC"]
state_area[, area := as.integer(gsub(",", "", area))]

# Loading alien species from GLONAF ----
ddata_alien <- read.csv(
  text = paste0(
    stringi::stri_read_lines(
      "./data/cache/continental-us_2020/glonaf/glonaf/GLONAF/Taxon_x_List_GloNAF_vanKleunenetal2018Ecology.csv",
      encoding = "UTF-16LE"
    ),
    collapse = "\n"
  ),
  sep = "\t",
  stringsAsFactors = FALSE
)
data.table::setDT(ddata_alien)

regions <- data.table::fread("./data/cache/continental-us_2020/glonaf/glonaf/GLONAF/Region_GloNAF_vanKleunenetal2018Ecology.csv")

ddata_alien <- merge(ddata_alien, regions[, .(region_id, country, name)])
ddata_alien <- ddata_alien[country == "United States of America (the)"]

data.table::setnames(ddata_alien, c("name", "standardized_name"), c("local", "species")) #
ddata_alien <- ddata_alien[local %in% unlist(state_dictionnary[c(1, 3:50), "long"])]
ddata_alien[, ":="(
  period = "present",
  species = gsub(" var. .*$| ssp. .*$| subsp. .*$", "", species),

  region_id = NULL,
  taxon_orig = NULL,
  tpl_input = NULL,
  TPL_Plant_Name_Index = NULL,
  author = NULL,
  hybrid = NULL,
  family_tpl = NULL,
  name_status = NULL,
  list_id = NULL,
  status = NULL,
  country = NULL
)]
lstsp <- unique(ddata_alien$species)






# Loading extinctions from knapp et al ----
ddata_extinction <- base::readRDS(paste0("./data/raw data/", dataset_id, "/ddata_extinction.rds"))
ddata_extinction[, local := trimws(gsub(" & ", ", ", local))]
ddata_extinction[, paste("tmp", 1:7) := data.table::tstrsplit(local, ", ")]
ddata_extinction <- data.table::melt(ddata_extinction,
  id.vars = "species",
  measure.vars = paste("tmp", 1:7),
  value.name = "local",
  na.rm = TRUE
)


ddata_extinction[, ":="(local = state_dictionnary$long[match(local, state_dictionnary$short)],
  species = unlist(stringi::stri_extract_all_regex(species, "^[A-Za-z]+ [a-z]+")), # 'Genus species' only
  matchl = species %in% lstsp,
  period = "historical",
  variable = NULL
)]
ddata_extinction <- ddata_extinction[!is.na(local)] # exclusion of Mexico and Ontario

## * check if extinct species were originally present in the glonaf data set: ----
# ddata_extinction$species %in% ddata_alien$species

if (file.exists("./data/requests to taxonomy databases/continental-us_2020 synonym pow request")) {
  load("./data/requests to taxonomy databases/continental-us_2020 synonym pow request")
} else {
  # synitis <- taxize::synonyms(sci_id = y, db = 'itis')
  synpow <- taxize::synonyms(sci_id = y, db = "pow")
  # Astralagus robbinsii - 3 -  urn:lsid:ipni.org:names:30066006-2
  # Prunus maritima - 1 - urn:lsid:ipni.org:names:30034170-2
  # Tephrosia angustissima - 1 - urn:lsid:ipni.org:names:520382-1
  synpow <- data.table::rbindlist(synpow, idcol = TRUE, use.names = TRUE)

  # save(synitis, file = './data/requests to taxonomy databases/continental-us_2020 synonym itis request')
  save(synpow, file = "./data/requests to taxonomy databases/continental-us_2020 synonym pow request")
}

synpow[, ":="(
  species = .id,
  synonyms = stringi::stri_extract_all_regex(name, "^[A-Za-z-?]+ [a-z-?]+", simplify = TRUE), # 'Genus species' only]

  ".id" = NULL,
  id = NULL,
  author = NULL,
  rank = NULL,
  taxonomicStatus = NULL,
  name = NULL
)]

synpow <- unique(synpow[species != synonyms, ])

ddata_extinction <- merge(ddata_extinction, synpow)

## names in ddata_extinction are replaced with there synonym when the synonym matches with glonaf.
ddata_extinction[, species := data.table::fifelse(
  synonyms %in% lstsp,
  synonyms,
  species
)][
  ,
  matchl := species %in% lstsp
]
ddata_extinction[species == "Crataegus lanuginosa", species := "Crataegus mollis"]
ddata_extinction[species == "Arctostaphylos franciscana", species := "Arctostaphylos hookeri"]

ddata_extinction <- unique(ddata_extinction[, .(species, local, period)])











# Loading native and still present species from the USDA PLANTS database ----
ddata_plants <- data.table::fread("./data/raw data/continental-us_2020/PLANTS database.csv")
data.table::setnames(ddata_plants, c("State and Province", "Scientific Name"), c("local", "species"))
ddata_plants[, local := stringi::stri_extract_all_regex(local, "(?<=USA\\().*(?=\\))", simplify = TRUE)]
ddata_plants <- ddata_plants[!is.na(local)]

## * splitting and melting local ----
ddata_plants[, paste0("tmp", 1:53) := data.table::tstrsplit(local, ", ")]
ddata_plants <- data.table::melt(ddata_plants,
  measure.vars = paste0("tmp", 1:53),
  na.rm = TRUE
)
ddata_plants <- ddata_plants[!value %in% c("AK", "PW", "NAV", "HI", "UM", "FM", "GU", "MH", "MP")]

## * splitting and melting periods ----

ddata_plants[, `Native Status` := stringi::stri_extract_all_regex(`Native Status`, "(?<=L48\\()[A-Z]+(?=\\))", simplify = TRUE)][
  , periodTemp := c("historical+present", "present")[match(`Native Status`, c("N", "I"))]
  # ][, periodTemp := c('historical+present', 'present','unclear','unclear')[match(`Native Status`, c('N','I','NI','W'))]
][, paste0("tmp", 1:2) := data.table::tstrsplit(periodTemp, "\\+")]
ddata_plants <- data.table::melt(ddata_plants,
  measure.vars = paste0("tmp", 1:2),
  value.name = "period",
  na.rm = TRUE
)

ddata_plants[, ":="(
  local = state_dictionnary$long[match(value, state_dictionnary$short)],
  species = gsub("Ã—", "X ", x = gsub(" var. .*$| ssp. .*$", "", species)),

  periodTemp = NULL,
  Invasive = NULL,
  "Native Status" = NULL,
  variable = NULL,
  variable.1 = NULL,
  value = NULL
)]

# checks <- data.frame(species = ddata_extinction$species, original = ddata_extinction$species %in% ddata_plants$species, synonyms = ddata_extinction$synonyms, match_synonym = ddata_extinction$synonyms %in% ddata_plants$species)
# checks <- checks[!checks$original & checks$match_synonym, ]
#
# ddata_plants[species %in% c('Arctostaphylos uva-ursi', 'Arctostaphylos hookeri')]

# ddata_plants[match(species, checks), species := ]

## * checking matches with glonaf and Knapp et al ----
# sl <- unique(ddata_plants$species)
# sl[sl %in% ddata_alien$species]
# ddata_plants[, ':='(
#    matchalien = species %in% ddata_alien$species,
#    matchextinct = species %in% ddata_extinction$species
# )]
# ts <-  ddata_plants[ !(period == 'historical' & matchalien) & !(period == 'present' & matchextinct)]

# unique(ddata_plants$local) %in% ddata_alien$local
# unique(ddata_plants$local) %in% ddata_extinction$local




# Making sure that there is no conflict between glonaf and extinctions ----
# ddata_alien[ species %in% ddata_extinction[(matchl), species]  &  local %in% ddata_extinction[(matchl), local] ]

# ddata_alien[!ddata_alien$species %in% unique(ddata_plants$species)]


# Binding plants, invasions and extinctions datasets ----
ddata <- rbind(ddata_plants, ddata_alien, ddata_extinction, fill = TRUE)


# Checking S values ----
# ddata_plants[, S := length(unique(species)), by = .(local, period)]
# unique(ddata[period %in% c('historical','present'), .(local, S, period)])[order(local, period)][, diff(S), by = local]
#
# ddata_extinction[, S := length(unique(species)), by = .(local, period)] # only one period
#
# ddata_alien[, S := length(unique(species)), by = .(local, period)] # only one period
#
#
#




# table(ddata[, length(species), by = .(species, period, local)]$V1)

# Ddata and metadata ----

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "USA",

  year = c(1565L, 2020L)[match(period, c("historical", "present"))],

  value = 1,

  period = NULL,

  "Accepted Symbol" = NULL,
  "Synonym Symbol" = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Plants",
  realm = "Terrestrial",

  latitude = state_dictionnary$latitude[match(local, state_dictionnary$long)],
  longitude = state_dictionnary$longitude[match(local, state_dictionnary$long)],

  effort = 1L,

  alpha_grain = state_area$area[match(local, state_area$long)],
  alpha_grain_unit = "km2",
  alpha_grain_type = "administrative",
  alpha_grain_comment = "USA state",

  gamma_sum_grains = sum(state_area$area[state_area$long %in% local]),
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "administrative",
  gamma_sum_grains_comment = "sum of the area of the contiguous US states",

  comment = "Alien species (absent from historical times) were extracted from the GLONAF and PLANTS databases. GLONAF is an international alien plant species database (https://glonaf.org/). PLANTS is a plant database maintained by the USDA agency (https://plants.usda.gov/). Extinct species (only present in historical times) were extracted from Knapp et al 2020 10.1111/cobi.13621. The other species occurrences were extracted from the USDA PLANTS database. IMPORTANT: subspecies and varieties were pooled together. Year is difficult to infer from these different data sets but historical situation being pre 1950s and modern situation being post 1990s is a reasonable assumption.",
  comment_standardisation = "none needed"
)]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)

