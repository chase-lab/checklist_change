# botham_2022 - UKBMS - Butterflies of UK
# data were downloaded by hand from the UKBMS website

if (!file.exists('data/raw data/botham_2022/rdata.rds')) {
   # Communities
   # if (!file.exists('data/cache/UKBMS/1286b858-34a7-4ff2-84a1-a55e48d63e86.zip'))
   #    download.file(url = 'https://data-package.ceh.ac.uk/data/1286b858-34a7-4ff2-84a1-a55e48d63e86.zip',
   #                  destfile = 'data/cache/UKBMS/1286b858-34a7-4ff2-84a1-a55e48d63e86.zip', mode = 'wb')

   utils::unzip(zipfile = 'data/cache/UKBMS/1286b858-34a7-4ff2-84a1-a55e48d63e86.zip',
                exdir = 'data/cache/UKBMS/')

   rdata <- unique(data.table::fread(
      file = 'data/cache/UKBMS/1286b858-34a7-4ff2-84a1-a55e48d63e86/data/ukbmssiteindices2021.csv',
      drop = c('SPECIES CODE','COMMON NAME','SITE INDEX'),
      stringsAsFactors = TRUE))

   # Site coordinates
   # if (!file.exists('data/cache/UKBMS/1cfdcd20-afb8-4b58-9ab2-604b90f5242d.zip'))
   #    download.file(url = 'https://data-package.ceh.ac.uk/data/1cfdcd20-afb8-4b58-9ab2-604b90f5242d.zip',
   #                  destfile = 'data/cache/UKBMS/1cfdcd20-afb8-4b58-9ab2-604b90f5242d.zip', mode = 'wb')
   #
   utils::unzip(zipfile = 'data/cache/UKBMS/1cfdcd20-afb8-4b58-9ab2-604b90f5242d.zip',
                exdir = 'data/cache/UKBMS/')

   coords <- data.table::fread(
      file = 'data/cache/UKBMS/1cfdcd20-afb8-4b58-9ab2-604b90f5242d/data/ukbmssitelocationdata2021_v2.csv',
      drop = c("Site_Name", "Gridreference", "Survey_type",
               "First_year_surveyed","Last_year_surveyed",
               "N_sections","N_yrs_surveyed"),
      stringsAsFactors = TRUE)

   # Joining coords and rdata
   data.table::setnames(coords, c('Site_Number', 'Country'), c('SITE CODE', 'COUNTRY'))
   rdata <- rdata[coords, on = c('COUNTRY', 'SITE CODE'), nomatch = NULL]

   base::dir.create('data/raw data/botham_2022/', showWarnings = FALSE)
   base::saveRDS(object = rdata, file = 'data/raw data/botham_2022/rdata.rds')
}
