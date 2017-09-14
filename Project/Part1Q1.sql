--- bookings/impressions ---
SELECT srch_id, COUNT(prop_id) AS Impression, SUM(booking_bool) AS Purchase,
       SUM(booking_bool)*1.00/COUNT(srch_id) AS Conversion FROM train
GROUP BY srch_id;

--- clicks and bookings for each position ---
SELECT train.position, sum(booking_bool) AS Purchase, sum(click_bool) AS Clicks
FROM train
GROUP by train.position
ORDER BY train.position ASC ;


SELECT srch_id, sum(click_bool) AS Clicks, SUM(booking_bool) AS Purchases,
  (SUM(booking_bool) + 1)*1.00/(sum(click_bool) + 1) AS Conversion --- Add 1 to avoid divided by 0 ---
       FROM train
         WHERE random_bool = 0 --- random ---
GROUP BY srch_id;

SELECT srch_id, sum(click_bool) AS Clicks, SUM(booking_bool) AS Purchases,
  (SUM(booking_bool) + 1)*1.00/(sum(click_bool) + 1) AS Conversion --- Add 1 to avoid divided by 0 ---
       FROM train
         WHERE random_bool = 1 --- sorted ---
GROUP BY srch_id;

--- Insert data into table sorted and random ---

SELECT avg(conversion)
FROM sorted;

SELECT avg(conversion)
FROM random;


SELECT srch_id,count()
FROM train
WHERE random_bool = 1;
