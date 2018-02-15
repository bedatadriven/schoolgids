Extracting parental contribution information
================

Ouderbijdrag:

``` r
bijdrag <- lapply(1:20, function(i) {
  url <- as.character(school_urls[i, "url"])
  if(!is.na(url)) {
    text <- tryCatch(pdf_text(url), error = function(e) "")
    text <- paste(str_replace_all(text, "\\s+", " "), collapse=" ")
  
    unlist(str_match_all(text, "[A-Z][^.]+€\\s*\\d+[^.]+\\."))
  } else {
    NA
  }
})
```
