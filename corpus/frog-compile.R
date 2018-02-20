

## This script compiles the output of all the frogged documents into a single grand table.

library(stringr)

bioIndex <- function(x) {
  start <- (substring(x, 1, 1) == "B")
  index <- as.integer(cumsum(start))
  index[substring(x, 1, 1) == "O"] <- NA
  index
}

bioType <- function(x) {
  c <- substring(x, 1, 1)
  ifelse(c=="O",NA_character_, str_match(x, "[BIO]-([A-Z]+)")[, 2]) 
}

outputs <- list.files("frog", pattern = "\\.out$", recursive = TRUE, full.names = TRUE)
merged <- file("schoolgids.tab", open = "wt", encoding = "UTF-8")

for(output in outputs) {
  
  
  table <- read.delim(output, stringsAsFactors = FALSE, quote="", col.names = c("position", "word", "lemma", "morph", 
                                                                      "pos", "prob", "ner", "chunk", "parse1", "parse2"))
  
  vn <- as.character(stringr::str_match(output, "[0-9][0-9][A-Z][A-Z][0-9][0-9]"))
  
  cat(sprintf("Reformatting %s...\n", vn))
  
  stopifnot(nchar(vn) == 6)
  table$school <- rep(vn, length=nrow(table))
  table
  table$pos <- gsub("\\(.*", "", table$pos)
  table$sent <- as.integer(cumsum(table$position==1))
  table$chunk_index <- bioIndex(table$chunk)
  table$chunk_type <- bioType(table$chunk)
  table$ner_index <- bioIndex(table$ner)
  table$ner_type <- bioType(table$ner)
  
  result <- table[, c("school", "sent", "position", "word", "lemma", "pos", "ner_index", "ner_type", "chunk_index", "chunk_type")] 
                        
  write.table(result, merged, col.names = FALSE, row.names = FALSE, quote = FALSE, sep="\t") 
}
close(merged)


complete <-read.delim("schoolgids.tab", quote="",
              col.names =  c("school",    "sent",    "position", "word",      "lemma", "pos", "ner_index", "ner_type", "chunk_index", "chunk_type"),
              colClasses = c("character", "integer", "integer",  "character", "character", "factor", "integer", "factor", "integer", "factor"))

saveRDS(complete, "schoolgids2017v4_frogged.rds")

