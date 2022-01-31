## pilarczyk_2006

dataset_id <- "pilarczyk_2006"
if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  lst <- tabulizer::extract_tables(
    file = "./data/cache/Pilarczyk et al. 2006 (data in Appendix).pdf",
    pages = 20L:23L,
    method = "stream"
  )
  lst <- lapply(lst, as.data.frame)

  # Adding missing rows
  lst[[1]] <- rbind(
    c("species", "2004", "1990s", "2004", "1990s", "2004", "1990s", "2004", "1990s", "2004", "1990s", "2004", "1990s"),
    c("Margaritifera marrianae", rep("", 12)),
    c("Anodontoides radiatus", rep("", 5), "X", rep("", 6)),
    c("Elliptio cf. arctata", rep("", 4), 24, rep("", 7)),
    lst[[1]]
  )

  # Adding missing rows and a missing column
  lst[[3]] <- rbind(
    c("species", "2004", "1990s", "2004", "1990s", "2004", "1990s", "2004", "1990s", "2004", "1990s", "1990s"),
    c("Margaritifera marrianae", rep("", 11), "X"),
    c("Anodontoides radiatus", rep("", 12)),
    c("Elliptio cf. arctata", 6, rep("", 11)),
    c("Elliptio cf. complanata", rep("", 12)),
    c("Elliptio crassidens", rep("", 11), "X"),
    lst[[3]]
  )

  lst[[3]] <- cbind(lst[[3]], V13 = lst[[3]]$V12)
  lst[[3]]$V12 <- c("1990s", rep("", 25))

  lst[[2]][1, 1] <- lst[[4]][1, 1] <- "species"

  # Erasing descriptor names
  lst[[1]][, 1] <- gsub("\\(|\\)|Lightfoot|Lamarck|Conrad|Clench and Turner|Simpson|Lea|I. Lea|Rafinesque|van der Schalie|Say|Walker|Johnson|Athearn|Wright", "", lst[[1]][, 1])

  # Adding site names

  sitenames <- list(
    c("05", "08", "27", "28", "29", "30"),
    c("31", "32", "33", "34", "35", "36"),
    c("37", "38", "39", "40", "41", "45"),
    c("56", "57", "59", "60", "61", "62")
  )
  for (i in 1:4) lst[[i]][1, -1] <- paste(rep(sitenames[[i]], each = 2), lst[[i]][1, -1])

  for (i in 1:4) colnames(lst[[i]]) <- lst[[i]][1, ]
  lst <- lapply(lst, function(x) x[-1, ])

  lst[2:4] <- lapply(2:4, function(i) lst[[i]][, -1])
  ddata <- lst[[1]]
  for (i in 2:4) ddata <- cbind(ddata, lst[[i]])

  ddata <- data.table::setDT(ddata)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
