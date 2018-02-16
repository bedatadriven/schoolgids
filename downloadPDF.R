library(parallel)

### Read list of URLs
df <- read.csv("school_urls.csv", stringsAsFactors = FALSE)


### Downloads pdf files with the pdf name

if(!dir.exists("pdf")) {
  dir.create("pdf")
}

tasks_url <- lapply(1L:nrow(df), function(i) {
  list(id = df[i, "VESTIGINGSNUMMER"],
       url = df[i, "url"])
})

downloadPDF <-  function(task) {
  if(!is.na(task$url)) {
    cat(sprintf("Downloading pdfs %s at %s...\n", task$id, task$url))
    url_file <- file.path("pdf", sprintf("%s.url", task$id))
    pdf_file <- file.path("pdf", sprintf("%s.pdf", task$id))
    
    if(!file.exists(url_file)) {
      tryCatch({
        files <- download.file(task$url, destfile = pdf_file)
        writeLines(text = task$url, con = url_file)
      }, error = function(e) {
        cat(sprintf("...ERROR: %s\n", e$message))
      })
      TRUE
    } else {
      FALSE
    }
  }
}

# Use more workers than cores
# as most of the time is spent waiting on the network
num_workers <- detectCores() * 4

cl <- makeCluster(num_workers, outfile = "")
clusterApplyLB(cl, tasks_url, downloadPDF)
stopCluster(cl)

# -- FIN --
