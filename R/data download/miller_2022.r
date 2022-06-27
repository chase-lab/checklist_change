dataset_id <- "miller_2022"

ddata <- read.csv(
   file = unz(
      description = suppdata::suppdata(x = "https://doi.org/10.6084/m9.figshare.17009027", from = "figshare", dir = "./data/cache/", save.name = "miller_2022_figshare_repo.zip", si = 1L, zip = TRUE),
      filename = "2_Species occurrence.csv", encoding = "UTF-8")
)
data.table::setDT(ddata)
