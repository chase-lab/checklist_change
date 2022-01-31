## continental-us_2020

dataset_id <- "continental-us_2020"

if (!file.exists(paste0("./data/raw data/", dataset_id, "/ddata_extinction.rds"))) {
  ## Native species
  ### PLANTS database request
  #### PLANTS Floristic Area: L48 + Alaska
  #### display State and Province
  #### Category: Dicot and Monocot
  #### Scientific Name include Accepted Names and Synonyms. Display all Synonyms
  #### ranK: Only Species Epithet. Display Species
  #### Display Native Status
  #### Display PLANTS Invasive Status
  ### Downloaded and saved in csv.


  ## Exotic species GLONAF
  ### downloading
  # using suppdata to download from he journal would be better(?) but the archive is in rar format and implementing a trans-platform solution to decompress it is too much of a hassle.
  dir.create(paste0("./data/downloaded data/", dataset_id), showWarnings = FALSE)
  if (!file.exists(paste0("./data/cache/", dataset_id, "/continental-us_2020_exotics.zip"))) {
    download.file(
      "https://idata.idiv.de/ddm/Data/DownloadZip/257",
      paste0("./data/cache/", dataset_id, "continental-us_2020_exotics.zip"),
      method = "curl"
    )
  }

  ### unziping and deleting
  if (!file.exists(paste0("./data/cache/", dataset_id, "glonaf/glonaf/GLONAF/Region_GloNAF_vanKleunenetal2018Ecology.csv"))) {
    utils::unzip("./data/cache/continental-us_2020/continental-us_2020_exotics.zip", exdir = "./data/cache/continental-us_2020/glonaf")
    utils::unzip("./data/cache/continental-us_2020/glonaf/257_2_GLONAF.zip", exdir = "./data/cache/continental-us_2020/glonaf/glonaf")
    file.remove(paste0("./data/cache/", dataset_id, "/glonaf/257_2_GloNAF.zip"))
    file.remove(paste0("./data/cache/", dataset_id, "/glonaf/257_2_GloNAF_Shapefile.zip"))
  }




  ## extinctions
  if (!file.exists("./data/cache/continental-US_2020_extincions.pdf")) download.file("https://conbio.onlinelibrary.wiley.com/doi/pdfdirect/10.1111/cobi.13621?download=true", "./data/cache/continental-US_2020_extincions.pdf", method = "curl", mode = "wb")

  page46 <- data.table::rbindlist(
    lapply(
      tabulizer::extract_tables(paste("./data/raw data", dataset_id, "extinctions-cobi.13621.pdf", sep = "/"),
        pages = c(4, 6),
        method = "stream"
      ),
      function(page) as.data.frame(page)[-(1:3), c(1, 5)]
    )
  )
  page46[44:45, V5 := c("AR, IL, KY, MO", "")]

  page5 <- as.data.frame(matrix(c(
    "Diplacus traskiae", "CA",
    "Eleocharis brachycarpa", "TX & MX",
    "Elodea schweinitzii", "NY & PA",
    "Erigeron mariposanus", " CA",
    "Eriochloa michauxii", "FL",
    "Euonymus atropurpureus", "TX ",
    "Franklinia alatamaha", "GA",
    "Govenia floridana", "FL",
    "Hedeoma pilosa", "TX",
    "Helianthus nuttallii", "CA",
    "Helianthus praetermissus", "AZ, NM ",
    "Isocoma humilis", "UT",
    "Juncus pervetus", "MA",
    "Lechea lakelae", "FL",
    "Lycium verrucosum", "CA ",
    "Marshallia grandiflora", "NC",
    "Micranthemum micranthemoides", "DC, DE, MD, NJ, NY, PA, VA",
    "Monardella leucocephala", "CA",
    "Monardella pringlei", "CA",
    "Narthecium montanum", "NC",
    "Orbexilum macrophyllum", "NC",
    "Orbexilum stipulatum", "KY",
    "Paronychia maccartii", "TX",
    "Plagiobothrys lamprocarpus", "OR",
    "Plagiobothrys lithocaryus", "CA",
    "Plagiobothrys mollis", "CA",
    "Polygonatum biflorum", "MI, ON"
  ),
  ncol = 2,
  dimnames = list(c(), c("species", "local")),
  byrow = TRUE
  ))

  ddata_extinction <- data.table::rbindlist(l = list(page5, page46), use.names = FALSE)
  base::saveRDS(ddata_extinction, file = paste0("./data/raw data/", dataset_id, "/ddata_extinction.rds"))
}
