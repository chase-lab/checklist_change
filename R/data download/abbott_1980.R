# abbott_1980
# Appendix 1 extracted by hand from the pdf to text.

# raw <- data.table::fread(file = "data/raw data/abbott_1980/raw_text_extraction.txt",
#                          stringsAsFactors = FALSE, header = FALSE,
#                          sep = NULL)

raw <- stringi::stri_read_lines(
   con = "data/raw data/abbott_1980/raw_text_extraction.txt",
   encoding = "UTF-8")

for (i in length(raw):2L) {
   if (grepl(pattern = "^[0-9]", x = raw[[i]])) {
      raw[[i - 1L]] <- stringi::stri_paste(raw[[i - 1L]], raw[[i]], sep = " ")
      raw[[i]] <- "delete"
   }
}
# Cleaning
raw <- raw[!grepl(pattern = "delete|^[A-Z]* ?,?[A-Z]*$", x = raw)]
raw <- sub(pattern = "*", replacement = "", x = raw, fixed = TRUE)
raw <- sub(pattern = "([0-9])([A-Z])", replacement = "\\1 \\2", x = raw, perl = TRUE)
raw <- stringi::stri_replace_all_fixed(
   str = raw,
   pattern = c("3 9a", "1 5 CEF", "II0", "93 CR", "1i1 E", "144 CE"),
   replacement = c("39a", "15 CEF", "110", "93 CE", "111 E", "111 CE"),
   vectorise_all = FALSE)
# Prepare for splitting
raw <- gsub(pattern = ",? (?=[0-9])", replacement = "|", x = raw, perl = TRUE)

# Saving rdata
rdata <- data.table::tstrsplit(raw, split = "|", fixed = TRUE)
data.table::setDT(rdata)
base::saveRDS(rdata, file = "data/raw data/abbott_1980/rdata.rds")

# Reading in Appendix 2
env <- pdftools::pdf_text(
   pdf = "data/raw data/abbott_1980/Abbott & Black 1980 J Biogeogr.pdf")[[13L]]
# Extracting alpha_grain
env <- stringi::stri_extract_all_regex(
   str = env,
   pattern = "(?<= )[0-9]{1,3}a?, ?[0-9]{1,6}(?=, *[0-9])")
data.table::setDT(env)
env[, c("local", "alpha_grain") := data.table::tstrsplit(V1, ",")]

# Saving alpha_grain
base::saveRDS(object = env, file = "data/raw data/abbott_1980/env.rds")
