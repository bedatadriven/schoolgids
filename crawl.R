
source("scrape.R")
library(parallel)

schools <- read.table("schools.csv", 
                      sep=";", 
                      quote="", 
                      fill = TRUE, 
                      header = TRUE, 
                      stringsAsFactors = FALSE)



if(!dir.exists("gids")) {
  dir.create("gids")
}

tasks <- lapply(1:nrow(schools), function(i) {
  list(id = schools[i, "VESTIGINGSNUMMER"],
       url = schools[i, "INTERNETADRES"])
})

executeTask <-  function(task) {
  
  source("scrape.R")
  cat(sprintf("Crawling school %s at %s...\n", task$id, task$url))
  url_file <- file.path("gids", sprintf("%s.csv", task$id))
  if(!file.exists(url_file)) {
    tryCatch({
      links <- find_schoolgids(task$url)
      write.csv(links, url_file, row.names = FALSE)
      
    }, error = function(e) {
      cat(sprintf("...ERROR: %s\n", e$message))
    })
    TRUE 
  } else {
    FALSE
  }
}

# Use more workers than cores
# as most of the time is spent waiting on the network
num_workers <- detectCores() * 8

cat(sprintf("Using %d workers.\n", num_workers))

cl <- makeCluster(num_workers, outfile = "")
clusterExport(cl, ls())
clusterApplyLB(cl, tasks, executeTask)
stopCluster(cl)

# Aggregate the individual results into a single table

csv.files <- list.files(path = "gids", pattern = ".csv$", full.names = FALSE)
v_number <- as.character(substr(csv.files, 1L, 6L))
gids_url <- sapply(csv.files, function(file) {
  csv <- read.csv(file.path("gids", file), nrows = 1L, stringsAsFactors = FALSE)
  if (nrow(csv) == 0L || is.null(csv$url)) {
    NA_character_
  } else {
    csv[1, "url"]
  }
})

pdf.url <- data.frame(VESTIGINGSNUMMER = v_number,
                      url = gids_url,
                      stringsAsFactors = FALSE)

write.csv(pdf.url, file = "school_urls.csv", row.names = FALSE)

