# Preparing a reference list for all data sets ----
dois <- unique(data.table::fread(file = 'data/metadata.csv', select = c('dataset_id','doi'), na.strings = ''))
dois[, c('doi','doi2') := data.table::tstrsplit(dois$doi, ' *\\| *')]
dois <- data.table::melt(data = dois, id.vars = 'dataset_id', value.name = 'doi', na.rm = TRUE)[, variable := NULL]

# Building the .bib reference file
bib <- rcrossref::cr_cn(dois = dois$doi, locale = "en-US")
saveRDS(object = bib, file = 'data/references/raw_references.rds')
bib <- unlist(stringi::stri_split_lines(bib))
bib <- base::enc2utf8(bib)
base::writeLines(text = bib, "./data/references/references.bib")

# Building the formatted reference vector
rcrossref::get_styles()
rcrossref::cr_cn(dois = dois$doi, locale = "en-US", format = "text", style = 'nature')
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
