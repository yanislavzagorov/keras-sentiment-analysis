library(mongolite)


# ---------//  ~~Configuration~~  //---------
M_COLLECTION_1 = "hotelreviews_collection"
M_COLLECTION_12 = "hotelreviews_collection_50k"
M_COLLECTION_2 = "hotelreviews_collection_balanced"
M_DB = "hotelreviews_db"
M_URL = "mongodb://localhost"


# ---------//  ~~Full Collection (1m rows)~~  //---------
##TODO commented out just to save time. Saves 1m rows to HotelReviews collection
M_CONNECTION <- mongo(collection=`M_COLLECTION_1`, db=`M_DB`, url=`M_URL`)
# M_CONNECTION$drop()
# M_CONNECTION$insert(df_hotelreviews_structured_all)

M_CONNECTION <- mongo(collection=`M_COLLECTION_12`, db=`M_DB`, url=`M_URL`)
M_CONNECTION$insert(df_hotelreviews_structured_all)


# ---------//  ~~Balanced Collection~~  //---------
M_DF_BALANCED_POS <- M_CONNECTION$find('{ "Sentiment" : "1" }', '{ "Review": 1, "Sentiment": 1}', sort = '{"Average_Score": -1}', limit = 10000)
M_DF_BALANCED_NEG <- M_CONNECTION$find('{ "Sentiment" : "0" }', '{ "Review": 1, "Sentiment": 1}', sort = '{"Average_Score": -1}', limit = 10000)
M_DF_BALANCED_ALL <- rbind(M_DF_BALANCED_POS, M_DF_BALANCED_NEG)
M_DF_BALANCED_ALL <- M_DF_BALANCED_ALL[sample(nrow(M_DF_BALANCED_ALL), nrow(M_DF_BALANCED_ALL)), ]

M_CONNECTION <- mongo(collection=`M_COLLECTION_2`, db=`M_DB`, url=`M_URL`)
M_CONNECTION$drop()
M_CONNECTION$insert(M_DF_BALANCED_ALL)


# ---------//  ~~Example Queries~~  //---------
## SELECT * 
M_QUERY_ALL <- M_CONNECTION$find('{}')
## WHERE Hotel_Name == "Hotel Arena" 
M_QUERY_ALL_HOTELARENA <- M_CONNECTION$find('{"Hotel_Name":{"$eq":"Hotel Arena"}}')
## Grouping by hotels and counting appearances
M_QUERY_COUNTED <- M_CONNECTION$aggregate('[{"$group":{"_id":"$Hotel_Name", "count": {"$sum":1}, "average":{"$avg":"$distance"}}}]',
                                          options = '{"allowDiskUse":true}'
)
## Below query don't need or have any positive effect of using MapReduce, just demonstrating MR works as intended.
M_QUERY_MAPREDUCE <- M_CONNECTION$mapreduce(
  map = "function(){emit(this.Review, 1), emit(this.Sentiment, 1)}",
  reduce = "function(id, counts){return Array.sum(counts)}"
)