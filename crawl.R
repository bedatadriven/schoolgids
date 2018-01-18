
source("scrape.R")
library(parallel)

schools <- read.table("schools.csv", 
                      sep=";", 
                      quote="", 
                      fill = TRUE, 
                      header = TRUE, 
                      stringsAsFactors = FALSE)

# Use twice as many workers as we have cores
# as most of the time is spent waiting on the network
num_workers <- detectCores() * 2

if(!dir.exists("gids")) {
  dir.create("gids")
}

cl <- makeCluster(num_workers)
clusterExport(cl, ls())

tasks <- lapply(1:nrow(schools), function(i) {
  list(id = schools[i, "VESTIGINGSNUMMER"],
       url = schools[i, "INTERNETADRES"])
})

executeTask <-  function(task) {
  
  source("scrape.R")
  
  url_file <- file.path("gids", sprintf("%s.csv", task$id))
  if(!file.exists(url_file)) {
    links <- find_schoolgids(task$url)
    write.csv(links, url_file, row.names = FALSE)
    TRUE 
  } else {
    FALSE
  }
}

clusterApplyLB(cl, tasks, executeTask)
stopCluster(cl)
