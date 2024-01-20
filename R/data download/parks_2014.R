dataset_id <- "parks_2014"

if (!file.exists("data/raw data/parks_2014/table_list.rds")) {
  if (!file.exists("data/cache/parks_2014_AmMidNat_2014_Parks_historical_changes.pdf")) {
    download.file(
      url = "https://www.webpages.uidaho.edu/quistlab/publications/AmMidNat_2014_Parks_historical_changes.pdf",
      destfile = "data/cache/parks_2014_AmMidNat_2014_Parks_historical_changes.pdf",
      method = "auto", mode = "wb"
    )
  }

  if (!file.exists("data/cache/parks_2014_AmMidNat_2014_Parks_historical_changes.pdf")) {
    download.file(
      url = "https://www.webpages.uidaho.edu/quistlab/publications/AmMidNat_2014_Parks_historical_changes.pdf",
      destfile = "data/cache/parks_2014_AmMidNat_2014_Parks_historical_changes.pdf",
      method = "curl",
    )
  }
}
