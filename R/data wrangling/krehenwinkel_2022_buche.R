# # krehenwinkel_2022_buche
# ddata <- base::readRDS("data/raw data/krehenwinkel_2022/rdata.rds")
# ddata <- ddata[tree_species == "Buche"][, c("tree_species", "value") := NULL]
# coords <- sf::st_as_sf(ddata[, .(local, latitude, longitude)], coords = c("latitude", "longitude"), crs = sf::st_crs("EPSG:23033"))
# # 2583
# # 5556
# # 23033
#
# coords <- sf::st_transform(coords, crs = "EPSG:4326")
# coords <- sf::st_coordinates(coords)
# coords
# ddata[, ":="(
#    latitude = coords[,'Y'],
#    longitude = coords[, 'X']
# )]
#
# world_map <- rnaturalearth::ne_countries(scale = 50, returnclass = 'sf')
# germ <- filter(world_map, name == "Germany")
# plot(germ, max.plot = 1)
# points(ddata$longitude, ddata$latitude)
