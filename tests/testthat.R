data.table::setDTthreads(4)
testthat::test_dir(path = "tests/testthat/")
data.table::setDTthreads(8)
