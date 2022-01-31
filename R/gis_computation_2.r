library(data.table)

# loading gift ----
gift <- fread(rdryad::dryad_download("10.5061/dryad.fv94v")[[1]][[2]], select = 1:17)

gift[, stIsland := trimws(gsub("Isla |Island|Atoll | ?of |Ile |Isle |Ilha do |Ilha de |Ilha das |Ilha |\\.", " ", Island))][, stIsland := gsub("‘", "", stIsland)]
gift[, stName_alt := trimws(gsub("Isla |Island|Atoll | ?of |Ile |Isle |Ilha do |Ilha de |Ilha das |Ilha |\\.", " ", Name_alt))][, stName_alt := gsub("‘", "", stName_alt)]
gift[!is.na(Island), uni := .N == 1, by = Island] # uni will allow selecting island names that are unique. FYI there are 34 different islands called "Long Island" in this data base. And in the 'Japan' archipelago, there are 16 distinct islands called 'O-shima'.
gift[!is.na(Island), stuni := .N == 1, by = stIsland] # stuni will allow selecting standardised island names that are unique. FYI there are 34 different islands called "Long" in this data base.





## * baiser_2011 ----
load(file = paste0("data/raw data/baiser_2011/ddata"))
meta <- unique(ddata[, .(Archipelago, island)])[order(Archipelago, island)]

# ** ISLANDS ACCURATE ----

# Is there a match for island? Both the name (which is not unique in gift and the gift island id are kept)
meta[, match_island_GIFT_ID := fifelse(island %in% gift[(uni), Island], gift$ID[match(island, gift$Island)], NA_integer_)][
  ,
  match_island_GIFT_ID2 := fifelse(island %in% gift[(stuni), stIsland], gift$ID[match(island, gift$stIsland)], NA_integer_)
]
# meta[!is.na(match_archipelago_GIFT)]
sum(!is.na(meta$match_island_GIFT_ID))

# standardising island name in baiser_2011
meta[, stisland := trimws(gsub("Island|island|I.do.|\\.", " ", island))]

# look up standardised names in gift
meta[, match_island_GIFT_ID3 := fifelse(stisland %in% gift[(uni), Island], gift$ID[match(stisland, gift$Island)], NA_integer_)][
  ,
  match_island_GIFT_ID4 := fifelse(stisland %in% gift[(stuni), stIsland], gift$ID[match(stisland, gift$stIsland)], NA_integer_)
]
# meta[!is.na(match_archipelago_GIFT)]
sum(!is.na(meta$match_island_GIFT_ID))

# Comparing different matches
meta[, match_coherence := length(unique(na.omit(unlist(.SD)))),
  by = seq_len(nrow(meta)),
  .SDcols = c("match_island_GIFT_ID", "match_island_GIFT_ID2", "match_island_GIFT_ID3", "match_island_GIFT_ID4")
]
meta[match_coherence == 1, match_island_GIFT_ID := unique(na.omit(unlist(.SD))),
  .SDcols = c("match_island_GIFT_ID", "match_island_GIFT_ID2", "match_island_GIFT_ID3", "match_island_GIFT_ID4")
][, c("match_island_GIFT_ID2", "match_island_GIFT_ID3", "match_island_GIFT_ID4") := NULL]
if (any(meta$match_coherence > 1)) warning("Several matches for a single island")
sum(!is.na(meta$match_island_GIFT_ID))
meta[, match_coherence := NULL]


# ** ARCHIPELAGO ----
# 1. Match archipelago where island is known
# 2. Then ACCURATE match even without the island matched
# 3. then APPROXIMATIVE match even when the island is unmatched
# and resolving approximate matches
meta[
  , # 1.
  match_archipelago_GIFT := gift$Archip[match(match_island_GIFT_ID, gift$ID)]
][ # 2.
  !is.na(Archipelago) & is.na(match_archipelago_GIFT),
  match_archipelago_GIFT := na.omit(unique(gift$Archip))[match(Archipelago, na.omit(unique(gift$Archip)))]
][ # 3.
  !is.na(Archipelago) & is.na(match_archipelago_GIFT),
  match_archipelago_GIFT := paste(
    agrep(
      pattern = Archipelago,
      x = na.omit(unique(gift$Archip)),
      value = TRUE,
      max.distance = 0.2
    ),
    collapse = " ; "
  ),
  by = which(
    !is.na(Archipelago) & is.na(match_archipelago_GIFT)
  )
]
sum(!is.na(meta$match_archipelago_GIFT) & meta$match_archipelago_GIFT != "")
# meta[grepl(';', match_archipelago_GIFT)]
# Manually replacing a few
meta[Archipelago == "Canaries", match_archipelago_GIFT := "Canary Islands"]
meta[Archipelago == "Comoros", match_archipelago_GIFT := "Mozambique Channel Islands"]
meta[Archipelago == "Madeira", match_archipelago_GIFT := "Madeira Archipelago"]
meta[Archipelago == "Marianas", match_archipelago_GIFT := "Mariana Islands"]
meta[Archipelago == "Trsitan Group", match_archipelago_GIFT := "Tristan da Cunha Islands"]

meta[grepl(";", match_archipelago_GIFT) | match_archipelago_GIFT == "", match_archipelago_GIFT := NA]
sum(!is.na(meta$match_archipelago_GIFT))

# All fuzzy matches have to be checked, not only when there are several possible solutions
write.table("~/GIS/GIFT database/")
# ** ISLANDS APPROXIMATE ----
# look up for APPROXIMATE matches for island where there is a match for archipelago
# To facilitate making a decision on approximate matches, let's use island names instead of island IDs
meta[, match_island_GIFT_name := gift$Island[match(match_island_GIFT_ID, gift$ID)]]
# First step with stisland
meta[!is.na(match_archipelago_GIFT),
  match_island_GIFT_name2 := paste(
    gift[(stuni) & Archip == match_archipelago_GIFT, Island][
      agrepl(
        pattern = stisland, # standardised name
        x = gift[(stuni) & Archip == match_archipelago_GIFT, stIsland],
        max.distance = 0.2
      )
    ],
    collapse = " ; "
  ),
  by = which(!is.na(match_archipelago_GIFT))
][match_island_GIFT_name2 == "", match_island_GIFT_name2 := NA_character_]
sum(!is.na(meta$match_island_GIFT_name))
meta[grepl(";", match_island_GIFT_name)]

# Second step with island raw name
meta[!is.na(match_archipelago_GIFT),
  match_island_GIFT_name3 := paste(
    gift[(stuni) & Archip == match_archipelago_GIFT, Island][
      agrepl(
        pattern = island, # raw name
        x = gift[(stuni) & Archip == match_archipelago_GIFT, stIsland],
        max.distance = 0.2
      )
    ],
    collapse = " ; "
  ),
  by = which(!is.na(match_archipelago_GIFT))
][match_island_GIFT_name3 == "", match_island_GIFT_name3 := NA_character_]
sum(!is.na(meta$match_island_GIFT_name))
meta[grepl(";", match_island_GIFT_name)]

# Third step match approx all remaining islands not only those with a matched archipelago
meta[,
  match_island_GIFT_name4 := paste(
    gift[(stuni), Island][
      agrepl(
        pattern = island, # raw name
        x = gift[(stuni), stIsland],
        max.distance = 0.05
      )
    ],
    collapse = " ; "
  ),
  by = seq_len(nrow(meta))
][match_island_GIFT_name4 == "", match_island_GIFT_name4 := NA_character_]

meta[,
  match_island_GIFT_name5 := paste(
    gift[(stuni), Island][
      agrepl(
        pattern = stisland, # standardised name
        x = gift[(stuni), stIsland],
        max.distance = 0.05
      )
    ],
    collapse = " ; "
  ),
  by = seq_len(nrow(meta))
][match_island_GIFT_name5 == "", match_island_GIFT_name5 := NA_character_]



# Comparing different matches
meta[, match_coherence := paste(unique(na.omit(unlist(.SD))), collapse = ";"),
  by = seq_len(nrow(meta)),
  .SDcols = c("match_island_GIFT_name", "match_island_GIFT_name2", "match_island_GIFT_name3", "match_island_GIFT_name4", "match_island_GIFT_name5")
]
meta[grepl(";", match_coherence)][1:10]




meta[match_coherence == 1, match_island_GIFT_name := unique(na.omit(unlist(.SD))),
  .SDcols = c("match_island_GIFT_name", "match_island_GIFT_name2", "match_island_GIFT_name3", "match_island_GIFT_name4", "match_island_GIFT_name4")
][, c("match_island_GIFT_name2", "match_island_GIFT_name3", "match_island_GIFT_name4", "match_island_GIFT_name5") := NULL]
if (any(meta$match_coherence > 1)) warning("Several matches for a single island")
sum(!is.na(meta$match_island_GIFT_ID))



sum(!is.na(meta$match_island_GIFT_name))
meta[grepl(";", match_island_GIFT_name)]

# Now resolving approximate multiple matches
# Marion is missing, Santiago1 is missing, Maug will be automatically matched with alternative names, rombo is missing,
# meta[grepl(pattern = ';', x = match_island_GIFT, fixed = TRUE)]
meta[stisland == "Huahine", c("match_island_GIFT_name", "match_island_GIFT_ID") := .("Huahine Nui", 9199L)] # This is the largest of the two Huahine islands
meta[stisland == "St Helena", c("match_archipelago_GIFT", "match_island_GIFT_name", "match_island_GIFT_ID") := .("Saint Helena", "Saint Helena Island", 85150L)]
meta[stisland == "Campbell" & Archipelago == "New Zealand", c("match_archipelago_GIFT", "match_island_GIFT_name", "match_island_GIFT_ID") := .("Campbell Islands", NA_character_, 2995L)] # no island name in gift but only one island in Campbell Islands Archipelago in New Zealand
meta[island == "St.Martin" & Archipelago == "Lesser Antilles", c("match_archipelago_GIFT", "match_island_GIFT_name", "match_island_GIFT_ID") := .("West Indies", "Ile Saint-Martin", 11653L)]
meta[grepl(pattern = ";", x = match_island_GIFT_name, fixed = TRUE)]
meta[grepl(pattern = ";", x = match_island_GIFT_name, fixed = TRUE), match_island_GIFT_name := NA_character_] # temporarily until all approximate matches have been solved

# Now matching match_island_GIFT_name and match_island_GIFT_ID
meta[is.na(match_island_GIFT_ID) & !is.na(match_island_GIFT_name), match_island_GIFT_ID := gift$ID[match(match_island_GIFT_name, gift$Island)]]
# and archipelagos
meta[, match_archipelago_GIFT := gift$Archip[match(match_island_GIFT_ID, gift$ID)]]
sum(!is.na(meta$match_island_GIFT_ID))
sum(!is.na(meta$match_island_GIFT_name))
sum(!is.na(meta$match_archipelago_GIFT))


# ** ISLAND ALTERNATIVE ----
# Matching with gift alternative names Name_alt
# TAKE INTO ACCOUNT THAT SEVERAL MATCHES CAN HAPPEN
# OR BUILD A DT WITH ID AND SEVERAL ROWS PER ID EACH ROW CORRESPONDING TO ONE ALTERNATIVE TSTRSPLIT AND MELT WITH ONLY ALT AND ID
altgift <- gift[, .(ID, stName_alt)]
altgift[, paste0("tmp", 1:9) := tstrsplit(x = stName_alt, split = "; ")]
altgift <- data.table::melt(altgift,
  id.vars = "ID",
  measure.vars = paste0("tmp", 1:9),
  value.name = "stName_alt",
  na.rm = TRUE
)

# ACCURATE match
sum(!is.na(meta$match_island_GIFT_name))
# looking up in gift alternative names among all archipelagos
meta[is.na(match_island_GIFT_ID),
  match_island_GIFT_ID :=
    altgift[
      grepl(
        pattern = stisland, # with standardised island name
        x = stName_alt,
      ),
      ID
    ],
  by = which(is.na(match_island_GIFT_ID))
]
meta[is.na(match_island_GIFT_ID),
  match_island_GIFT_ID :=
    altgift[
      grepl(
        pattern = island, # with raw island name
        x = stName_alt,
      ),
      ID
    ],
  by = which(is.na(match_island_GIFT_ID))
]
sum(!is.na(meta$match_island_GIFT_ID))



# APPROXIMATIVE match
# looking up in gift alternative names among all archipelagos
meta[is.na(match_island_GIFT),
  match_island_GIFT := paste(
    gift[
      !is.na(stName_alt) &
        agrepl(
          pattern = stisland, # with standardised island name
          x = stName_alt,
          max.distance = 0.1
        ),
      Island
    ],
    collapse = " ; "
  ),
  by = which(is.na(match_island_GIFT))
][match_island_GIFT == "", match_island_GIFT := NA_character_]

meta[is.na(match_island_GIFT),
  match_island_GIFT := paste(
    gift[
      !is.na(stName_alt) &
        agrepl(
          pattern = island, # with raw island name
          x = stName_alt,
          max.distance = 0.1
        ),
      Island
    ],
    collapse = " ; "
  ),
  by = which(is.na(match_island_GIFT))
][match_island_GIFT == "", match_island_GIFT := NA_character_]
sum(!is.na(meta$match_island_GIFT))

# Now resolving approximate multiple matches
# WARNING PAY ATTENTION: HARD TO RESOLVE BY LOOKING BECAUSE THE APPROX MATCHING WAS MADE WITH NAME_ALT AND HERE ISLAND IS PRINTED
meta[grepl(";", match_island_GIFT)]
meta[grepl(pattern = ";", x = match_island_GIFT, fixed = TRUE), match_island_GIFT := NA_character_]
sum(!is.na(meta$match_island_GIFT))



# MAKING SURE THAT NONE OF THE MATCHED NAMES CORRESPONDS TO A NON UNIQUE NAME
# MAKING SURE THAT ARCHIPELAGOS AND ISLANDS MATCH THE SAME ROWS
# en fait a chaque step il faudrait alimenter une colone differente et s,assurer que les valeurs correspondent au lieu de faire confiance a la premiere match




meta[is.na(match_archipelago_GIFT) | match_archipelago_GIFT == ""]

meta[!is.na(match_archipelago_GIFT)]

meta[is.na(match_archipelago_GIFT) | is.na(match_island_GIFT) | match_archipelago_GIFT == "" | match_island_GIFT == ""]

# Filling by hand
sum(!is.na(meta$match_island_GIFT))
meta[island == "Prince.Edward", c("match_archipelago_GIFT", "match_island_GIFT") := list("Prince Edward Islands", NA_character_)] # area available for two unnamed islands

meta[island == "New.Caledonia", c("match_archipelago_GIFT", "match_island_GIFT") := list("New Caledonia", "Nouvelle-Caledonie")]

sum(!is.na(meta$match_island_GIFT))

# San Andres Island is a wrong match!
# if archip and island match, check that they match the same row in gift
meta[, ":="(
  no_archip = paste(which(gift$Archip == match_archipelago_GIFT), collapse = ";"),
  no_island = which(gift$Island == match_island_GIFT)
), by = seq_len(nrow(meta))][, check := grepl(no_island, no_archip)]



# IN RETURN GIFT NAMEALT SHOULD BE APPENDED WITH THE MATCHES FOUND














# Look up for matches with last word only and with spaces instead of dots
meta[is.na(match_archipelago_GIFT),
  match_archipelago_GIFT := grep(
    pattern = gsub("\\.", " ", Archipelago),
    x = unique(gift$Archip),
    value = TRUE
  ),
  by = which(is.na(match_archipelago_GIFT))
]
meta[!is.na(match_archipelago_GIFT)]



# look up for potential matches for island where there is a match for archipelago
meta[!is.na(match_island_GIFT),
  match_island_approximate := paste(agrep(pattern = island, x = na.omit(gift[gift$Archip == Archipelago, "Island"]), value = TRUE), collapse = ";"),
  by = which(!is.na(match_island_GIFT))
]






unique(meta[!Archipelago %in% gift$Archip, .(Archipelago)])
agrep("Trsitan Group", unique(gift$Archip), max.distance = .5, value = TRUE)
meta[, match_archipelago := fifelse(
  Archipelago %in% unique(gift$Archip), Archipelago,
  paste(unique(agrep(Archipelago, unique(gift$Archip),
    value = TRUE,
    max.distance = 0.5, fixed = TRUE
  )),
  collapse = ";"
  ),
  match_archipelago
),
by = seq_len(nrow(meta))
]


meta[!island %in% gift$Island, .(Archipelago, island)]
gift[agrep("Tupai", gift$Island, value = FALSE, fixed = TRUE), .(Country, Archip, Island)]

meta[, match_island := island %in% gift[gift$Archip == Archipelago, "Island"], by = seq_len(nrow(meta))]
meta[(!match_island), match_island_approximate := paste(agrep(pattern = island, x = gift[gift$Archipelago == Archipelago, "Island"], value = TRUE), collapse = ";"), by = which(!match_island)]







save(gift, file = paste("data/GIS data/gift", sep = "/"))
