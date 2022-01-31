# Area of polygons of points forming the gamma scale extent of a study

library(geosphere)

# starko_2019
stark <- read.csv("C:/Users/as80fywe/idiv/homogenisation/data/raw data/starko_2019/journal.pone.0213191.s001.csv")
vertices <- stark[chull(x = stark$Longitude, y = stark$Latitude), c("Longitude", "Latitude")]
areaPolygon(vertices) / 1000000


# roman-palacios_2020
roman <- readxl::read_xlsx("./data/raw data/roman-palacios_2020/pnas.1913007117.sd02.xlsx", 2)

areas <- c()
names(areas) <- unique(roman$Study)
for (study in unique(roman$Study)) {
  tmp <- roman[roman$Study == study, ]
  tmp <- tmp[chull(tmp$Longitude, tmp$Latitude), c("Longitude", "Latitude")]
  areas <- c(areas, areaPolygon(tmp) / 1000000)
}


summary(areas)
sd(areas)

## Eros_2020
## GIS computation of the area of the watersheds
unzip("./data/GIS data/hydrosheds-8966d4509a0958e7559f.zip",
  overwrite = FALSE,
  exdir = "./data/cache/hydroSHEDS"
)
lapply(
  list.files("./data/cache/hydroSHEDS", full.names = TRUE),
  function(zipped) {
    unzip(zipped, overwrite = FALSE, exdir = "./data/cache/hydroSHEDS")
    file.remove(zipped)
  }
)

aus <- rgdal::readOGR(dsn = "./data/cache/hydroSHEDS", layer = "au_bas_15s_beta", GDAL1_integer64_policy = TRUE)
ca <- rgdal::readOGR(dsn = "./data/cache/hydroSHEDS", layer = "ca_bas_15s_beta", integer64 = "no.loss")
lapply(slot(aus, "polygons"), slot, "area")
slot(ca, "data")$BASIN_ID
tst <- foreign::read.dbf("./data/cache/hydroSHEDS/ca_bas_15s_beta.dbf", as.is = TRUE)



tst <- data.table::as.data.table(foreign::read.dbf("./data/GIS data/hydroBASINS/hybas_au_lev00_v1c/hybas_au_lev00_v1c.dbf", as.is = F))
tst[, HYBAS_ID := as.character(HYBAS_ID)]

dt <- data.table::rbindlist(
  lapply(
    list.files("./data/GIS data/hydroBASINS/hybas_au_lev01-06_v1c", pattern = ".dbf$", recursive = TRUE, full.names = TRUE),
    function(dbfFile) data.table::as.data.table(foreign::read.dbf(dbfFile, as.is = TRUE))
  )
)

sum(unique(ddata$regional) %in% dt$HYBAS_ID)
