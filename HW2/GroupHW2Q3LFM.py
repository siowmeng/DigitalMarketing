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

mu = np.nanmean(ratings.as_matrix())
centRatings1 = ratings.as_matrix() - mu
bu = np.nanmean(centRatings1, axis = 1)
centRatings2 = centRatings1 - bu[:, np.newaxis]
bi = np.nanmean(centRatings2, axis = 0)
centRatings3 = centRatings2 - bi[np.newaxis, :]

def get_error(R, P, Q):
    return np.nansum((R - np.dot(P, Q))**2)

# Unrefined Latent Factor Model
#R = ratings.as_matrix()
# Refined Latent Factor Model
R = centRatings3.copy()
m, n = ratings.shape
n_iterations = 100
prediction = []
for n_factors in [3, 4, 5]:
    np.random.seed(123)
    P = 1 + 4 * np.random.rand(m, n_factors)
    Q = 1 + 4 * np.random.rand(n_factors, n)
    # Use Alternating Least Squares for Latent Factor estimation
    errors = []
    for ii in range(n_iterations):
        P = np.linalg.solve(np.dot(Q, Q.T), np.dot(Q, np.nan_to_num(R.T))).T
        Q = np.linalg.solve(np.dot(P.T, P), np.dot(P.T, np.nan_to_num(R)))
        errors.append(get_error(R, P, Q))
    Q_hat = np.dot(P, Q)
    print("SSE of rated movies (no of latent factors = %d): %.2f" % (n_factors, get_error(R, P, Q)))
    
    # Prediction for unrefined LFM model
    #prediction.append(np.dot(P, Q))
    
    # Prediction for refined LFM model
    prediction.append(np.dot(P, Q) + bi[np.newaxis, :] + bu[:, np.newaxis] + mu)

