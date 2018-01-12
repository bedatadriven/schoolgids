
library(Rcrawler)

schools <- read.ta

## First step:
# Data<-ContentScraper(Url = "http://www.amgschmidtschool.nl/schoolgids/Paginas/default.aspx", 
#                    XpathPatterns =c("//a[contains(@href,'.pdf')]/@href"))


findAllPdfLinks <- function(schoolUrl = "http://www.amgschmidtschool.nl") {

  Rcrawler(Website=schoolUrl, no_cores=4, 
                   ExtractXpathPat =c("//a[contains(@href,'.pdf')]/@href"),
                   ManyPerPattern = TRUE)
                            
  paste0(schoolUrl, unlist(DATA))
}

#' Given a list of PDF links 
findSchoolGidsPdf <- function(pdfLinks) {
  matching <- grep(pdfLinks, pattern = "gids", ignore.case = TRUE, value = TRUE)
  if(length(matching) == 0) {
    stop("No PDF matching schools gids")
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

