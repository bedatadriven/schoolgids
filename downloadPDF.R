# Path
gids.path <- "gids"

# Remove NAs function
na.omit.list <- function(y) { return(y[!sapply(y, function(x) all(is.na(x)))]) }

collectFromPath <- function(path){
  filenames <- list.files(path = path, pattern = ".csv$", full.names = FALSE)
  datalist <- lapply(filenames, function(file) { read.csv(file.path(path, file), stringsAsFactors = FALSE) })
  na.omit.list(datalist)
}

# All pdf links in list without NA
all <- collectFromPath(gids.path)

# Only URLs
allPdf <- lapply(1L:length(all), function(i) all[[i]]["url"])

#rm(list=ls())