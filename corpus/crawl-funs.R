
library(httr)
library(xml2)


find_schoolgids <- function(school_url, debug = FALSE) {

  root_domain <- NA
  visited <- character(0)
  to_visit <- school_url
  depth <- 0
  
  schoolgids_links <- data.frame(page_title = character(0), 
                     page_url = character(0),
                     text = character(0), 
                     url = character(0), 
                     stringsAsFactors = FALSE)
    
  while(depth <= 6 && length(to_visit) > 0) {
  
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
      
        # Identify any links that *could* be schools gids pdfs  
        school_gids <- is_school_gids(page_links)
        
        # Add to our list
        schoolgids_links <- rbind(schoolgids_links, page_links[school_gids, ])
        
        # impose a reasonable limit of pages to search for each school
        if(length(visited) > 500) {
          break;
        }
        
        # Otherwise identify the next round of pages to crawl
        non_html_links <- grepl(page_links$url, pattern = "\\.(pdf|jpg|jpeg|png|docx|doc)$", ignore.case = TRUE)
        
        html_urls <- unique(page_links$url[!non_html_links & !is.na(page_links$url)])
        already_seen <- html_urls %in% visited
        domain <- vapply(html_urls, FUN.VALUE = character(1), FUN = url_domain)
      
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
  
  schoolgids_links
}

url_domain <- function(url) {
  hostname <- parse_url(url)$hostname
  if(is.character(hostname)) {
    hostname
  } else {
    ""
  }
}

is_school_gids <- function(links) {
  
  is_doc <- sapply(links$url, function(url) {
    parsed <- parse_url(url)
    grepl(parsed$path, pattern = "\\.(pdf|doc|docx)$")
  })
  
  match <- grepl(links$text, pattern = "gids", ignore.case = TRUE) | 
           grepl(links$url, pattern = "gids|schoolg", ignore.case = TRUE) |
           grepl(links$url, pattern = "2017-2018")
  
  is_doc & match
}

#' Verify that PDF/document URLs actually exist on the server
is_valid_link <- function(pdf_links) {
  sapply(pdf_links$url, function(url) {
    # Only perform the check if the url is point to a document
    if(!grepl(url, pattern = "\\.(pdf|doc|docx)$")) {
      return(TRUE)
    }
    cat(sprintf("Checking %s...\n", url))
    response <- GET(url)
    response$status_code == 200
  })
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

modify_url_or_na <- function(...) {
  tryCatch(modify_url(...), error = function(e) NA_character_)
}

normalize_link <- function(base_url, link) {
  
  stopifnot(inherits(base_url, "url"))
  stopifnot(is.character(link) && length(link) == 1)
  
  
  # is the url on the same page?
  if(grepl(link, pattern = "^#")) {
    return(modify_url_or_na(base_url))
  }
  
  # Parse the link
  link_url <- parse_url(link)
  
  # the query string of the base url is never used
  base_url$query <- NULL
  
  # is the link simply a query string?
  if(!is.null(link_url$query) && !nzchar(link_url$path)) {
    return(modify_url_or_na(base_url, query = link_url$query))
  }
  
  # is the link actually an absolute URL?
  if(!is.null(link_url$scheme) || !is.null(link_url$hostname)) {
    return(modify_url_or_na(link_url, fragment = NULL))
  }

  # is the url an absolute path?
  if(grepl(link_url$path, pattern = "^/")) {
    return(modify_url_or_na(url = base_url, path = link_url$path, query = link_url$query, fragment = NULL))
  }
  
  # Otherwise need to combine paths
  base_parts <- strsplit(base_url$path, split = "/", fixed = TRUE)[[1]]
  link_parts <- strsplit(link_url$path, split = "/", fixed = TRUE)[[1]]
  
  # Strip the filename if the path is not a "directory"
  # For example "/foo/index.html"
  if(length(base_parts) > 0 && !grepl(base_url$path, pattern = "/$")) {
    length(base_parts) <- length(base_parts) - 1
  }
  
  modify_url_or_na(base_url, path = paste(c(base_parts, link_parts), collapse="/"), query = link_url$query)
}
