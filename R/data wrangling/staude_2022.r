# staude_2022

ddata <- base::readRDS(file = "./data/raw data/staude_2022/rdata.rds")

# recoding and splitting periods
ddata[, trajectory := c("historical", "historical-recent", "recent")[data.table::chmatch(trajectory, c("lost","persisting", "gained"))]
]
ddata[, c("tmp1","tmp2") := data.table::tstrsplit(x = trajectory, split = "-", fixed = TRUE)]

ddata <- data.table::melt(data = ddata,
                          id.vars = c("habitat","site","speciesKey"),
                          measure.vars = c("tmp1","tmp2"),
                          value.name = "period",
                          na.rm = TRUE)

