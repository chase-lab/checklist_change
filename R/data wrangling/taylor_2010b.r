## taylor_2010b

dataset_id <- "taylor_2010b"
ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(ddata, c("local", paste(gsub("\\.+[0-9]+", "\\.", colnames(ddata)[-1]), unlist(ddata[1])[-1])))

# cleaning the data set
ddata <- ddata[-(1:2)]
selected_columns <- colnames(ddata)[!grepl("Total|Extinctions", colnames(ddata))]
ddata <- ddata[, ..selected_columns]

# building 2000 community based on Table 2
ddatah <- data.table::copy(ddata)
ddatah[local == "Quebec", ":="("Ichthyomyzon casteneus" = 0,
                               "Myoxocephalus thompsoni" = 1,
                               "Morone. saxatilis" = 1,
                               "Scardinius erythrophthalmus" = 1)]
ddatah[local == "Alberta", ":="("H. tergisus" = 0,
                                "C. bairdii" = 1,
                                "Cottus. sp." = 0,
                                "O. aguabonita" = 1,
                                "Ctenopharyngodon idella" = 1)]
ddatah[local == "Yukon", ":="("Hiodon alosoides" = 1,
                              "Carassius auratus" = 0,
                              "S. alpinus" = 0,
                              "P. williamsoni" = 0,
                              "Gasterosteus aculeatus" = 0)]
ddatah[local == "Saskatchewan", ":="("Anguilla rostrata" = 0,
                                     "Carassius auratus" = 0,
                                     "R. obtusus" = 0,
                                     "Rhinichthys atratulus" = 1,
                                     "Osmerus mordax" = 0,
                                     "O. nerka" = 0,
                                     "O. kisutch" = 0,
                                     "S. alpinus" = 0,
                                     "L. macrochirus" = 0,
                                     "Pomoxis nigromaculatus" = 0,
                                     "P. annularis" = 0,
                                     "Ctenopharyngodon idella" = 0)]
ddatah[local == "Yukon", ":="("Hiodon alosoides" = 1,
                              "Carassius auratus" = 0,
                              "S. alpinus" = 0,
                              "P. williamsoni" = 0,
                              "Gasterosteus aculeatus" = 0)]
ddatah[local == "PEI", c("A. nebulosus", "Notemigonus crysoleucas") := 0]
ddatah[local == "BC", ":="("A. natalis" = 0,
                           "C. bairdii" = 1,
                           "Cottus. sp." = 0,
                           "C. hubbsi" = 0,
                           "O. aguabonita" = 1)]
ddatah[local == "Manitoba", ":="("R. obtusus" = 0,
                                 "Rhinichthys atratulus" = 1,
                                 "N. percobromus" = 0,
                                 "N. rubellus" = 1,
                                 "Osmerus mordax" = 0,
                                 "O. nerka" = 1)]
ddatah[local == "Ontario", ":="("R. obtusus" = 0,
                                "Salmo salar" = 1,
                                "Thymallus arcticus" = 1,
                                "P. shumardi" = 0,
                                "Cichlosoma managuense" = 1,
                                "Platichthys flesus" = 1,
                                "Lepisosteus platyrhincus" = 1,
                                "Ctenopharyngodon idella" = 1,
                                "Colossoma bidens" = 1,
                                "Astronotus ocellatus" = 1,
                                "Dallia pectoralis" = 1)]
ddatah[local == "Newf/Lab", ":="("Esox lucius" = 0,
                                 "Margariscus margarita" = 1,
                                 "Coregonus clupeaformis" = 0)]
ddatah[local == "NewB", c("E. masquinongy", "Menidia menidia") := 0]
ddatah[local == "Nova S", "C. commersoni" := 0]
ddatah[local == "NWT", ":="("O. mykiss" = 1,
                            "C. laurettae" = 1,
                            "Prosopium coulterii" = 0)]
ddatah[local == "NunT", c("Myoxocephalus thompsoni", "M. quadricornis") := 1]


# binding 2000 and 2005 communities
ddata[, year := 2005L]
ddatah[, year := 2000L]
ddata <- rbind(ddata, ddatah, fill = TRUE)

# melting species
ddata <- data.table::melt(ddata,
                          id.vars = c("local", "year"),
                          variable.name = "species"
)

ddata <- ddata[value != 0]


ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Canada"
)]


meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   realm = "Freshwater",
   taxon = "Fish",

   latitude = 51L,
   longitude = -101L,

   effort = 1L,

   alpha_grain = c(661848L, 944735L, 647797L, 72908L, 405212L, 55284L, 2093190L, 1346106L, 1076395L, 5660L, 1542056L, 651036L, 482443L)[match(local, c("Alta", "BC", "Manitoba", "NewB", "Newf/Lab", "Nova S", "NunT", "NWT", "Ontario", "PEI", "Quebec", "Sask", "YT"))],
   alpha_grain_unit = "km2",
   alpha_grain_type = "administrative",
   alpha_grain_comment = "area of the province/territory",

   gamma_sum_grains = sum(c(661848L, 944735L, 647797L, 72908L, 405212L, 55284L, 2093190L, 1346106L, 1076395L, 5660L, 1542056L, 651036L, 482443L)),
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "administrative",
   gamma_sum_grains_comment = "sum of alpha grains = area of Canada",

   comment = "Extracted from supplementary 1, Taylor et al 2010 (10.1111/j.1472-4642.2010.00670.x). Data presented here are fish inventories that the authors compiled from literature at the province or territory scale in Canada. Compositional change between 2000 and 2005 is detailed in table 2.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1111/j.1472-4642.2010.00670.x'
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
