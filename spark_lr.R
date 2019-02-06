library(sparklyr)
library(dplyr)
library(tidyr)
library(titanic)
library(ggplot2)
library(purrr)
library(mongolite)


# ---------//  ~~Data Collection~~  //---------
M_COLLECTION_1 = "hotelreviews_collection"
M_COLLECTION_2 = "hotelreviews_collection_balanced"
M_DB = "hotelreviews_db"
M_URL = "mongodb://localhost"
M_CONNECTION <- mongo(collection=`M_COLLECTION_2`, db=`M_DB`, url=`M_URL`)
reviews <- M_CONNECTION$find('{}')
reviews$Sentiment <- as.integer(reviews$Sentiment)


# ---------//  ~~Spark Connection~~  //---------
sc <- spark_connect(master = "local", version = "2.2.0")
reviews_spark <- sdf_copy_to(sc, reviews, name="reviews_spark", overwrite=TRUE)


# ---------//  ~~Building Models~~  //---------
logr_pipeline <- ml_pipeline(
  ft_tokenizer(sc, input_col = "Review", output_col = "word_list"),
  ft_stop_words_remover(sc, input_col = "word_list", output_col = "wo_stop_words"),
  ft_count_vectorizer(sc, input_col = "wo_stop_words", output_col = "vectorizer_output"),
  ml_logistic_regression(sc, label_col = "Sentiment", features_col = "vectorizer_output")
)


# ---------//  ~~Fitting & Predictions~~  //---------
partitions <- sdf_partition(reviews_spark, training=0.7, test=0.3, seed=123)
logr_model <- ml_fit(logr_pipeline, partitions$training)
logr_pred <- ml_transform(logr_model, partitions$test)

logr_pred %>%
  group_by(Sentiment,Prediction) %>%
  tally()


# ---------//  ~~Data Prediction~~  //---------
new_review <- "Horrible review, hated it!"
predict_unseen_text(new_review)

