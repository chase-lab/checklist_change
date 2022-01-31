# su_2021
dataset_id <- "su_2021"

if (!file.exists("./data/raw data/su_2021/Sugh-biodiveristy_freshwaterfish_paper_abd3369/000_input/Occ_bef_2456_10682")) {
  dir.create("./data/cache/su_2021", showWarnings = FALSE)
  # downloading the 300+ Mb archive only once
  suppdata::suppdata(
    x = "10.6084/m9.figshare.13383170.v1", from = "figshare", si = 3, zip = TRUE,
    dir = "./data/cache/su_2021", save.name = "10.6084_m9.figshare.13383170.v1_3.zip"
  )

  dir.create("./data/raw data/su_2021", showWarnings = FALSE)
  unzip(
    zipfile = "./data/cache/su_2021/10.6084_m9.figshare.13383170.v1_3.zip",
    files = paste0("Sugh-biodiveristy_freshwaterfish_paper_abd3369/000_input/", c("Occ_bef_2456_10682", "Occ_aft_2456_10682", "basin_2456")),
    exdir = "./data/raw data/su_2021"
  )
}
