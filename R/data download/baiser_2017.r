## baiser_2017

dataset_id <- "baiser_2017"

  # community data ----
  islands <- read.table(
    file = base::unz(
      description = rdryad::dryad_download("10.5061/dryad.rs714")[[1]][1],
      filename = "IslandList.txt"
    ),
    header = TRUE, sep = "\t"
  )
  data.table::setDT(islands)

  islands[, ":="(
    Archipelago = gsub("(?<=[a-z])([A-Z])", " \\1", Archipelago, perl = TRUE),
    `Island.Name` = gsub(".|_",
      " ",
      gsub("(?<=[a-z])([A-Z])", " \\1", `Island.Name`, perl = TRUE),
      fixed = TRUE
    )
  )]

  old <- read.table(
    file = base::unz(
      description = rdryad::dryad_download("10.5061/dryad.rs714")[[1]][1],
      filename = "IslandSampleOld.txt"
    ),
    header = TRUE, sep = "\t"
  )
  data.table::setDT(old)

  current <- read.table(
    file = base::unz(
      description = rdryad::dryad_download("10.5061/dryad.rs714")[[1]][1],
      filename = "IslandSampleCurrent.txt"
    ),
    header = TRUE, sep = "\t"
  )
  data.table::setDT(current)


  data.table::setnames(islands, old = "Island.Name", new = "island")
  data.table::setnames(old, c("island", "presence", "species"))
  data.table::setnames(current, c("island", "presence", "species"))

  old <- merge(islands, old, by = "island")
  current <- merge(islands, current, by = "island")

  old[, period := "old"]
  current[, period := "current"]

  ddata <- rbind(old, current)

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))

