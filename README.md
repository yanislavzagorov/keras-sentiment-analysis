# keras-sentiment-analysis
Simple natural language processing using Keras and Spark in R. Models are trained on 10,000 positive and 10,000 negative hotel reviews of hotels in Europe.

## Report
Report available at www.yanislavzagorov.com/keras-sentiment-analysis-report

## The data
The dataset '515K Hotel Reviews Data in Europe' is provided by Jason Liu and hosted on kaggle.com. The full dataset is available here: https://www.kaggle.com/jiashenliu/515k-hotel-reviews-data-in-europe
Currently, the data undergoes an unnecessary process of being put in and out of ffbase storage and into a local NOSQL mongo database after cleaning. This is solely done as a proof of concept and to play around with the libraries, and will be removed when I have the time.

## The model
Model is built using Keras in R. Pre-built models use both the Adagrad and RMSPropagation algorithms for gradient descent optimization.

## To build and run a Keras model
Currently, there needs to be a local mongodb database running in order to clean, save and use the data. The database needs to have the following collections inside of a database called 'hotelreviews_db'; hotelreviews_collection, hotelreviews_collection_50k and hotelreviews_collection_balanced. The datahandling.R and database.R scripts do all the cleaning and storage on their own.

1. **Run datahandling.R.** This script will run configuration.R, installing all missing, necessary libraries. database.R will also be sourced, saving the clean data to 'hotelreviews_collection_balanced'.
1. **Build the keras model by running the keras.R script.** This will build the model using Adagrad for gradient descent optimization without further changes to the code.
1. **Use the predict_unseen_text-function to make a prediction a new review.** The only argument for this function is a String which would be the new review. The function cleans, stems and tokenizes the new review before passing it to the model. 

Spark models are built the same way, but will be split into a seperate project to keep things tidy in the future. 
