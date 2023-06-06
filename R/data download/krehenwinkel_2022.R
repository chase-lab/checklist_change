# krehenwinkel_2022
if (!file.exists("data/krehenwinkel_2022/rdata.rds")) {

   if (!file.exists("data/cache/krehenwinkel_2022_elife-78521-supp2-v2.xlsx"))
      download.file(url = "https://cdn.elifesciences.org/articles/78521/elife-78521-supp2-v2.xlsx",
                    destfile = "data/cache/krehenwinkel_2022_elife-78521-supp2-v2.xlsx")
   # suppdata::suppdata(x = "https://doi.org/10.7554/eLife.78521", si = 2L)

   # reading sample data ----
   samples <- readxl::read_xlsx(
      path = "data/cache/krehenwinkel_2022_elife-78521-supp2-v2.xlsx",
      range = "OTU_Table!A10:K322",
      col_names = TRUE)
   data.table::setDT(samples)

   # reading community data ----
   taxo <- readxl::read_xlsx(
      path = "data/cache/krehenwinkel_2022_elife-78521-supp2-v2.xlsx",
      range = "OTU_Table!BL8:CCK322",
      col_names = FALSE)
   data.table::setDT(taxo)
   species <- paste(taxo[1], taxo[2])
   species <- data.table::fifelse(
      grepl("NA", species, fixed = TRUE) | duplicated(species),
      unlist(taxo[3]),
      species)
   data.table::setnames(taxo, species)
   taxo <- taxo[-(1:3), -1]

   # merging ----
   ddata <- cbind(samples, taxo)

   # melting species ----
   ddata <- data.table::melt(
      ddata,
      id.vars = c("ID", "Site_ID", "Tree", "Year", "GK_E", "GK_N"),
      measure.vars = 13L:ncol(ddata))
   data.table::setnames(ddata, c("local","regional","tree_species", "year", "longitude", "latitude", "species", "value"))

   ddata <- ddata[value != "0"][, value := 1L]

   # saving ----
   base::dir.create("data/raw data/krehenwinkel_2022/", showWarnings = FALSE)
   base::saveRDS(ddata, "data/raw data/krehenwinkel_2022/rdata.rds")
}
