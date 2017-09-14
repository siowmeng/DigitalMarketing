library(dplyr)

search_data <- read.csv ("train.csv", 
                         stringsAsFactors = FALSE, dec = c(".",","))

#check data types
sapply(search_data, class)

search_data$orig_destination_distance <- as.numeric(search_data$orig_destination_distance)

#add price/quality column
search_data["price_quality_ratio"] <- search_data["price_usd"] / search_data["prop_starrating"]

search_data_grouped <- search_data %>%
  group_by(srch_id) %>%
  summarise(number=n(),
            geo_diverse=sd(orig_destination_distance, na.rm=TRUE),
            price_diverse=sd(price_usd, na.rm=TRUE),
            quality_diverse=sd(prop_starrating, na.rm=TRUE),
            price_quality_diverse=sd(price_quality_ratio, na.rm=TRUE),
            no_click=sum(click_bool, na.rm=TRUE),
            booked_bool=sum(booking_bool, na.rm=TRUE),
            visitor_location_id=mean(visitor_location_country_id, na.rm=TRUE),
            prop_country_id=mean(prop_country_id, na.rm=TRUE),
            length_of_stay=mean(srch_length_of_stay, na.rm=TRUE),
            booking_window=mean(srch_booking_window, na.rm=TRUE),
            search_adult_count=mean(srch_adults_count, na.rm=TRUE),
            search_child_count=mean(srch_children_count, na.rm=TRUE),
            room_count=mean(srch_room_count, na.rm=TRUE),
            saturday_bool=mean(srch_saturday_night_bool, na.rm=TRUE))

#remove inf values
search_data_clean <- do.call(data.frame,lapply(search_data, function(x) replace(x, is.infinite(x),NA)))
data_clean <-search_data_grouped[is.finite(rowSums(search_data_grouped)), ] 

#descriptive statistics of grouped level data
mean(search_data_grouped$geo_diverse, na.rm = TRUE)
mean(search_data_grouped$price_diverse)
mean(search_data_grouped$quality_diverse)
mean(data_clean$price_quality_diverse)

sd(search_data_grouped$geo_diverse, na.rm = TRUE)
sd(search_data_grouped$price_diverse)
sd(search_data_grouped$quality_diverse)
sd(data_clean$price_quality_diverse)


#histogram showing distribution of bookings at each diversity level (geogrpahic and qaulity)
data_booked <- search_data_grouped[search_data_grouped["booked_bool"] == 1,]

hist(data_booked$geo_diverse, , breaks = seq(0, 110, by = 0.1))
hist(data_booked$quality_diverse, breaks = seq(0, 3, by = 0.05))

#logit models with whether or not booked as dependent variable 
#model with price/quality ratio
logit_model_price_quality_ratio <- glm(booked_bool ~ geo_diverse +price_quality_diverse + 
                    visitor_location_id + prop_country_id +length_of_stay + booking_window +
                    search_adult_count + search_child_count + room_count + saturday_bool,
                   family = "binomial"(link = "logit"), data_clean)
summary(logit_model_price_quality_ratio)

#model with price and quality separate
logit_model_separate <- glm(booked_bool ~ geo_diverse +price_diverse + quality_diverse + 
                        visitor_location_id + prop_country_id +length_of_stay + booking_window +
                        search_adult_count + search_child_count + room_count + saturday_bool,
                        family = "binomial"(link = "logit"), search_data_grouped)
summary(logit_model_separate)


#linear models with number of clicks as depedent variable
clicks_model_price_quality_ratio <- lm(no_click ~ geo_diverse + price_quality_diverse + 
                                     visitor_location_id + prop_country_id +length_of_stay + booking_window +
                                     search_adult_count + search_child_count + room_count + saturday_bool,
                                     data_clean)
summary(clicks_model_price_quality_ratio)


clicks_model_separate <- lm(no_click ~ geo_diverse +price_diverse + quality_diverse + 
                          visitor_location_id + prop_country_id +length_of_stay + booking_window +
                          search_adult_count + search_child_count + room_count + saturday_bool,
                          search_data_grouped)
summary(clicks_model_separate)

