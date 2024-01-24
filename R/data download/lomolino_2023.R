# lomolino_2023
## Extracting raw data from pdf
raw <- tabulizer::extract_tables(
   file = "data/raw data/lomolino_2023/lomolino_2023_59967-Table_S1.pdf",
   pages = c(2:10), area = list(
      Wallacea1 =  c(y0 = 80, x0 = 20, y1 = 1000, x1 = 1000),
      Wallacea2 =  c(y0 = 10, x0 = 20, y1 = 1000, x1 = 1000),
      Wallacea3 =  c(y0 = 10, x0 = 20, y1 = 300, x1 = 1000),
      Macronesia = c(y0 = 80, x0 = 20, y1 = 315, x1 = 600),
      Pacific_isolates =  c(y0 = 150, x0 = 20, y1 = 675, x1 = 1000),
      Mediterranean_Islands1 =  c(y0 = 100, x0 = 20, y1 = 1050, x1 = 1000),
      Mediterranean_Islands2 =  c(y0 = 10, x0 = 20, y1 = 500, x1 = 1000),
      Caribbean_Archipelago1 =  c(y0 = 120, x0 = 20, y1 = 1200, x1 = 1000),
      Caribbean_Archipelago2 =  c(y0 = 10, x0 = 20, y1 = 230, x1 = 1000)),
   guess = FALSE, output = "matrix")

## Regional
names(raw) <- c(rep("Wallacea", 3), "Macronesia", "Pacific Isolates",
                rep("Mediterranean Islands", 2), rep("Caribbean Archipelago", 2))
## Column names
raw[1:3] <- lapply(raw[1:3], function(page) {
   page <- data.table::as.data.table(page)
   data.table::setnames(
      x = page,
      new = c("species", "Flores", "Luzon", "Mindanao", "Mindoro", "Negros", "Timor"))
})

raw[[4]] <- data.table::as.data.table(raw[[4]])
data.table::setnames(
   x = raw[[4]],
   new = c("species", "Fuerteventura", "Gran Canaria", "Tenerife"))

raw[[5]] <- data.table::as.data.table(raw[[5]])
data.table::setnames(
   x = raw[[5]],
   new = c("species", "Isabela", "Santa Cruz", "Amami", "Kume", "Okinawa", "Tokuno", "Santa Rosae"))

raw[6:7] <- lapply(raw[6:7], function(page) {
   page <- data.table::as.data.table(page)
   data.table::setnames(
      x = page,
      new = c("species", "Crete", "Cyprus", "Karpathos", "Majorca", "Naxos", "Sardinia", "Sicily", "Tilos"))
})

raw[[8]] <- data.table::as.data.table(raw[[8]])
data.table::setnames(
   x = raw[[8]],
   new = c("species", "Anguilla", "Antigua", "Barbados", "Bonaire", "Cuba", "Curaçao", "Hispaniola", "Jamaica", "Martinique", "Puerto Rico", "Saint Kitts", "Saint Lucia", "Saint Vincent"))

raw[[9]] <- data.table::as.data.table(raw[[9]])
data.table::setnames(
   x = raw[[9]],
   new = c("species", "Anguilla", "Antigua", "Barbados", "Bonaire", "Cuba", "Curaçao", "Hispaniola", "Jamaica", "Martinique", "Puerto Rico", "Saint Kitts", "Saint Lucia"))

# Saving data
base::saveRDS(
   object = data.table::rbindlist(raw, fill = TRUE, idcol = TRUE),
   file = "data/raw data/lomolino_2023/rdata.rds")
