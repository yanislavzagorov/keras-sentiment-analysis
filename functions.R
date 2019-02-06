library(ff)
library(ffbase)
library(dplyr)
library(qdap)
library(tm)
source("functions.R")


# ---------//  ~~Compares runtime of ffdf and regular df~~  //---------
speed_tester <- function() {
  ffdf_hotelreviews_unstructured <- read.csv.ffdf(file="C:/Users/yanis/Documents/Rscripts/IndividualAssignment2/data/Hotel_Reviews.csv")
  df_hotelreviews_unstructured <- read.csv.ffdf(file="C:/Users/yanis/Documents/Rscripts/IndividualAssignment2/data/Hotel_Reviews_50k.csv")
  
  system.time(ffdf_hotelreviews_unstructured[,2] + ffdf_hotelreviews_unstructured[,2] * ffdf_hotelreviews_unstructured[,2])
  system.time(df_hotelreviews_unstructured[,2] + df_hotelreviews_unstructured[,2] * df_hotelreviews_unstructured[,2] )
  return(speedTest)
}

# ---------//  ~~Takes a row of pure text and returns cleaned text~~  //---------
qdap_clean <- function(x) {
  x <- gsub("booking com", "", x)
  x <- replace_abbreviation(x)
  x <- replace_contraction(x)
  x <- replace_number(x)
  x <- replace_ordinal(x)
  x <- replace_symbol(x)
  x <- tolower(x)
  
  x <- gsub("didn t", "did not", x)
  x <- gsub("don t", "do not", x)
  x <- gsub("can t", "can not", x)
  x <- gsub("shouldn t", "should not", x)
  x <- gsub("wouldn t", "would not", x)
  x <- gsub("couldn t", "could not", x)
  x <- gsub("wasn t", "was not", x)
  x <- gsub("won t", "will not", x)
  x <- gsub("weren t", "were not", x)
  return(as.factor(x))
}


# ---------//  ~~Cleans a Corpus~~  //---------
tm_clean <- function(corpus) {
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeWords,
                   c(stopwords("en"), "hotel", "also", "Amsterdam"))
  corpus <- tm_map(corpus, stripWhitespace)
  #corpus <- tm_map(corpus, PlainTextDocument)
  corpus <- tm_map(corpus, stemDocument)
  return(corpus)
}


# ---------//  ~~Cleans a single text review and returns corpus~~  //---------
clean_text_review <- function(dirty_review) {
  review_qdapcleaned <- qdap_clean(dirty_review)
  
  corpus <- VCorpus(VectorSource(review_qdapcleaned))
  
  corpus <- tm_clean(corpus)
  
  review_cleaned <- tm_clean(corpus)
  
  return(review_cleaned[[1]]$content)
}


# ---------//  ~~Tokenizes following NGram~~  //---------
tokenizer <- function(x) {
  NGramTokenizer(x, Weka_control(min = 2, max = 2))
}