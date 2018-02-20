

## This script compiles the output of all the frogged documents into a single grand table.

library(stringr)

bioIndex <- function(x) {
  start <- (substring(x, 1, 1) == "B")
  index <- cumsum(start)
  index[substring(x, 1, 1) == "O"] <- NA
  index
}

bioType <- function(x) {
  c <- substring(x, 1, 1)
  ifelse(c=="O",NA_character_, str_match(x, "[BIO]-([A-Z]+)")[, 2]) 
}

outputs <- list.files("frog", pattern = "\\.out$", recursive = TRUE, full.names = TRUE)
results <- lapply(outputs, function(output) {
  
  table <- read.delim(output, stringsAsFactors = FALSE, col.names = c("position", "word", "lemma", "morph", 
                                                                      "pos", "prob", "ner", "chunk", "parse1", "parse2"))
  
  vn <- as.character(stringr::str_match(output, "[0-9][0-9][A-Z][A-Z][0-9][0-9]"))
  
  stopifnot(nchar(vn) == 6)
  
  table$pos <- gsub("\\(.*", "", table$pos)
  table$sent[table$position == 1] = 1:sum(table$position == 1)
  if (nrow(table) > 0 && is.na(table$sent[1])) 
    table$sent[1] = 1
  table$sent = na.locf(table$sent)
  table$chunk_index <- bioIndex(table$chunk)
  table$chunk_type <- bioType(table$chunk)
  table$ner_index <- bioIndex(table$ner)
  table$ner_type <- bioType(table$ner)
  
  result <- with(table, data.frame(school=rep(vn, length=nrow(table)), 
                                   sent=sent, 
                                   position=position, 
                                   word=word, 
                                   lemma=lemma, 
                                   pos=as.factor(pos), 
                                   ner=ner_index, ner_type=as.factor(ner_type), chunk=chunk_index, chunk_type=as.factor(chunk_type), stringsAsFactors = FALSE))

  result
})

tokens <- do.call(rbind, results)
