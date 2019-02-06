library(mongolite)
library(ff)
library(ffbase)
library(dplyr)
library(tensorflow)
library(yaml)
library(Rcpp)
library(devtools)
library(corrplot)
library(keras)
library(reticulate)
library(data.table)
source("functions.R")


# ---------//  ~~Functions~~  //---------
predict_unseen_text <- function(new_reviews) {
  tokenizer <- load_text_tokenizer("models/tokenizer.RData")
  kerasModel <- load_model_hdf5("models/keras_model_rms.RData")
  new_reviews_cleaned <- qdap_clean(new_reviews)
  new_data <- texts_to_sequences(tokenizer, new_reviews)
  # Padding of new dataset
  new_matrix <- matrix(0, nrow = length(new_data), ncol = 20000) 
  for (i in 1:length(new_data)) {
    new_matrix[i, new_data[[i]]] <- 1
  }
  prediction <- predict(kerasModel, new_matrix,
          batch_size = 1024, verbose = 0)
  return(prediction[1,])
}


# ---------//  ~~Data Collection~~  //---------
M_COLLECTION_1 = "hotelreviews_collection"
M_COLLECTION_2 = "hotelreviews_collection_balanced"
M_DB = "hotelreviews_db"
M_URL = "mongodb://localhost"
M_CONNECTION <- mongo(collection=`M_COLLECTION_2`, db=`M_DB`, url=`M_URL`)
reviews <- M_CONNECTION$find('{}')


# ---------//  ~~Data Preperation~~  //---------
tokenizer <- text_tokenizer(num_words = 10000)
tokenizer <- fit_text_tokenizer(tokenizer, reviews$Review)
save_text_tokenizer(tokenizer, file = "models/tokenizer.RData")

temp <- data.table(Review = reviews$Review,
                   Sentiment = reviews$Sentiment)

TRAIN_LENGTH <- nrow(temp)
train_data <- texts_to_sequences(tokenizer, temp[1:TRAIN_LENGTH]$Review)
train_labels <- temp[1:TRAIN_LENGTH]$Sentiment

matrix <- matrix(0, nrow = length(train_data), ncol = 20000) 
for (i in 1:length(train_data)) {
  matrix[i, train_data[[i]]] <- 1 
}

train_x <- matrix
train_y <- as.numeric(train_labels)
trainSet <- list(x = train_x, y = train_y)


# ---------//  ~~Model Building~~  //---------
model <- keras_model_sequential() %>%
  layer_dense(units = 16, activation = "relu", input_shape = c(20000)) %>% 
  layer_dense(units = 16, activation = "relu") %>% 
  layer_dense(units = 1, activation = "sigmoid")
model <- compile(model, 
                 optimizer = "RMSprop",
                 loss = "binary_crossentropy",
                 metrics = c("accuracy"))
x = trainSet$x
y = trainSet$y
kerasModel <- model 

history <- kerasModel %>% fit(
  x,
  y,
  epochs = 40,
  batch_size = 1024,
  validation_spit = 0.4
)
plot(history)

path_keras_model <- paste(path, "/models/keras_model_rms.RData", sep="")
save_model_hdf5(kerasModel, path_keras_model)


# ---------//  ~~Data Prediction~~  //---------
# Predicting a new review
#unseen_text <- c("Great Hotel, amazing experience and great staff!")
#unseen_text <- c("Horrible hotel, rooms had rats and the waiter spat in my wife's eye.")
#unseen_text <- c("We loved our stay at Hilton in Egypt. It was clean, the roomservice was great, the dining room was glamorous and the food was world-class as well. Only thing missing was proper ventilation in the rooms, but that is a small price to pay considering our overall experience.")
#predict_unseen_text(unseen_text)

