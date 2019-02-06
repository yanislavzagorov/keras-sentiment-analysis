library(ff)
library(ffbase)
library(dplyr)
source("functions.R")


# ---------//  ~~Initial Setup~~  //---------
source("configuration.R")
#path <- "C:/Users/yanis/Documents/Rscripts/IndividualAssignment2"
path <- getwd()
setwd(path)
print(paste("Working directory set to:", getwd()))
tempdir <- paste0(getwd(),"/ffdf",sep="")
options(fftempdir = tempdir)
print(paste("FF working directory set to:", tempdir))
ffdf_hotelreviews_unstructured <- read.csv.ffdf(file="data/Hotel_Reviews_50k.csv")

ffdf_hotelreviews_structured_pos <- subset.ffdf(ffdf_hotelreviews_unstructured, 
                                                select = c(Hotel_Address, 
                                                           Hotel_Name, 
                                                           lat,
                                                           lng,
                                                           Average_Score,
                                                           Total_Number_of_Reviews,
                                                           Reviewer_Nationality,
                                                           Review_Date,
                                                           Positive_Review,
                                                           Review_Total_Positive_Word_Counts,
                                                           Total_Number_of_Reviews_Reviewer_Has_Given,
                                                           Reviewer_Score,
                                                           Tags
                                                ))
ffdf_hotelreviews_structured_pos$Sentiment <- as.ff(
  rep(factor("1"), times = nrow(ffdf_hotelreviews_structured_pos))
)

ffdf_hotelreviews_structured_neg <- subset.ffdf(ffdf_hotelreviews_unstructured, 
                                                select = c(Hotel_Address, 
                                                           Hotel_Name, 
                                                           lat,
                                                           lng,
                                                           Average_Score,
                                                           Total_Number_of_Reviews,
                                                           Reviewer_Nationality,
                                                           Review_Date,
                                                           Negative_Review,
                                                           Review_Total_Negative_Word_Counts,
                                                           Total_Number_of_Reviews_Reviewer_Has_Given,
                                                           Reviewer_Score,
                                                           Tags
                                                ))
ffdf_hotelreviews_structured_neg$Sentiment <- as.ff(
  rep(factor("0"), times = nrow(ffdf_hotelreviews_structured_neg))
)


# ---------//  ~~Cleaning Data~~  //---------
df_hotelreviews_structured_pos <- subset(as.data.frame(ffdf_hotelreviews_structured_pos, stringsAsFactors = T))
names(df_hotelreviews_structured_pos)[names(df_hotelreviews_structured_pos) == 'Positive_Review'] <- 'Review'
names(df_hotelreviews_structured_pos)[names(df_hotelreviews_structured_pos) == 'Review_Total_Positive_Word_Counts'] <- 'Review_Word_Counts'
df_hotelreviews_structured_neg <- subset(as.data.frame(ffdf_hotelreviews_structured_neg, stringsAsFactors = T))
names(df_hotelreviews_structured_neg)[names(df_hotelreviews_structured_neg) == 'Negative_Review'] <- 'Review'
names(df_hotelreviews_structured_neg)[names(df_hotelreviews_structured_neg) == 'Review_Total_Negative_Word_Counts'] <- 'Review_Word_Counts'

df_hotelreviews_structured_pos$Review <- qdap_clean(df_hotelreviews_structured_pos$Review)
df_hotelreviews_structured_neg$Review <- qdap_clean(df_hotelreviews_structured_neg$Review)

df_hotelreviews_structured_pos <- filter(df_hotelreviews_structured_pos, df_hotelreviews_structured_pos$Review != " n a")
df_hotelreviews_structured_pos <- filter(df_hotelreviews_structured_pos, df_hotelreviews_structured_pos$Review != "n a")  
df_hotelreviews_structured_pos <- filter(df_hotelreviews_structured_pos, df_hotelreviews_structured_pos$Review != "no") 
df_hotelreviews_structured_pos <- filter(df_hotelreviews_structured_pos, df_hotelreviews_structured_pos$Review != " ")  
df_hotelreviews_structured_pos <- filter(df_hotelreviews_structured_pos, df_hotelreviews_structured_pos$Review != "")  
df_hotelreviews_structured_neg <- filter(df_hotelreviews_structured_neg, df_hotelreviews_structured_neg$Review != " n a")
df_hotelreviews_structured_neg <- filter(df_hotelreviews_structured_neg, df_hotelreviews_structured_neg$Review != "n a")
df_hotelreviews_structured_neg <- filter(df_hotelreviews_structured_neg, df_hotelreviews_structured_neg$Review != "no") 
df_hotelreviews_structured_neg <- filter(df_hotelreviews_structured_neg, df_hotelreviews_structured_neg$Review != " ") 
df_hotelreviews_structured_neg <- filter(df_hotelreviews_structured_neg, df_hotelreviews_structured_neg$Review != "") 

df_hotelreviews_structured_all <- rbind(df_hotelreviews_structured_pos, df_hotelreviews_structured_neg)

ff_all <- as.ffdf(df_hotelreviews_structured_all)


# ---------//  ~~Writing FFDF as CSV~~  //---------
path_review_pos <- paste(tempdir, "/Review_pos.csv", sep="")
path_review_neg <- paste(tempdir, "/Review_neg.csv", sep="")
write.csv.ffdf(subset(ff_all, Sentiment == 1), file = path_review_pos)
write.csv.ffdf(subset(ff_all, Sentiment == 0), file = path_review_neg)

print("Confirming Reviews_pos.csv:")
tbl_df(read.csv(path_review_pos))
print("Confirming Reviews_neg.csv:")
tbl_df(read.csv(path_review_neg))