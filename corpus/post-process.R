

# Post-process extract text.
# We want to remove stray text that will interfere with the natural flow
# of paragraphs and inhibit natural language processing.

inputs <- list.files("pdf", "\\.txt$")
for(input in inputs) {
  lines <- readLines(file.path("pdf", input), encoding = "UTF-8")

  # Remove leading and trailing spaces
  lines <- gsub(x = lines, pattern = "^\\s+", replacement = "")
  lines <- gsub(x = lines, pattern = "\\s+$", replacement = "")

  # Find repeated lines: these are headers and footers
  freqs <- table(lines)
  headers <- names(freqs[freqs > 10])

  # Find table of contents...
  toc_lines <- grepl(lines, pattern = "[.]{5,}")
  
  # Remove headers
  header_lines <-  (lines %in% headers)
  
  # remove page numbers
  page_numbers <- grepl(lines, pattern = "^pagina \\d", ignore.case = TRUE) |
    grepl(lines, pattern = "^\\d+$")
  
  # Exclude lines with low text content
  # This includes tables of contents with ".........34" and
  # tables that frog does not understand
  count_alpha <- nchar(gsub(lines, pattern = "[^[:alpha:]]", replacement = ""))
  count_chars <- nchar(lines, allowNA = TRUE)
  alpha_prop <- count_alpha / count_chars
  alpha_prop[is.na(alpha_prop)] <- 1

  blank_lines <- (lines == "")
  
  lines <- lines[ blank_lines | (!header_lines & !page_numbers & alpha_prop > 0.5) ]

  writeLines(lines, con = file.path("pdf", sprintf("%s.post", input)))
}
