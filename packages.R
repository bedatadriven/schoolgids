

# Find installed packages
installed <- installed.packages()[,"Package"]

# Install packages from CRAN
cran_packages <- c("ggplot2", "rJava", "tm", "devtools", "httr")
uninstalled <- cran_packages[!(cran_packages %in% installed)]

install.packages(uninstalled, repos = "https://cloud.r-project.org")

# Install pdfbox from GitHub
if("pdfbox" %in% installed) {
  devtools::install_github("hrbrmstr/pdfboxjars")
  devtools::install_github("hrbrmstr/pdfbox")
}
