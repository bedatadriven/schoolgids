
library(tm)
library(pdfbox)
library(parallel)

# Write all PDFs to text files
pdfs <- list.files("pdf", pattern = "\\.pdf$")

# We will require starting one JVM per worker to
# support pdf box, so be conservative about the number of workers
num_workers <- detectCores() - 1

cl <- makeCluster(num_workers, outfile = "")
clusterApplyLB(cl, pdfs, function(pdf) {
  tryCatch({
    vn <- substring(pdf, first = 1, last = 6)
    output <- file.path("pdf", sprintf("%s.txt", vn))
    if(!file.exists(output)) {
      cat(sprintf("Extracting text from %s...\n", pdf))
      suppressMessages({ 
        pages <- pdfbox::extract_text(file.path("pdf", pdf))
        writeLines(pages$text, con = output, sep = "\n")
      })
    }
  }, error = function(e) {
    cat(sprintf("Error converting %s...: %s\n", pdf, e$message))
  })
})

# Clean up our cluster
stopCluster(cl)

