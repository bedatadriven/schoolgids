library(parallel)

# Path
csv.path <- "gids"


df <- merge(x = pdf.url, y = schools, by = "VESTIGINGSNUMMER")

write.csv(df, file = "schools_w_url.csv", row.names = FALSE)

### Downloads pdf files with the pdf name

if(!dir.exists("pdf")) {
  dir.create("pdf")
}

tasks_url <- lapply(1L:nrow(df), function(i) {
  list(id = df[i, "VESTIGINGSNUMMER"],
       url = df[i, "url"])
})

downloadPDF <-  function(task) {

  cat(sprintf("Downloading pdfs %s at %s...\n", task$id, task$url))
  url_file <- file.path("pdf", sprintf("%s.pdf", task$id))
  if(!file.exists(url_file)) {
    tryCatch({
      files <- download.file(task$url, destfile = paste(file.path("pdf"), paste(task$id, ".pdf", sep = ""), sep = "/"))
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
num_workers <- detectCores() * 4

cl <- makeCluster(num_workers, outfile = "")
clusterExport(cl, ls())
clusterApplyLB(cl, tasks_url, downloadPDF)
stopCluster(cl)

# -- FIN --
