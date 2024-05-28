## kodric-brown_2007
dataset_id <- "kodric-brown_2007"

ddata <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/rdata.csv"),
   skip = 1L)

# melting sites
ddata <- data.table::melt(data = ddata,
                          id.vars = c("species"),
                          value.name = "value",
                          variable.name = "local"
)

# recoding and melting 123 values
ddata[j = c("1991", "2003") := data.table::tstrsplit(
   data.table::fcase(
      value == "+", paste("1", "1"),
      value == "E", paste("1", ""),
      value == "C", paste("", "1"),
      default = NA),
   split = " ")
][j = c("1991", "2003") := lapply(.SD, function(x) base::replace(
   x = x,
   list = stringi::stri_isempty(x),
   values = NA)),
  .SDcols = c("1991", "2003")]

ddata <- data.table::melt(data = ddata,
                          id.vars = c("local", "species"),
                          measure.vars = c("1991", "2003"),
                          value.name = "value",
                          variable.name = "year",
                          na.rm = TRUE)

ddata[, ":="(
   dataset_id = dataset_id,

   local = sub("\\*", "", local),
   regional = "Dalhousie Springs",

   value = NULL
)]


meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Fish",
   realm = "Freshwater",

   latitude = -26.438867,
   longitude = 135.494492,

   effort = 1L,
   data_pooled_by_authors = FALSE,

   alpha_grain = 9600L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "lake_pond",
   alpha_grain_comment = "this is roughly the area of the largest spring pond of the park. Trap area and number unknown",

   gamma_bounding_box = 72L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "functional",
   gamma_bounding_box_comment = "area covered by the Dalhousie Springs, given by the authors",

   comment = "Extracted from kodric-brown_2007 table 1 (Kodric-Brown, A., Wilcox, C., Bragg, J.G. and Brown, J.H. (2007), Dynamics of fish in Australian desert springs: role of large-mammal disturbance. Diversity and Distributions, 13: 789-798. https://doi.org/10.1111/j.1472-4642.2007.00395.x) (table extraction from pdf). The authors sampled fish in 30 ponds of a nature park in 1991 and resurveyed in 2003. years correspond to a first survey and a resurvey. Effort to get these checklists varies a lot in time and in space. During the resurvey, no seine nets were used and special effort was made to found species that were originally present in 1991. BUT 'We used essentially identical methods to sample intensively for the presence of each fish species.'
Regional is the Dalhousie Springs, Witjira National Park, Australia, local are springs. ",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.1111/j.1472-4642.2007.00395.x"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
   row.names = FALSE
)

data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
   row.names = FALSE
)
