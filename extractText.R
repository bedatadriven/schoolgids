
library(tm)
library(pdftools)


# Write all PDFs to text files
pdfs <- list.files("pdf", pattern = "\\.pdf$")
for(pdf in pdfs) {
  tryCatch({
      suppressMessages({ 
        vn <- substring(pdf, first = 1, last = 6)
        text <- pdf_text(pdf = file.path("pdf", pdf))
        writeLines(text, con = file.path("pdf", sprintf("%s.txt", vn)))
      })
  }, error = function(e) {
      cat(sprintf("Error converting %s...: %s\n", pdf, e$message))
  })
}


corpus <- VCorpus(DirSource("pdf", pattern="[0-9]{2}[A-Z]{2}[0-9]{2}\\.txt$"), readerControl = list(reader = readPlain, language = "nl"))
names(corpus) <- substring(names(corpus), 1, 6)

# Add metadata from the schools list
schools <- read.csv("schools.csv", sep=";", fill = TRUE, stringsAsFactors = FALSE)
index <- match(names(corpus), schools$VESTIGINGSNUMMER)

stopifnot(all(!is.na(index)))

for(tag in names(schools)) {
  meta(corpus, tolower(tag)) <- schools[index, tag]
}

# Lookup the URL we downloaded for each pdf
meta(corpus, "pdf.url") <- sapply(names(corpus), function(id) {
  readLines(sprintf("pdf/%s.url", id))[[1]]
})

saveRDS(corpus, "schoolgids2017v2.rds")
saveRDS(corpus[sample(length(corpus), size = 500)], "schoolgids2017v2_500.rds")
saveRDS(corpus[sample(length(corpus), size = 100)], "schoolgids2017v2_100.rds")
