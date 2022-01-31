# Preparing a reference list for all data sets ----
## the citation for the data repository and the article are associated when available.
path_to_homogenisation_dropbox_folder <- base::readRDS(file = "./data/references/homogenisation_dropbox_folder_path.rds")
if (!file.exists(paste0(path_to_homogenisation_dropbox_folder, "_data_extraction/list of papers.xlsx"))) {
   references <- readxl::read_xlsx(path = paste0(path_to_homogenisation_dropbox_folder, "/_data_extraction/list of papers.xlsx"), col_names = TRUE, na = c("", "NA"))
   data.table::setDT(references)
   references <- references[!is.na(`follow up`) & `follow up` == "merge", .(dataset_id, reference, DOI)]
   references[, paste0("doi", 1:3) := data.table::tstrsplit(x = DOI, " +\\| +", perl = TRUE)]
   references <- data.table::melt(references, id.vars = c("dataset_id", "reference"), measure.vars = paste0("doi", 1:3), value.name = "DOI", na.rm = FALSE)[, variable := NULL]
   base::saveRDS(object = references, file = "./data/references/references_vector.rds")
} else {
   references <- base::readRDS(file = "./data/references/references_vector.rds")
}


# Building the .bib reference file
bib <- rcrossref::cr_cn(dois = na.omit(references$DOI), locale = "en-US")
complete_bib <- c(unlist(stringi::stri_split_lines(bib)), "\n", base::readLines("./data/references/references_without_DOI.bib"), "\n", base::readLines("./data/references/fitzgerald_1997.bib"))
complete_bib <- base::enc2utf8(complete_bib)
base::writeLines(text = complete_bib, "./data/references/references.bib")

# Building the formatted reference vector
# vec <- RefManageR::ReadBib(file = "./data/references.bib", .Encoding = "UTF-8")

# Building the reference data.frame ----
## handling bib collection in Zotero -> spreadsheet  ----
## looking for missing references ----
references[, length(unique(na.omit(DOI))), by = dataset_id][V1 != 0L][order(dataset_id)]

## -> merge with other data set level metadata.  ----





if (FALSE) {
   RefManageR::PrintBibliography(bib[[1]])
   bib_without_DOI <- bibtex::read.bib(file = "./data/references/references_without_DOI.bib", encoding = "UTF-8")
   bib_without_DOI <- RefManageR::ReadBib(file = "./data/references/references_without_DOI.bib", .Encoding = "UTF-8")
   # bibtex::write.bib(entry = bib_without_DOI, file = './data/references.bib', append = TRUE)

   # RefManageR::ReadBib("./data/references.bib", .Encoding = "UTF-8")
   RefManageR::GetBibEntryWithDOI(doi = DOI, temp.file = "./data/references/references.bib", delete.file = FALSE) # works well but does not give back NAs
   tst <- utils::bibentry(bibtype = "Article", verbose = TRUE) # buiding a reference by providing individual journal title, year and author fields
}
