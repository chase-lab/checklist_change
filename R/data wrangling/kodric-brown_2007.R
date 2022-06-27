## kodric-brown_2007


dataset_id <- "kodric-brown_2007"

ddata <- data.table::fread(paste0("data/raw data/", dataset_id, "/rdata.csv"), skip = 1L)

# melting sites
ddata <- data.table::melt(ddata,
                          id.vars = c("species"),
                          value.name = "value",
                          variable.name = "local"
)

# recoding and melting 123 values
ddata[, c("1991", "2003") := data.table::tstrsplit(
   base::ifelse(
      value == "+",
      paste("1", "1"),
      data.table::fifelse(
         value == "E",
         paste("1", ""),
         paste("", "1")
      )
   ),
   split = " "
)]
ddata <- data.table::melt(ddata,
                          id.vars = c("local", "species"),
                          measure.vars = c("1991", "2003"),
                          value.name = "value",
                          variable.name = "year"
)
ddata <- ddata[!is.na(value) & value != ""]


ddata[, ":="(
   dataset_id = dataset_id,
   local = gsub("\\*", "", local),
   regional = "Dalhousie Springs"
)]


meta <- unique((ddata[, .(dataset_id, regional, local, year)]))
meta[, ":="(
   taxon = "Fish",
   realm = "Freshwater",

   latitude = -26.438867,
   longitude = 135.494492,

   effort = 1L,

   alpha_grain = 9600L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "lake_pond",
   alpha_grain_comment = "this is roughly the area of the largest spring pond of the park. Trap area and number unknown",

   gamma_bounding_box = 72L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "area covered by the Dalhousie Springs, given by the authors",

   comment = 'Extracted from kodric-brown_2007 table 1 (https://doi.org/10.1111/j.1472-4642.2007.00395.x) (table extraction from pdf). The authors sampled fish in 30 ponds of a nature park in 1991 and resurveyed in 2003. Regional is the Dalhousie Springs, Witjira National Park, Australia, local are springs. years correspond to a first survey and a resurvey. Effort to get these checklists varies a lot in time and in space. During the resurvey, no seine nets were used and special effort was made to found species that were originally present in 1991. BUT "We used essentially identical methods to sample intensively for the presence of each fish species.',
   comment_standardisation = "none needed"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
