## tissot_1999a

dataset_id <- "tissot_1999a"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  # extraction with tabulizer
  lst <- lapply(
    tabulizer::extract_tables(
      file = "./data/cache/tissot_1999 - Tissot_Pelekane_Bay_1999 (data in appendix).pdf",
      pages = 19:21,
      output = "data.frame",
      header = FALSE
    ),
    data.table::setDT
  )

  lst[[1]] <- lst[[1]][-(1:4)]
  lst[[1]][
    ,
    paste(c("inner", "outer", "mean"), "1976") := data.table::tstrsplit(V2, split = " ")
  ][
    ,
    "SE 1976" := V3
  ][
    ,
    paste(c("inner", "middle", "outer"), "1996") := data.table::tstrsplit(V4, split = " "),
  ][
    ,
    paste(c("mean", "SE", "p"), 1996) := .(V5, V6, V7)
  ][
    ,
    paste0("V", 2:7) := NULL
  ]

  lst[[2]][
    ,
    paste(c("inner", "outer"), "1976") := data.table::tstrsplit(V2, split = " ")
  ][
    ,
    c("mean 1976", "SE 1976") := .(V3, V5)
  ][
    ,
    c(paste(c("inner", "middle"), "1996"), "V12") := data.table::tstrsplit(V6, split = " "),
  ][
    ,
    paste(c("outer", "mean", "SE", "p"), 1996) := .(V7, V9, V10, V11)
  ][
    ,
    paste0("V", 2:12) := NULL
  ]


  lst[[3]][
    ,
    paste(c("inner", "outer"), "1976") := data.table::tstrsplit(V2, split = " ")
  ][
    ,
    c("mean 1976", "SE 1976") := .(V3, V5)
  ][
    ,
    c(paste(c("inner", "middle"), "1996"), "V12") := data.table::tstrsplit(V6, split = " "),
  ][
    ,
    paste(c("outer", "mean", "SE", "p"), 1996) := .(V7, V9, V10, V11)
  ][
    ,
    paste0("V", 2:12) := NULL
  ]




  ddata <- data.table::rbindlist(lst, use.names = TRUE)

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
