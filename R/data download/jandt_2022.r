download.file(url = "https://idata.idiv.de/ddm/Data/DownloadZip/3508?version=5349",
              destfile = "./data/cache/jandt_2022.zip", mode = "wb")

utils::read.table(
   file = base::unz(
      description = base::unz(
         description = "./data/cache/jandt_2022.zip",
         filename = "ReSurveyGermany_data.zip"),
      filename = "ReSurveyGermany.csv")
)

