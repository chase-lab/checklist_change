# # hamstead_2019
# # extraction from the close-access article directly with tabula
# page1and2 <- data.table::fread("./data/raw data/hamstead_2019/tabula-hamstead_2019_aqc.3220.csv", encoding = "UTF-8", fill = FALSE)
# page3 <- tabulizer::extract_tables(file = "data/cache/hamstead_2019_aqc.3220.pdf",  pages = 14, encoding = "UTF-8", method = "stream", output = "data.frame")[[1]]
#
# rdata <- rbind(page1and2, page3, use.names = FALSE)
#
# saveRDS(object = rdata, file = "./data/raw data/hamstead_2019/extracted_data.rds")
