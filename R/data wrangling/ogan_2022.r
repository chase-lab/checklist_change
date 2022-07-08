# ogan_2022
dataset_id <- "ogan_2022"

ddata <- base::readRDS(file = "./data/raw data/ogan_2022/rdata.rds")

# melting species ----
species_columns <- grep(pattern = "[A-Z][a-z]{0,2}_[a-z]*$",
                        x = colnames(ddata), value = FALSE)
ddata[, (species_columns) := lapply(
   .SD,
   function(column) replace(column, column == 0L, NA_integer_)),
   .SDcols = species_columns] # replace all 0 values by NA

ddata <- data.table::melt(
   data = ddata,
   id.vars = c("name_site", "year", "area", "Lat", "Long"),
   measure.vars = species_columns,
   variable.name = "species",
   na.rm = TRUE
)

data.table::setnames(ddata, c("name_site","area","Lat","Long"),
                     c("local","alpha_grain","latitude","longitude"))

# community ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Rhineland-Palatinate"
)]

# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude, alpha_grain)])
meta[, ":="(
   taxon = "Fish",
   realm = "Freshwater",

   effort = 1L,

   data_pooled_by_authors = FALSE,

   alpha_grain_unit = "km2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "grassland area given by the authors",

   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "Sum of the plot areas sampled each year",

   gamma_bounding_box = 19846L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "area of the state of Rhineland-Palatinate",

   comment = "Extracted from Dryad repository Ogan, Sophie (2022), Re-surveys reveal biotic homogenization of Orthoptera assemblages as a consequence of environmental change, Dryad, Dataset, https://doi.org/10.5061/dryad.tqjq2bw1t. Authors resurveyed grasslands in Rhineland-Palatinate, Germany to assess the trends of Orthoptera species. METHODS: 'Re-surveys of all 199 study sites took place between August 2018 and October 2020. At least two surveys were conducted for each study site to consider variation in phenology among species. At each site, one sampling session was done in spring (end of April–middle of June) to cover Tetrix spp., the field cricket Gryllus campestris and the mole cricket Gryllotalpa gryllotalpa (nymphs of identifiable species were also recorded). A second census was done between July and August, which represents the peak Orthoptera occurrence in the study region. In case of an early second census date (e.g. mid-July), a third survey was scheduled in late summer (end of August to September) to adequately cover the occurrence of late summer species (due to the start of the project in August 2018, some sites were first surveyed in summer and then in spring and July 2019). Our survey intensity was probably higher than during the historical surveys in P1 (most of which were only conducted 1–2 times). Nevertheless, we used a sampling design with a slightly higher effort to minimize omission error. This means that any estimates of declines are conservative as it is more likely that species may have been missed during the historical surveys than in P2.[...]Overall, the method used during our survey followed the method of the original studies as closely as possible (acoustic and visual counts, study period 1–2 years), except for being more comprehensive (at least 2 surveys rather than 1–2 surveys), to avoid omission error and provide a solid basis for future surveys.",
   comment_standardisation = "none needed"
)][, gamma_sum_grains := sum(alpha_grain), by = year]

ddata[, c("alpha_grain","latitude","longitude") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
