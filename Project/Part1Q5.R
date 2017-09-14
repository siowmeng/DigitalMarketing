# See the percentage of missing value in each feature
sapply(subset,function(x) sum(is.na(x))/dim(subset)[1])

# logistic regression
model = glm(booking_bool ~ prop_starrating + prop_review_score +
              prop_brand_bool + position + price_usd + promotion_flag +
              prop_location_score1, family = binomial(link = "logit"),data = subset)
summary(model)
require(MASS)
exp(cbind(coef(model), confint(model)))

model2 = glm(booking_bool ~ prop_starrating + prop_review_score +
               prop_brand_bool + position + price_usd + promotion_flag +
               prop_location_score1+ srch_adults_count + srch_room_count 
              + srch_children_count, family = binomial(link = "logit"),data = subset)
summary(model2)
exp(cbind(coef(model2)))

model3 = glm(booking_bool ~ prop_starrating + prop_review_score +
               prop_brand_bool + position + price_usd + promotion_flag +
               prop_location_score1 + srch_adults_count + srch_room_count 
               + srch_room_count*price_usd + srch_adults_count*price_usd, 
               family = binomial(link = "logit"),data = subset)

summary(model3)
exp(cbind(coef(model3)))
