-- Average Spend Per Customer in Each Location
SELECT
   GeoCode, 
   AVG(CustTotal) AS AveAmtPerCustomer
FROM
   (SELECT
       Summary.SFCCode AS GeoCode, 
       Lines.CustID, 
       SUM(LineDollar) AS CustTotal
    FROM
       Lines
    LEFT JOIN Summary ON Lines.CustID = Summary.CustID
    GROUP BY
       Lines.CustID, Summary.SFCCode) AS CustTotalTable
WHERE
   GeoCode IS NOT NULL
GROUP BY
   GeoCode
ORDER BY
   AveAmtPerCustomer DESC
LIMIT
   5
