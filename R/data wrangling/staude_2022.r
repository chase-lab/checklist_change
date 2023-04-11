dataset_id <- "staude_2022"

ddata <- base::readRDS(file = "./data/raw data/staude_2022/rdata.rds")

# recoding and splitting periods
ddata[, trajectory := c("2001", "2001-2015", "2015")[data.table::chmatch(trajectory, c("lost","persisting", "gained"))]
]
ddata[, c("tmp1","tmp2") := data.table::tstrsplit(x = trajectory, split = "-", fixed = TRUE)]

ddata <- data.table::melt(data = ddata,
                          id.vars = c("habitat","site","speciesKey"),
                          measure.vars = c("tmp1","tmp2"),
                          value.name = "year",
                          na.rm = TRUE)
data.table::setnames(ddata, new = c("regional","local","species","deleteME","year"))
ddata <- unique(ddata[regional == "Summit"])

# Community data ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Mountain summits, Europe",

   value = 1L,
   metric = "pa",
   unit = "pa",

   deleteME = NULL
)]

# Metadata ----
meta <- unique((ddata[, .(dataset_id, regional, local, year)]))
meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   latitude = 47L,
   longitude = 13L,

   effort = 8L,

   alpha_grain = 0.25,
   alpha_grain_unit = "ha",
   alpha_grain_type = "ecosystem",
   alpha_grain_comment = "median area of the summits given by the authors",

   gamma_bounding_box = 2.98 * 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coarse convex hull covering the summit ecostystems",

   comment = "Extracted from repository https://doi.org/10.6084/m9.figshare.12514172.v1 associated to article Staude, I.R., Pereira, H.M., Daskalova, G.N., Bernhardt-Römermann, M., Diekmann, M., Pauli, H., et al. (2022) Directional turnover towards larger-ranged plants over time and across habitats. Ecology Letters, 25, 466– 482. Available from: https://doi.org/10.1111/ele.13937  . METHODS: 'We synthesised data [...]. Mountain summits are represented by 52 sites from the Global Observation Research Initiative in Alpine environments (GLORIA, gloria.ac.at, Pauli et al., 2015) [...] Summits were always resurveyed in eight spatial sections that together covered the entire area from the highest summit point to the contour line 10 m in elevation below this point. The median summit area was 0.25 ha.'",
   comment_standardisation = "only summit ecosystems included, duplicated rows in raw data were excluded"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)

