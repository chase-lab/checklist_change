dataset_id <- "miller_2022"

ddata <- base::readRDS(file = "./data/raw data/miller_2022/rdata.rds")

# Excluding non serpentine sites
ddata <- ddata[grepl(pattern = "^S", PlotKey)]
# Keepink only sites sampled twice
ddata <- ddata[ddata[, length(unique(Visit)), by = PlotKey][V1 == 2L][,.(PlotKey)], on = "PlotKey"]
# averaging coordinates between both visits
ddata <- ddata[, ":="(Latitude = mean(Latitude, na.rm = TRUE),
                      Longitude = mean(Longitude, na.rm = TRUE)),
               by = PlotKey]


# communities ----
data.table::setnames(ddata, c("local","species","visit","latitude","longitude"))
ddata[, ":="(
   dataset_id = factor(dataset_id),
   regional = factor("Serpentine"),

   year = c(2003L, 2014L)[data.table::chmatch(visit, c("Initial sampling","2014 Revisit"))],

   value  = 1L,

   visit = NULL
)]

# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])
meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   effort = 1L,
   data_pooled_by_authors = FALSE,
   sampling_years = c("2000-2003", "2014")[match(year, c(2003L, 2014L))],

   alpha_grain = 50L*10L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "area of each plot given by the authors",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "'At each serpentine or nonserpentine location, a north- and a south-facing 50 * 10 m plot were sampled.'",

   gamma_bounding_box = geosphere::areaPolygon(x = data.frame(longitude, latitude)[grDevices::chull(x = longitude, y = latitude), ]) / 1000000,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors in figshare repo 1_Location_Topography.csv",

   comment = "Extracted from dataset Miller, Jesse E. D., Stella Copeland, Kendi Davies, Brian Anacker, Hugh Safford, and Susan Harrison. 2022. 'Plant Community Data from a Statewide Survey of Paired Serpentine and Non-Serpentine Soils in California, USA.' METHODS: 'In 2000–2003, serpentine plant communities were sampled at 107 locations representing the full range of occurrence of serpentine in California, USA, spanning large gradients in climate.[...] At each serpentine or nonserpentine location, a north- and a south-facing50 * 10 m plot were sampled. This design produced 97 “sites” each consisting of four “plots” (north-south exposure, serpentine-nonserpentine soil). All plots were initially visited three or more times over two years to record plant diversity and cover, and a subset were revisited in 2014 to examine community change after a drought.' Ecology 103(6): e3644. https:// doi.org/10.1002/ecy.3644 with data archived on FigShare at https://doi.org/10.6084/m9.figshare.17009027.",
   comment_standardisation = "only serpentine sites sampled twice were kept",
   doi = ' https://doi.org/10.1002/ecy.3644'
)]

ddata[, c("latitude", "longitude") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
