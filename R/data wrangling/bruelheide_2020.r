# bruelheide_2020

dataset_id <- "bruelheide_2020"

ddata <- base::readRDS(file = "./data/raw data/bruelheide_2020/rdata.rds")
data.table::setnames(ddata, c("Site_ID", "Species"), c("local", "species"))

# recoding, splitting and melting period
ddata[, periodraw := data.table::fifelse(
  Year_last_obs <= 2016, "historical",
  data.table::fifelse(Year_first_obs >= 1981 & Year_last_obs >= 2017, "present", "historical+present")
)]
ddata[, paste0("tmp", 1:2) := data.table::tstrsplit(periodraw, "\\+")]
ddata <- data.table::melt(ddata,
  measure.vars = paste0("tmp", 1:2),
  value.name = "period",
  na.rm = TRUE
)



ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Black Forest",
  year = c(1972L, 2017L)[match(period, c("historical", "present"))],

  value = 1L,

  period = NULL,
  periodraw = NULL,
  variable = NULL,
  Year_first_obs = NULL,
  Year_last_obs = NULL,
  Ext_event = NULL

)]

# environment data: area this is supplementary data 1 from https://doi.org/10.1111/ddi.13184
env <- data.table::as.data.table(
  docxtractr::docx_extract_tbl(
    docx = docxtractr::read_docx(
      paste0("./data/raw data/", dataset_id, "/ddi13184-sup-0001-appendixs1-s4.docx")
    ),
    tbl_number = 1
  )
)

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Plants",
  realm = "Terrestrial",

  effort = 1L,



  latitude = 48L,
  longitude = 8L,

  alpha_grain = env$Area..ha.[match(local, env$Site.ID)],
  alpha_grain_unit = "ha",
  alpha_grain_type = "ecosystem",
  alpha_grain_comment = "checklist",

  gamma_bounding_box = 530L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "this is the area of the L shaped area highlighted by the authors in figure 1 of the paper.",

  gamma_sum_grains = sum(as.numeric(env$Area..ha.)),
  gamma_sum_grains_unit = "ha",
  gamma_sum_grains_type = "ecosystem",
  gamma_sum_grains_comment = "sum of the areas of the sampled ecosystems",

  comment = "Extracted from Bruelheide et al 2020 dryad repository. We considered two time periods: an early one (1972-1980) and a late one (2017-2020). Anything that has 'first appearance' in early time period would be 'present initially'.  Anything that has first appearance only in the second time period would be 'new' (occupancy change column 1) and anything that has last appearance before 2017-220 (occupancy change column -1) as a local extinction.",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.5061/dryad.mw6m905vj | https://doi.org/10.1111/ddi.13184'
)]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
