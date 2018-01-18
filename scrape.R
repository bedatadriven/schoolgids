
library(Rcrawler)
library(RCurl)
library(XML)

normalizeUrl <- function(url, relativeUrl) {
  
  # is the relative url actually an absolute URL?
  if(grepl(relativeUrl, pattern = "^https?://")) {
    return(relativeUrl)
  }
  
  # find the seperate the schema+host from the 
  # path of the base url
  baseMatch <- regexec(url, pattern = "(https?://[^/]+)/(.+)")
  baseGroups <- regmatches(url, baseMatch)[[1]]
  baseHost <- baseGroups[2]
  basePath <- baseGroups[3]
  
  # is this an absolute url?
  if(grepl(relativeUrl, pattern = "^/")) {
    return(paste0(baseHost, relativeUrl))
  }
  
  if(!grepl(url, pattern = "/$")) {
    url <- paste0(url, "/")
  }
  paste0(url, relativeUrl)
}

#' Parses an HTML document to see if it includes a <META http-equiv="refresh"> tag
#' that many of these schools use as a poor man's redirect.
#' 
findMetaRefreshUrl <- function(doc) {
  html <- XML::htmlParse(doc, asText = TRUE, isHTML = TRUE)
  nodeSet <- xpathApply(html, "//meta[@http-equiv='refresh']/@content")
  
  if(length(nodeSet) >= 1) {
    content <- strsplit(nodeSet[[1]], split = ";", fixed = TRUE)[[1]]
    urlIndex <- grep(content, pattern="^URL=")
    if(length(urlIndex) >= 1) {
      refreshParam <- content[urlIndex[1]]
      refreshUrl <- substring(refreshParam, 5)
      return(refreshUrl)
    }
  }
  NA_character_
}

#' Finds the correct URL of a school's web page,
#' after redirects.
#' 
findRootUrl <- function(url) {
  
  # In the schoolen list from DUO, the URL scheme is not 
  # included
  if(!grepl(url, pattern="^https?://")) {
    url <- paste0("http://", url)
  }
  
  # Check for redirects.
  # If the school's URL redirects to another domain, we need
  # to feed *that* domain to the scraper.
  repeat {
    h <- basicHeaderGatherer()
    doc <- getURI(url, headerfunction = h$update)
    headers <- h$value()
    switch(headers["status"], 
           "200" = {
             # Check for <meta referesh> which Rcrawler doesn't support
             refreshUrl <- findMetaRefreshUrl(doc)
             if(!is.na(refreshUrl)) {
               url <- normalizeUrl(url, refreshUrl)
             } else {
               break
             }
           },
           "301" = {
             url <- headers["Location"]
           },
           "404" = {
             return(NA_character_)
           },
           {
             break;
           }
    )
  }
  return(as.character(url))
}

normalizeLinks <- function(links) {
  baseUrl <- as.character(links)
  links <- names(links)
  
  sapply(seq_along(links), function(i) normalizeUrl(baseUrl[i], links[i]))
}

#' Given a school's URL, crawl the site for all links to pdf files.
#' 
findAllPdfLinks <- function(url) {

  # Define an XPath pattern that matches the URL of all hyperlinks to PDFs
  pattern <-  "//a[contains(@href,'.pdf') or contains(@href, '.PDF')]/@href"

  # Temporary directory where Rcrawler will dump files. We want to 
  dir <- tempdir()
  # clean up when the function is done.
  on.exit(unlink(dir))
  
  Rcrawler(Website=url, no_cores=4, 
                   DIR = dir,
                   ExtractXpathPat = pattern,
                   MaxDepth = 3,  # Saves some time and 
                   ManyPerPattern = TRUE)
                            
  # RCrawler annoying saves results in the global environment
  
  if(exists("DATA", envir = .GlobalEnv)) {
    results <- normalizeLinks(unlist(DATA))
    rm("DATA", envir = .GlobalEnv)
    return(results)
    
  } else {
    character(0)
  }
}

#' Given a list of PDF links, find the link to the latest schoolgids
#' 
findSchoolGidsPdf <- function(pdfLinks) {
  stopifnot(is.character(pdfLinks))
  
  matching <- grep(pdfLinks, pattern = "gids", ignore.case = TRUE, value = TRUE)
  if(length(matching) == 0) {
    NA_character_
    warning("No PDF matching schools gids")
  }
  if(length(matching) > 1) {
    warning("More than one PDF found matching school gids pattern")
  }
  matching[1]
}

downloadPdf <- function(url) {
  pdfFile <- "annie.pdf"
  download.file(url, pdfFile)
  pdfFile
}

findAllUrls <- function() {
  schools <- read.table("schools.csv", 
                        sep=";", 
                        quote="", 
                        fill = TRUE, 
                        header = TRUE, 
                        stringsAsFactors = FALSE)
  
  for(i in 1:nrow(schools)) {
    adres <- schools[i, "INTERNETADRES"]
    rootUrl <- findRootUrl(adres)
    
    if(is.na(schools[i, "GIDSADRES"])) {
      schools[i, "GIDSADRES"] <- findSchoolGidsPdf(findAllPdfLinks(rootUrl))
    }
  }
  schools
}
  
