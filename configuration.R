###############################################################################
## The following script installs all libraries inside of 'InstallCandidates', #
## as well as the 'tensorflow', 'reticulate' and 'keras'-libraries if these   #
## are not already installed on the machine. This operation will take some    #
## time, and cancelling before everything is finished installing is not       #
## recommended. Operation should take 10-20 minutes on most hardware.         #
###############################################################################


# ---------//  ~~Collection of necessary libraries~~  //---------
InstallCandidates <- c(
  "mongolite",
  "ff",
  "ffbase",
  "dplyr",
  "tensorflow",
  "yaml",
  "Rcpp",
  "devtools",
  "corrplot",
  "keras",
  "reticulate",
  "data.table",
  "sparklyr",
  "tidyr",
  "ggplot2",
  "purrr"
)


# ---------//  ~~Checking pre-existing and installing missing candidates~~  //---------
toInstall <- InstallCandidates[!InstallCandidates %in% library()$results[, 1]]
if (length(toInstall) != 0) {
  install.packages(toInstall, repos = "http://cran.r-project.org")
}

lapply(InstallCandidates, library, character.only = TRUE)
rm("InstallCandidates", "toInstall")

source("functions.R")


# ---------//  ~~Installers for ~~  //---------
if(!'tensorflow' %in% library()$results[, 1]){
  devtools::install_github("rstudio/reticulate")
  install_tensorflow(method = "auto")
}
if(!'reticulate' %in% library()$results[, 1]){
  devtools::install_github("rstudio/reticulate")
}
if(!'keras' %in% library()$results[, 1]){
  devtools::install_github("rstudio/keras")
}