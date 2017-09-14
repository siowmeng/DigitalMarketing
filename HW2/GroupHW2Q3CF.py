# -*- coding: utf-8 -*-
"""
Created on Mon May 22 10:16:10 2017

@author: siowmeng
"""

import pandas as pd
import numpy as np

import os
os.chdir('D:\\Imperial MSc\\Electives\\Digital Marketing Analytics\\Week 3')

ratings = pd.read_excel('movie_ratings_corrected.xlsx', skiprows = 2, skip_footer = 8, 
                        parse_cols = 'B:V', index_col = 0)

# Average rating of each item
itemAvg = np.nanmean(ratings.as_matrix(), axis = 0)
# Average rating given by each user
userAvg = np.nanmean(ratings.as_matrix(), axis = 1)
          
# User ratings, centered using user average
usrRatCent = ratings.as_matrix().copy() - userAvg[:, np.newaxis]
usrRatCent = np.nan_to_num(usrRatCent)

# 0-1 matrix indicates the presence of user ratings
hasRatingMatrix = usrRatCent.copy()
hasRatingMatrix[hasRatingMatrix != 0] = 1

## Pearson Correlation (average calculated using intersected values)
#distDF = ratings.transpose().corr()
#distMatrix = distDF.as_matrix().copy()
#np.fill_diagonal(distMatrix, 0) # Set diagonal to zero
#distMatrix = np.nan_to_num(distMatrix) # Set NaN value to zero
#distMatrix[abs(distMatrix) < 0.25] = 0
#absWeightMatrix = np.dot(abs(distMatrix), hasRatingMatrix)

# Pearson Correlation (average calculated using the whole user average)
distMatrix = np.dot(usrRatCent, usrRatCent.transpose()) / (np.sqrt(np.dot(usrRatCent**2, hasRatingMatrix.transpose())) * np.sqrt(np.dot(hasRatingMatrix, usrRatCent.transpose()**2)))
np.fill_diagonal(distMatrix, 0) # Set diagonal to zero
#distMatrix[abs(distMatrix) < 0.25] = 0
absWeightMatrix = np.dot(abs(distMatrix), hasRatingMatrix)

#myDistMatrix = np.zeros((20, 20))
#for a in range(20):
#    for u in range(20):
#        numerator = np.dot(usrRatCent[a, :], usrRatCent[u, :])
#        denominator = np.sqrt(np.dot((usrRatCent[a, :])**2, hasRatingMatrix[u, :])) * np.sqrt(np.dot((usrRatCent[u, :])**2, hasRatingMatrix[a, :]))
#        myDistMatrix[a, u] = numerator / denominator

# Final prediction
predictionMatrix = userAvg[:, np.newaxis] + np.dot(distMatrix, usrRatCent) / absWeightMatrix

# Sum of Squared Errors (using Pearson correlation with whole user average)
print("SSE of Corrected Pearson:", np.nansum((predictionMatrix - ratings.as_matrix())**2))

k = 6        
predictionMatrix = np.zeros((20, 20))
for a in range(20):
    for i in range(20):
        # User similarity
        similarity = distMatrix[a, :] * hasRatingMatrix[:, i]
        similarity[abs(similarity).argsort()[:(20 - k)]] = 0
        predictionMatrix[a, i] = userAvg[a] + np.dot(similarity, usrRatCent[:, i]) / np.sum(abs(similarity))

# Sum of Squared Errors (using six highest absolute similarity scores)
print("SSE of Corrected Pearson with 6 nearest neighbours (absolute similarity):", np.nansum((predictionMatrix - ratings.as_matrix())**2))

distMatrix = np.dot(usrRatCent, usrRatCent.transpose()) / (np.sqrt(np.dot(usrRatCent**2, hasRatingMatrix.transpose())) * np.sqrt(np.dot(hasRatingMatrix, usrRatCent.transpose()**2)))
np.fill_diagonal(distMatrix, 0) # Set diagonal to zero
distMatrix[abs(distMatrix) < 0.25] = 0
absWeightMatrix = np.dot(abs(distMatrix), hasRatingMatrix)

# Final prediction
predictionMatrix = userAvg[:, np.newaxis] + np.dot(distMatrix, usrRatCent) / absWeightMatrix

# Sum of Squared Errors (using threshold < 0.25)
print("SSE of Corrected Pearson with absolute similarity >= 0.25:", np.nansum((predictionMatrix - ratings.as_matrix())**2))
