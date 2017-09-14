-- Average Spend Per Order in Each Location
SELECT
   GeoCode, 
   AVG(OrderTotal) AS AveAmtPerOrder
FROM
   (SELECT
       Summary.SFCCode AS GeoCode, 
       Lines.CustID, 
       Lines.OrderNo, 
       Lines.OrderDate, 
       SUM(LineDollar) AS OrderTotal
    FROM
       Lines
    LEFT JOIN Summary ON Lines.CustID = Summary.CustID
    GROUP BY
       Lines.CustID, Lines.OrderNo, Lines.OrderDate, Summary.SFCCode) AS OrderTotalTable
WHERE
   GeoCode IS NOT NULL
GROUP BY
   GeoCode
ORDER BY
   AveAmtPerOrder DESC
LIMIT
   5

