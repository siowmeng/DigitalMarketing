-- Build RDA Table
WITH RDAData AS (
    SELECT
        OrdersFirstSet.CustID,
        MIN('2007-01-01'::date - OrderDate) AS RecencyDays,
		AVG(StoreDist) AS Distance,
		AVG(AgeCode) AS AgeC
	FROM
		OrdersFirstSet
	LEFT JOIN Summary ON OrdersFirstSet.CustID = Summary.CustID
	WHERE
		OrdersFirstSet.CustID IN (SELECT DISTINCT(CustID) FROM OrdersSecondSet) AND StoreDist IS NOT NULL AND AgeCode IS NOT NULL
	GROUP BY
		OrdersFirstSet.CustID, StoreDist, AgeCode
)
SELECT
    CustID,
    RecencyDays,
    NTILE(5) OVER (ORDER BY RecencyDays DESC, CustID) AS R,
    Distance,
    NTILE(5) OVER (ORDER BY Distance DESC, CustID) AS D,
    AgeC,
    NTILE(5) OVER (ORDER BY AgeC ASC, CustID) AS A
INTO
    RDATable
FROM
    RDAData;

-- RDA Response Rate (First Set)
WITH RDAResponseRateTraining AS (
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
    D,
    A
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
        Contacts.CustID IN (SELECT CustID FROM RDATable) AND -- Only Estimate the customers that are segmented
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
	    CustID IN (SELECT CustID FROM RDATable) -- Only Estimate the customers that are segmented
    GROUP BY
        CustID, ContactType) T2
    ON T1.ContactType = T2.ContactType AND T1.CustID = T2.CustID
	LEFT JOIN
	(SELECT
	    CustID, R, D, A -- Join the RDA Rankings
	FROM
	    RDATable) T3
	ON T2.CustID = T3.CustID
)
SELECT
    ContactType,
    R,
    D,
    A,
    ROUND(AVG(ResponseRate) * 100, 2) AS AvgRespPercent
INTO
    RDARespRateTraining
FROM 
    RDAResponseRateTraining
GROUP BY 
    ContactType, R, D, A
ORDER BY
    ContactType, (R, D, A) DESC;


-- RDA Response Rate (Second Set)
WITH RDAResponseRate AS (
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
    D,
    A
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
        Contacts.CustID IN (SELECT CustID FROM RDATable) AND -- Only Estimate the customers that are segmented
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
	    CustID IN (SELECT CustID FROM RDATable) -- Only Estimate the customers that are segmented
    GROUP BY
        CustID, ContactType) T2
    ON T1.ContactType = T2.ContactType AND T1.CustID = T2.CustID
	LEFT JOIN
	(SELECT
	    CustID, R, D, A -- Join the RDA Rankings
	FROM
	    RDATable) T3
	ON T2.CustID = T3.CustID
)
SELECT
    ContactType,
    R,
    D,
    A,
    ROUND(AVG(ResponseRate) * 100, 2) AS AvgRespPercent
INTO
    RDARespRate
FROM 
    RDAResponseRate
GROUP BY 
    ContactType, R, D, A
ORDER BY
    ContactType, (R, D, A) DESC;


-- RDA Revenue (First Set)
WITH RDARevenueTraining AS (
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
        Contacts.CustID IN (SELECT CustID FROM RDATable) AND -- Only Estimate the customers that are segmented
        OrdersFirstSet.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Orders made within 30 days of contacts
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END -- Condition to match OrderMethod with ContactType
), AvgCustSpend AS (
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
        (SELECT CustID, OrderNo, OrderDate FROM RDARevenueTraining) -- Valid orders are orders from RDA customers, made within 30 days of contacts and OrderMethod matches the ContactType
    GROUP BY
        OrdersFirstSet.CustID, ContactType
)
SELECT
    ContactType,
    R,
    D,
    A,
    ROUND(AVG(AvgCustSpendPerOrder), 2) AS AvgSpend
INTO
    RDARevenueTraining
FROM
    AvgCustSpend
LEFT JOIN RDATable ON AvgCustSpend.CustID = RDATable.CustID
GROUP BY
    ContactType, R, D, A
ORDER BY
    ContactType, (R, D, A) DESC;


-- RDA Revenue (Second Set)
WITH RDARevenue AS (
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
        Contacts.CustID IN (SELECT CustID FROM RDATable) AND -- Only Estimate the customers that are segmented
        OrdersSecondSet.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Orders made within 30 days of contacts
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END -- Condition to match OrderMethod with ContactType
), AvgCustSpend AS (
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
        (SELECT CustID, OrderNo, OrderDate FROM RDARevenue) -- Valid orders are orders from RDA customers, made within 30 days of contacts and OrderMethod matches the ContactType
    GROUP BY
        OrdersSecondSet.CustID, ContactType
)
SELECT
    ContactType,
    R,
    D,
    A,
    ROUND(AVG(AvgCustSpendPerOrder), 2) AS AvgSpend
INTO
    RDARevenue
FROM
    AvgCustSpend
LEFT JOIN RDATable ON AvgCustSpend.CustID = RDATable.CustID
GROUP BY
    ContactType, R, D, A
ORDER BY
    ContactType, (R, D, A) DESC;


-- Display both ResponseRate and Revenue (for Catalog and Email) in nice table format (First Set)
SELECT
    CatalogTable.R,
    CatalogTable.D,
    CatalogTable.A,
    CatalogTable.AvgRespPercent AS CatalogRespRate,
    EmailTable.AvgRespPercent AS EmailRespRate,
    COALESCE(CatalogTable.AvgSpend, 0) AS CatalogAvgSpend,
    COALESCE(EmailTable.AvgSpend, 0) AS EmailAvgSpend
FROM
    (SELECT
        RDARespRateTraining.ContactType,
        RDARespRateTraining.R,
        RDARespRateTraining.D,
        RDARespRateTraining.A,
        AvgRespPercent,
        AvgSpend
    FROM
        RDARespRateTraining
    LEFT JOIN
        RDARevenueTraining
    ON RDARespRateTraining.ContactType = RDARevenueTraining.ContactType AND RDARespRateTraining.R = RDARevenueTraining.R AND RDARespRateTraining.D = RDARevenueTraining.D AND RDARespRateTraining.A = RDARevenueTraining.A
    WHERE
        RDARespRateTraining.ContactType = 'C'
    ORDER BY
        RDARespRateTraining.ContactType, (RDARespRateTraining.R, RDARespRateTraining.D, RDARespRateTraining.A) DESC) CatalogTable
    LEFT JOIN
    (SELECT
        RDARespRateTraining.ContactType,
        RDARespRateTraining.R,
        RDARespRateTraining.D,
        RDARespRateTraining.A,
        AvgRespPercent,
        AvgSpend
    FROM
        RDARespRateTraining
    LEFT JOIN
        RDARevenueTraining
    ON RDARespRateTraining.ContactType = RDARevenueTraining.ContactType AND RDARespRateTraining.R = RDARevenueTraining.R AND RDARespRateTraining.D = RDARevenueTraining.D AND RDARespRateTraining.A = RDARevenueTraining.A
    WHERE
        RDARespRateTraining.ContactType = 'E'
    ORDER BY
        RDARespRateTraining.ContactType, (RDARespRateTraining.R, RDARespRateTraining.D, RDARespRateTraining.A) DESC) EmailTable
    ON CatalogTable.R = EmailTable.R AND CatalogTable.D = EmailTable.D AND CatalogTable.A = EmailTable.A
ORDER BY
    (CatalogTable.R, CatalogTable.D, CatalogTable.A) DESC;	


-- Display both ResponseRate and Revenue (for Catalog and Email) in nice table format (Second Set)
SELECT
    CatalogTable.R,
    CatalogTable.D,
    CatalogTable.A,
    CatalogTable.AvgRespPercent AS CatalogRespRate,
    EmailTable.AvgRespPercent AS EmailRespRate,
    COALESCE(CatalogTable.AvgSpend, 0) AS CatalogAvgSpend,
    COALESCE(EmailTable.AvgSpend, 0) AS EmailAvgSpend
FROM
    (SELECT
        RDARespRate.ContactType,
        RDARespRate.R,
        RDARespRate.D,
        RDARespRate.A,
        AvgRespPercent,
        AvgSpend
    FROM
        RDARespRate
    LEFT JOIN
        RDARevenue
    ON RDARespRate.ContactType = RDARevenue.ContactType AND RDARespRate.R = RDARevenue.R AND RDARespRate.D = RDARevenue.D AND RDARespRate.A = RDARevenue.A
    WHERE
        RDARespRate.ContactType = 'C'
    ORDER BY
        RDARespRate.ContactType, (RDARespRate.R, RDARespRate.D, RDARespRate.A) DESC) CatalogTable
    LEFT JOIN
    (SELECT
        RDARespRate.ContactType,
        RDARespRate.R,
        RDARespRate.D,
        RDARespRate.A,
        AvgRespPercent,
        AvgSpend
    FROM
        RDARespRate
    LEFT JOIN
        RDARevenue
    ON RDARespRate.ContactType = RDARevenue.ContactType AND RDARespRate.R = RDARevenue.R AND RDARespRate.D = RDARevenue.D AND RDARespRate.A = RDARevenue.A
    WHERE
        RDARespRate.ContactType = 'E'
    ORDER BY
        RDARespRate.ContactType, (RDARespRate.R, RDARespRate.D, RDARespRate.A) DESC) EmailTable
    ON CatalogTable.R = EmailTable.R AND CatalogTable.D = EmailTable.D AND CatalogTable.A = EmailTable.A
ORDER BY
    (CatalogTable.R, CatalogTable.D, CatalogTable.A) DESC;
