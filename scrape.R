
library(httr)
library(xml2)


find_schoolgids <- function(school_url, debug = FALSE) {

  root_domain <- NA
  visited <- character(0)
  to_visit <- school_url
  depth <- 0
  
  pdfs <- data.frame(page_title = character(0), 
                     page_url = character(0),
                     text = character(0), 
                     url = character(0), 
                     stringsAsFactors = FALSE)
    
  while(depth <= 3 && length(to_visit) > 0) {
  
    cat(sprintf("...Fetching %d pages at depth %d...\n", length(to_visit), depth))
    
    visiting <- unique(to_visit)
    visited <- c(visited, visiting)
    to_visit <- character(0)
    for(url in visiting) {
      response <- tryCatch(GET(url), error = function(e) NULL)
      if(!is.null(response)) {
        
        page_links <- find_links(response)
        
        # The first page we visit we consider to be the "root domain"
        # as long as it not just a page with a single <Meta refresh tag> or 
        # frame
        if(is.na(root_domain) && nrow(page_links) > 1) {
          root_domain <- parse_url(response$url)$hostname
        }
        
        # Also mark the effective url as visited
        visited <- c(visited, response$url)
        
        pdf_links <- grepl(page_links$url, pattern = "\\.pdf$", ignore.case = TRUE)
        school_gids <- pdf_links & is_school_gids(page_links)
        if(any(pdf_links)) {
          if(debug) {
            new_links <- page_links[pdf_links, ]
            new_links$page_url <- url
            pdfs <- rbind(pdfs, new_links)
          } else if(any(school_gids)) {
            page_links$page_url <- url
            return(page_links[school_gids, ])
          }
        }
        
        # Otherwise identify the next round of pages to crawl
        html_urls <- unique(page_links$url[!pdf_links & !is.na(page_links$url)])
        already_seen <- html_urls %in% visited
        domain <- vapply(html_urls, FUN.VALUE = character(1), FUN = function(url) parse_url(url)$hostname)
      
        in_domain <- if(is.na(root_domain)) {
          TRUE
        } else {
          domain == root_domain
        }
        
        to_visit <- c(to_visit, html_urls[!already_seen & in_domain])
      }
    }
    
    if(length(visiting) > 1) {
      depth <- depth + 1
    }
  }
  
  pdfs
}
is_school_gids <- function(links) {
  match <- grepl(links$text, pattern = "gids", ignore.case = TRUE) | 
           grepl(links$url, pattern = "gids|schoolg", ignore.case = TRUE)
  
  match
}

find_links <- function(response) {
  html <- tryCatch(read_html(response), error = function(e) NULL)
  if(is.null(html)) {
    return(data.frame(text = character(0), url = character(0), stringsAsFactors = FALSE))
  }
  base_url <- parse_url(response$url)
  title_nodeset <- xml_find_all(html, "//title")
  title <- if(length(title_nodeset) > 0) {
    xml_text(title_nodeset[1])
  } else {
    NA_character_
  }
  title <- gsub(title, pattern = "^\\s+", replacement = "")
  title <- gsub(title, pattern = "\\s+$", replacement = "")
  
  
  refresh <- xml_find_all(html, "//meta[@http-equiv='refresh']")
  refresh_links <- vapply(refresh, FUN.VALUE = character(1), parse_refresh_tag)
  refresh_text <- rep(NA_character_, length = length(refresh_links))
  
  frames <- xml_find_all(html, "//frame/@src|//iframe/@src")
  frame_links <- vapply(frames, FUN.VALUE = character(1), FUN = xml_text)
  frame_text <- rep(NA_character_, length = length(frame_links))
  
  anchors <- xml_find_all(html, "//a[@href]")
  anchor_links <- vapply(anchors, FUN.VALUE = character(1), FUN = xml_attr, "href")
  anchor_text <- vapply(anchors, FUN.VALUE = character(1), FUN = xml_text)
      
  urls <- vapply(c(refresh_links, frame_links, anchor_links), 
                 FUN.VALUE = character(1),
                 FUN = function(link) normalize_link(base_url, link))
  
  data.frame(page_title = rep.int(title, length(urls)),
             text = c(refresh_text, frame_text, anchor_text),
             url = as.character(urls),
             stringsAsFactors = FALSE)
  
}


parse_refresh_tag <- function(meta_element) {
  content <- strsplit(xml_attr(meta_element, 'content'), split = ";", fixed = TRUE)[[1]]
  url <- grep(content, pattern = "^URL=", value = TRUE)
  if(length(url) >= 1) {
    refresh_param <- url[1]
    refresh_url <- substring(refresh_param, 5)
    refresh_url
  } else {
    NA_character_
  }
}

normalize_link <- function(base_url, link) {
  
  stopifnot(inherits(base_url, "url"))
  stopifnot(is.character(link) && length(link) == 1)
  
  # Strip the fragment from the link
  link <- gsub(link, pattern = "#.+$", replacement = "")
  
  # is the link actually an absolute URL or path?
  if(grepl(link, pattern = "^https?://")) {
    return(link)
  }
  
  # If this another sort of link, like mailto: etc,
  # return NA
  if(grepl(link, pattern = "^[A-Za-z]+:")) {
    return(NA_character_)
  }

  # is the url on the same page?
  if(grepl(link, pattern = "^#")) {
    return(modify_url(base_url))
  }

  # is the url an absolute path?
  if(grepl(link, pattern = "^/")) {
    return(modify_url(url = base_url, path = link, fragment = NULL))
  }
  
  # Otherwise need to combine paths
  base_parts <- strsplit(base_url$path, split = "/", fixed = TRUE)[[1]]
  link_parts <- strsplit(link, split = "/", fixed = TRUE)[[1]]
  
  # Strip the filename if the path is not a "directory"
  # For example "/foo/index.html"
  if(length(base_parts) > 0 && !grepl(base_url$path, pattern = "/$")) {
    length(base_parts) <- length(base_parts) - 1
  }
  
  modify_url(base_url, path = paste(c(base_parts, link_parts), collapse="/"))
}
