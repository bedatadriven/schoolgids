

# Find installed packages
installed <- installed.packages()[,"Package"]

# Install packages from CRAN
cran_packages <- c("ggplot2", "rJava", "tm", "devtools", "httr", "NLP", "openNLP")
uninstalled <- cran_packages[!(cran_packages %in% installed)]

if(length(uninstalled) > 0) {
  install.packages(uninstalled, repos = "https://cloud.r-project.org")
}

# Install pdfbox from GitHub
if(!("pdfbox" %in% installed)) {
  devtools::install_github("hrbrmstr/pdfboxjars")
  devtools::install_github("hrbrmstr/pdfbox")
}

if(!("frogr" %in% installed)) {
  devtools::install_github("frogr", username="vanatteveldt")
}

# Install open NLP models
nlp_models <- c("openNLPmodels.nl", "openNLPmodels.en")
if(any(!(nlp_models %in% installed))) {
  install.packages(nlp_models, repos = "http://datacube.wu.ac.at/", type = "source") 
}

