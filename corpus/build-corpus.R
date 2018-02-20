
# This script compiles the extracted text documents into a serialized VCorpus

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

saveRDS(corpus, "schoolgids2017v4.rds")
saveRDS(corpus[sample(length(corpus), size = 500)], "schoolgids2017v4_500.rds")
saveRDS(corpus[sample(length(corpus), size = 100)], "schoolgids2017v4_100.rds")
