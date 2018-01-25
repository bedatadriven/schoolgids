library(stringr)

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

# Only pdf URLs
allPdf <- lapply(1L:length(all), function(i) all[[i]]["url"])

#' Downloads pdf files with the pdf name
#' Pdf name is the set of strings after the last part of the url "/"
#' A sequence is added beginning o the pdf names to avoid overwriting
#' 
lapply(1L:length(allPdf), function(n) {
  lapply(1L:length(allPdf[[n]]), function(i) { 
    tryCatch({
      download.file(
        allPdf[[n]][i,], 
        destfile = paste(file.path("pdf"), paste(n, i, str_extract(allPdf[[n]][i,], "[^/]+(?=/$|$)"), sep="_"), sep = "/")
      )
    }, error = function(e) {
      cat(sprintf("...ERROR: %s\n", e$message))
    })
  })
})

# -- FIN --
