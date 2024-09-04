## corke_1992
dataset_id <- "corke_1992"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
data.table::setnames(ddata, "Species", "species")

# melting sites
ddata <- data.table::melt(data = ddata,
                          id.vars = "species",
                          value.name = "period",
                          variable.name = "local"
)
ddata <- ddata[period != "" & !grepl("Total|Tota l|To ta l|endemics", species)]

# recoding presence absence
ddata[j = period := trimws(gsub("\\([0-9]\ ?\\)", "", period))]
ddata[
   j = period := data.table::fifelse(
      period %in% c("-", "- -", ".", ". ."), "",
      data.table::fifelse(
         test = period %in% c("*", ":~", "~", "~:", "+", "t"),
         yes = "historical+present",
         no = data.table::fifelse(
            test = grepl("\\[|\\{", period),
            yes = "historical",
            no = "present")
      )
   )]

# melting historical and present values
ddata[, c("period1", "period2") := data.table::tstrsplit(period, "\\+")]
ddata <- data.table::melt(
   ddata,
   id.vars = c("local", "species"),
   measure.vars = c("period1", "period2"),
   value.name = "period"
)
ddata <- ddata[!is.na(period)]

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Windward Islands",
   year = c(1498L, 1992L)[match(period, c("historical", "present"))],



   variable = NULL,
   period = NULL
)]

ddata[, species := species |> sub(pattern = " {2,}", replacement = "_") |>
         sub(pattern = " {1}", replacement = "") |>
         sub(pattern = "\\._", replacement = "\\. ") |>
         sub(pattern = "\\(seetext\\)", replacement = "") |>
         sub(pattern = "\\.([[:alpha:]])", replacement = "\\. \\1") |>
         sub(pattern = "_", replacement = " ") |>
         sub(pattern = "^,4", replacement = "A")]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])

env <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/env.csv"),
   skip = 0, header = TRUE, encoding = "Latin-1", sep = ",")
env[, c("latitude", "longitude") := data.table::tstrsplit(coordinates, " ")]

meta[i = env,
     j = ":="(
        latitude = i.latitude,
        longitude = i.longitude,
        alpha_grain = i.area),
     on = "local"][
        j = ":="(
           latitude = parzer::parse_lat(latitude),
           longitude = parzer::parse_lon(longitude)
        )]

meta[, ":="(
   taxon = "Herpetofauna",
   realm = "Terrestrial",

   effort = 1L,
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Literature review",

   alpha_grain_unit = "km2",
   alpha_grain_type = "island",
   alpha_grain_comment = "area of the island",

   gamma_bounding_box = geosphere::areaPolygon(x = data.frame(longitude, latitude)[grDevices::chull(x = longitude, y = latitude), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "archipelago",
   gamma_sum_grains_comment = "sum of the areas of the sampled islands.",


   comment = "Extracted from the article 'The status and conservation needs of the terrestrial herpetofauna of the windward islands (West Indies)' with tabulizer and hand copy.
Freshwater, terrestrial and marine amphibian and reptile species sampled. The authors made a review of the literature to assess the historical compositions.
METHODS 'The status summaries for St Lucia, St Vincent and some of the Grenadines are based on my own field observations carried out during 1989 with previous visits to St Lucia and satellites in 1983 and 1986.[...]The current checklist for the West Indian herpetofauna is Schwartz and Henderson (1988).' Species that were noted as extinct in the main island but still present in islets were considered extinct for this study.
1498 is considered to be the end of the pre-European contact in the area as this is the year Christopher Columbus landed on Trinidad y Tobago
Regional is the archipelago, local are islands",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1016/0006-3207(92)91151-H'
)][j = gamma_sum_grains := sum(alpha_grain), keyby = year]

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
