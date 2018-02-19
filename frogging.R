

library(pdfbox)

pages <- extract_text("pdf/10GR00.pdf")
pages <- strsplit(pages$text, split ="\\r?\\n")
pages <- lapply(pages, function(lines) {
    
  # Remove leading and trailing spaces
  lines <- gsub(x = lines, pattern = "^\\s+", replacement = "")
  lines <- gsub(x = lines, pattern = "\\s+$", replacement = "")
  lines
})

# Find repeated lines: these are headers and footers
freqs <- table(unlist(pages))
num_pages <- length(pages)
headers <- names(freqs[freqs > (num_pages / 3)])
headers <- headers[nzchar(headers)]

# Remove headers and footers
pages <- lapply(pages, function(lines) {
  
  # Remove headers
  header_lines <-  (lines %in% headers)
  
  # remove page numbers
  page_numbers <- grepl(lines, pattern = "^pagina \\d", ignore.case = TRUE) |
                  grepl(lines, pattern = "^\\d+$")
  
  lines[ !header_lines & !page_numbers ]
})

writeLines(unlist(pages), con = "pdf/10GR00.txt.pre")

frogged <- read.table("10GR00.txt.frogged", sep = "\t", fill = TRUE, stringsAsFactors = FALSE, quote = "", 
                        col.names = c("token_num", "token", "lemma", "morphemes", "pos_complete", "prob", "entity", "chunk", "head_word", "dependency"))

frogged$pos <- str_match(frogged$pos_complete, "([A-Z]+)\\((.+)\\)")[, 2]
frogged$chunk_index <- cumsum(ifelse(grepl(frogged$chunk, pattern = "^I"), 0, 1))
frogged$chunk_type <- str_match(frogged$chunk, "[BI]-([A-Z]+)")[, 2]
