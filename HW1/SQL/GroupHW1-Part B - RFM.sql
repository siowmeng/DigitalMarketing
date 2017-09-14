-- First Set of Data
SELECT
    CustID, OrderNo, OrderDate, SUM(LineDollar) AS AmtSpent
INTO
    OrdersFirstSet
FROM
    Lines
WHERE 
    (CustID IN (SELECT DISTINCT(CustID) FROM Contacts)) AND OrderDate >= '2005-01-06'::date AND OrderDate < '2007-01-01'::date
GROUP BY
    CustID, OrderNo, OrderDate;

-- Second Set of Data
SELECT
    CustID, OrderNo, OrderDate, SUM(LineDollar) AS AmtSpent
INTO
    OrdersSecondSet
FROM
    Lines
WHERE 
    (CustID IN (SELECT DISTINCT(CustID) FROM Contacts)) AND OrderDate >= '2007-01-01'::date
GROUP BY
    CustID, OrderNo, OrderDate;

-- Number of Distinct Customers in 1st set
SELECT
    COUNT(DISTINCT(CustID))
FROM
    OrdersFirstSet;

-- Number of customers exist in both 1st and 2nd set
SELECT
    COUNT(DISTINCT(CustID))
FROM
    OrdersSecondSet
WHERE
    CustID IN (SELECT DISTINCT(CustID) FROM OrdersFirstSet);


-- Build RFM Table
WITH RFMData AS (
    SELECT
        CustID,
        MIN('2007-01-01'::date - OrderDate) AS RecencyDays,
        COUNT(*) AS FrequencyCounts,
        AVG(AmtSpent) AS AvgSpend
    FROM
        OrdersFirstSet
    WHERE
        CustID IN (SELECT DISTINCT(CustID) FROM OrdersSecondSet)
    GROUP BY
        CustID
)
SELECT
    CustID,
    RecencyDays,
    NTILE(5) OVER (ORDER BY RecencyDays DESC, CustID) AS R,
    FrequencyCounts,
    NTILE(5) OVER (ORDER BY FrequencyCounts ASC, CustID) AS F,
    AvgSpend,
    NTILE(5) OVER (ORDER BY AvgSpend ASC, CustID) AS M
INTO
    RFMTable
FROM
    RFMData;

-- RFM Response Rate Training (First Set)
WITH RFMResponseRateTraining AS (
SELECT
    T2.CustID,
    T2.ContactType,
    NumOrders,
    NumContacts,
    CASE WHEN (NumOrders * 1.00 / NumContacts) IS NULL THEN 0 -- Cap individual response rate at 1
         WHEN (NumOrders * 1.00 / NumContacts) > 1 THEN 1
         ELSE (NumOrders * 1.00 / NumContacts) END
    AS ResponseRate,
    R,
    F,
    M
FROM
    (SELECT 
        Contacts.CustID,
        ContactType,
        COUNT(DISTINCT (OrdersFirstSet.OrderNo, OrdersFirstSet.OrderDate)) AS NumOrders -- Distinct Order is distinguished by the tuple
    FROM 
        Contacts
    LEFT JOIN OrdersFirstSet ON Contacts.CustID = OrdersFirstSet.CustID
    LEFT JOIN Orders ON OrdersFirstSet.CustID = Orders.CustID AND OrdersFirstSet.OrderNo = Orders.OrderNo AND OrdersFirstSet.OrderDate = Orders.OrderDate
    WHERE 
        Contacts.CustID IN (SELECT CustID FROM RFMTable) AND -- Only Estimate the customers that are segmented
        OrdersFirstSet.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Orders made within 30 days of contacts
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END -- Condition to match OrderMethod with ContactType
    GROUP BY 
        Contacts.CustID, ContactType) T1 
    RIGHT OUTER JOIN
    (SELECT
        CustID, ContactType, COUNT(*) AS NumContacts
    FROM
        Contacts
	WHERE
	    CustID IN (SELECT CustID FROM RFMTable) -- Only Estimate the customers that are segmented
    GROUP BY
        CustID, ContactType) T2
    ON T1.ContactType = T2.ContactType AND T1.CustID = T2.CustID
	LEFT JOIN
	(SELECT
	    CustID, R, F, M -- Join the RFM Rankings
	FROM
	    RFMTable) T3
	ON T2.CustID = T3.CustID
)
SELECT
    ContactType,
    R,
    F,
    M,
    ROUND(AVG(ResponseRate) * 100, 2) AS AvgRespPercent
INTO
    RFMRespRateTraining
FROM 
    RFMResponseRateTraining
GROUP BY 
    ContactType, R, F, M
ORDER BY
    ContactType, (R, F, M) DESC;

	

-- RFM Response Rate (Second Set)
WITH RFMResponseRate AS (
SELECT
    T2.CustID,
    T2.ContactType,
    NumOrders,
    NumContacts,
    CASE WHEN (NumOrders * 1.00 / NumContacts) IS NULL THEN 0 -- Cap individual response rate at 1
         WHEN (NumOrders * 1.00 / NumContacts) > 1 THEN 1
         ELSE (NumOrders * 1.00 / NumContacts) END
    AS ResponseRate,
    R,
    F,
    M
FROM
    (SELECT 
        Contacts.CustID,
        ContactType,
        COUNT(DISTINCT (OrdersSecondSet.OrderNo, OrdersSecondSet.OrderDate)) AS NumOrders -- Distinct Order is distinguished by the tuple
    FROM 
        Contacts
    LEFT JOIN OrdersSecondSet ON Contacts.CustID = OrdersSecondSet.CustID
    LEFT JOIN Orders ON OrdersSecondSet.CustID = Orders.CustID AND OrdersSecondSet.OrderNo = Orders.OrderNo AND OrdersSecondSet.OrderDate = Orders.OrderDate
    WHERE 
        Contacts.CustID IN (SELECT CustID FROM RFMTable) AND -- Only Estimate the customers that are segmented
        OrdersSecondSet.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Orders made within 30 days of contacts
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END -- Condition to match OrderMethod with ContactType
    GROUP BY 
        Contacts.CustID, ContactType) T1 
    RIGHT OUTER JOIN
    (SELECT
        CustID, ContactType, COUNT(*) AS NumContacts
    FROM
        Contacts
	WHERE
	    CustID IN (SELECT CustID FROM RFMTable) -- Only Estimate the customers that are segmented
    GROUP BY
        CustID, ContactType) T2
    ON T1.ContactType = T2.ContactType AND T1.CustID = T2.CustID
	LEFT JOIN
	(SELECT
	    CustID, R, F, M -- Join the RFM Rankings
	FROM
	    RFMTable) T3
	ON T2.CustID = T3.CustID
)
SELECT
    ContactType,
    R,
    F,
    M,
    ROUND(AVG(ResponseRate) * 100, 2) AS AvgRespPercent
INTO
    RFMRespRate
FROM 
    RFMResponseRate
GROUP BY 
    ContactType, R, F, M
ORDER BY
    ContactType, (R, F, M) DESC;

-- RFM Revenue (First Set)
WITH RFMRevenueTraining AS (
    SELECT 
        ContactType,
        OrdersFirstSet.CustID,
        OrdersFirstSet.OrderNo, 
        OrdersFirstSet.OrderDate
    FROM 
        Contacts
    LEFT JOIN OrdersFirstSet ON Contacts.CustID = OrdersFirstSet.CustID
    LEFT JOIN Orders ON OrdersFirstSet.CustID = Orders.CustID AND OrdersFirstSet.OrderNo = Orders.OrderNo AND OrdersFirstSet.OrderDate = Orders.OrderDate
    WHERE 
        Contacts.CustID IN (SELECT CustID FROM RFMTable) AND -- Only Estimate the customers that are segmented
        OrdersFirstSet.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Orders made within 30 days of contacts
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END -- Condition to match OrderMethod with ContactType
), AvgCustSpend AS ( -- Averae Amount Spent Per Order for Each Customer
    SELECT
        OrdersFirstSet.CustID,
        AVG(AmtSpent) AS AvgCustSpendPerOrder,
        CASE OrderMethod WHEN 'P' THEN 'C' -- Map OrderMethod to ContactType
                         WHEN 'M' THEN 'C'
                         WHEN 'I' THEN 'E'
                         ELSE 'ST' END
        AS ContactType
    FROM
        OrdersFirstSet
    LEFT JOIN 
        Orders ON OrdersFirstSet.CustID = Orders.CustID AND OrdersFirstSet.OrderNo = Orders.OrderNo AND OrdersFirstSet.OrderDate = Orders.OrderDate
    WHERE
        (OrdersFirstSet.CustID, OrdersFirstSet.OrderNo, OrdersFirstSet.OrderDate) 
    IN 
        (SELECT CustID, OrderNo, OrderDate FROM RFMRevenueTraining) -- Valid orders are orders from RFM customers, made within 30 days of contacts and OrderMethod matches the ContactType
    GROUP BY
        OrdersFirstSet.CustID, ContactType
)
SELECT
    ContactType,
    R,
    F,
    M,
    ROUND(AVG(AvgCustSpendPerOrder), 2) AS AvgSpend
INTO
    RFMRevenueTraining
FROM
    AvgCustSpend
LEFT JOIN RFMTable ON AvgCustSpend.CustID = RFMTable.CustID
GROUP BY
    ContactType, R, F, M
ORDER BY
    ContactType, (R, F, M) DESC;

-- RFM Revenue (Second Set)
WITH RFMRevenue AS (
    SELECT 
        ContactType,
        OrdersSecondSet.CustID,
        OrdersSecondSet.OrderNo, 
        OrdersSecondSet.OrderDate
    FROM 
        Contacts
    LEFT JOIN OrdersSecondSet ON Contacts.CustID = OrdersSecondSet.CustID
    LEFT JOIN Orders ON OrdersSecondSet.CustID = Orders.CustID AND OrdersSecondSet.OrderNo = Orders.OrderNo AND OrdersSecondSet.OrderDate = Orders.OrderDate
    WHERE 
        Contacts.CustID IN (SELECT CustID FROM RFMTable) AND -- Only Estimate the customers that are segmented
        OrdersSecondSet.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Orders made within 30 days of contacts
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END -- Condition to match OrderMethod with ContactType
), AvgCustSpend AS ( -- Averae Amount Spent Per Order for Each Customer
    SELECT
        OrdersSecondSet.CustID,
        AVG(AmtSpent) AS AvgCustSpendPerOrder,
        CASE OrderMethod WHEN 'P' THEN 'C' -- Map OrderMethod to ContactType
                         WHEN 'M' THEN 'C'
                         WHEN 'I' THEN 'E'
                         ELSE 'ST' END
        AS ContactType
    FROM
        OrdersSecondSet
    LEFT JOIN 
        Orders ON OrdersSecondSet.CustID = Orders.CustID AND OrdersSecondSet.OrderNo = Orders.OrderNo AND OrdersSecondSet.OrderDate = Orders.OrderDate
    WHERE
        (OrdersSecondSet.CustID, OrdersSecondSet.OrderNo, OrdersSecondSet.OrderDate) 
    IN 
        (SELECT CustID, OrderNo, OrderDate FROM RFMRevenue) -- Valid orders are orders from RFM customers, made within 30 days of contacts and OrderMethod matches the ContactType
    GROUP BY
        OrdersSecondSet.CustID, ContactType
)
SELECT
    ContactType,
    R,
    F,
    M,
    ROUND(AVG(AvgCustSpendPerOrder), 2) AS AvgSpend
INTO
    RFMRevenue
FROM
    AvgCustSpend
LEFT JOIN RFMTable ON AvgCustSpend.CustID = RFMTable.CustID
GROUP BY
    ContactType, R, F, M
ORDER BY
    ContactType, (R, F, M) DESC;

-- Display both ResponseRate and Revenue (for Catalog and Email) in nice table format (First Set)
SELECT
    CatalogTable.R,
    CatalogTable.F,
    CatalogTable.M,
    CatalogTable.AvgRespPercent AS CatalogRespRate,
    EmailTable.AvgRespPercent AS EmailRespRate,
    COALESCE(CatalogTable.AvgSpend, 0) AS CatalogAvgSpend,
    COALESCE(EmailTable.AvgSpend, 0) AS EmailAvgSpend
FROM
    (SELECT
        RFMRespRateTraining.ContactType,
        RFMRespRateTraining.R,
        RFMRespRateTraining.F,
        RFMRespRateTraining.M,
        AvgRespPercent,
        AvgSpend
    FROM
        RFMRespRateTraining
    LEFT JOIN
        RFMRevenueTraining
    ON RFMRespRateTraining.ContactType = RFMRevenueTraining.ContactType AND RFMRespRateTraining.R = RFMRevenueTraining.R AND RFMRespRateTraining.F = RFMRevenueTraining.F AND RFMRespRateTraining.M = RFMRevenueTraining.M
    WHERE
        RFMRespRateTraining.ContactType = 'C'
    ORDER BY
        RFMRespRateTraining.ContactType, (RFMRespRateTraining.R, RFMRespRateTraining.F, RFMRespRateTraining.M) DESC) CatalogTable
    LEFT JOIN
    (SELECT
        RFMRespRateTraining.ContactType,
        RFMRespRateTraining.R,
        RFMRespRateTraining.F,
        RFMRespRateTraining.M,
        AvgRespPercent,
        AvgSpend
    FROM
        RFMRespRateTraining
    LEFT JOIN
        RFMRevenueTraining
    ON RFMRespRateTraining.ContactType = RFMRevenueTraining.ContactType AND RFMRespRateTraining.R = RFMRevenueTraining.R AND RFMRespRateTraining.F = RFMRevenueTraining.F AND RFMRespRateTraining.M = RFMRevenueTraining.M
    WHERE
        RFMRespRateTraining.ContactType = 'E'
    ORDER BY
        RFMRespRateTraining.ContactType, (RFMRespRateTraining.R, RFMRespRateTraining.F, RFMRespRateTraining.M) DESC) EmailTable
    ON CatalogTable.R = EmailTable.R AND CatalogTable.F = EmailTable.F AND CatalogTable.M = EmailTable.M
ORDER BY
    (CatalogTable.R, CatalogTable.F, CatalogTable.M) DESC;



-- Display both ResponseRate and Revenue (for Catalog and Email) in nice table format (Second Set)
SELECT
    CatalogTable.R,
    CatalogTable.F,
    CatalogTable.M,
    CatalogTable.AvgRespPercent AS CatalogRespRate,
    EmailTable.AvgRespPercent AS EmailRespRate,
    COALESCE(CatalogTable.AvgSpend, 0) AS CatalogAvgSpend,
    COALESCE(EmailTable.AvgSpend, 0) AS EmailAvgSpend
FROM
    (SELECT
        RFMRespRate.ContactType,
        RFMRespRate.R,
        RFMRespRate.F,
        RFMRespRate.M,
        AvgRespPercent,
        AvgSpend
    FROM
        RFMRespRate
    LEFT JOIN
        RFMRevenue
    ON RFMRespRate.ContactType = RFMRevenue.ContactType AND RFMRespRate.R = RFMRevenue.R AND RFMRespRate.F = RFMRevenue.F AND RFMRespRate.M = RFMRevenue.M
    WHERE
        RFMRespRate.ContactType = 'C'
    ORDER BY
        RFMRespRate.ContactType, (RFMRespRate.R, RFMRespRate.F, RFMRespRate.M) DESC) CatalogTable
    LEFT JOIN
    (SELECT
        RFMRespRate.ContactType,
        RFMRespRate.R,
        RFMRespRate.F,
        RFMRespRate.M,
        AvgRespPercent,
        AvgSpend
    FROM
        RFMRespRate
    LEFT JOIN
        RFMRevenue
    ON RFMRespRate.ContactType = RFMRevenue.ContactType AND RFMRespRate.R = RFMRevenue.R AND RFMRespRate.F = RFMRevenue.F AND RFMRespRate.M = RFMRevenue.M
    WHERE
        RFMRespRate.ContactType = 'E'
    ORDER BY
        RFMRespRate.ContactType, (RFMRespRate.R, RFMRespRate.F, RFMRespRate.M) DESC) EmailTable
    ON CatalogTable.R = EmailTable.R AND CatalogTable.F = EmailTable.F AND CatalogTable.M = EmailTable.M
ORDER BY
    (CatalogTable.R, CatalogTable.F, CatalogTable.M) DESC;
