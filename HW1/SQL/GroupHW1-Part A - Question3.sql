-- ResponseRate (WhiteCollar)
CREATE VIEW ResponseCustomerWhiteCollar AS
    SELECT 
	    T2.CustID, 
		T2.ContactType, 
		CASE WHEN (NumOrders * 1.00 / NumContacts) IS NULL THEN 0 -- Cap individual response rate at 1
		     WHEN (NumOrders * 1.00 / NumContacts) > 1 THEN 1
			 ELSE (NumOrders * 1.00 / NumContacts) END
		AS ResponseRate
FROM
    (SELECT 
        Contacts.CustID,
        ContactType,
        COUNT(DISTINCT (Orders.OrderNo, Orders.OrderDate)) AS NumOrders -- Distinct Order is distinguished by the tuple
    FROM 
        Contacts
    LEFT JOIN Orders ON Contacts.CustID = Orders.CustID
    WHERE 
	    Contacts.CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 1 AND OccupCd <= 7) AND
        Orders.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END -- Condition to match OrderMethod with ContactType
    GROUP BY 
        Contacts.CustID, ContactType) T1 
    RIGHT OUTER JOIN
    (SELECT
        CustID, ContactType, COUNT(*) AS NumContacts -- COUNT(*) since there can be more than 1 contacts per day
    FROM
        Contacts 
	WHERE 
	    CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 1 AND OccupCd <= 7)
    GROUP BY
        CustID, ContactType) T2
    ON T1.ContactType = T2.ContactType AND T1.CustID = T2.CustID
;

-- Average Response Rate (Average Across the Individual Response Rates)
SELECT 
    ContactType, 
	AVG(ResponseRate)
FROM 
    ResponseCustomerWhiteCollar
GROUP BY 
    ContactType;

-- Average Response Rate (Total Orders / Total Contacts)
SELECT
    T2.ContactType,
    SUM(NumOrders) * 1.00 / SUM(NumContacts)
FROM
    (SELECT 
        Contacts.CustID,
        ContactType,
        COUNT(DISTINCT (Orders.OrderNo, Orders.OrderDate)) AS NumOrders
    FROM 
        Contacts
    LEFT JOIN Orders ON Contacts.CustID = Orders.CustID
    WHERE 
	    Contacts.CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 1 AND OccupCd <= 7) AND
        Orders.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Add WHERE CustID FROM SELECT(DISTINCT) FROM SUmmary Table for additional criteria
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END
    GROUP BY 
        Contacts.CustID, ContactType) T1 
    RIGHT OUTER JOIN
    (SELECT
        CustID, ContactType, COUNT(*) AS NumContacts
    FROM
        Contacts 
	WHERE 
	    CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 1 AND OccupCd <= 7)
    GROUP BY
        CustID, ContactType) T2
    ON T1.ContactType = T2.ContactType AND T1.CustID = T2.CustID
GROUP BY
    T2.ContactType;
	
-- Revenue (WhiteCollar)
CREATE VIEW RevenueCustomerWhiteCollar AS
    SELECT 
        Orders.CustID AS CustID, 
        Orders.OrderNo AS OrderNo, 
        Orders.OrderDate AS OrderDate, 
        ContactType
    FROM 
        Contacts
    LEFT JOIN Orders ON Contacts.CustID = Orders.CustID
    WHERE 
	    Contacts.CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 1 AND OccupCd <= 7) AND
        Orders.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Add WHERE CustID FROM SELECT(DISTINCT) FROM SUmmary Table for additional criteria
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END
;
		
-- Revenue per Catalog Order (Averaged across orders)
SELECT
    SUM(LineDollar) / COUNT(DISTINCT(CustID, OrderNo, OrderDate))
FROM
    Lines
WHERE
    (CustID, OrderNo, OrderDate) 
IN 
    (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerWhiteCollar WHERE ContactType = 'C');
	
-- Revenue per Catalog Order (Averaged across average customer spend per order)
WITH OrderSum AS (
    SELECT
        CustID,
        OrderNo,
        OrderDate,
        SUM(LineDollar) AS Amount
    FROM
        Lines
    WHERE
        (CustID, OrderNo, OrderDate) 
    IN 
        (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerWhiteCollar WHERE ContactType = 'C')
    GROUP BY
        CustID, OrderNo, OrderDate
), AvgCustSpend AS (
    SELECT
        CustID, 
        AVG(OrderSum.Amount) AS AvgCustSpendPerOrder
    FROM
        OrderSum
    GROUP BY
        CustID
)
SELECT
    AVG(AvgCustSpendPerOrder) AS AvgCatalogSpend
FROM
    AvgCustSpend
	
-- Revenue per Internet Order (Averaged across orders)
SELECT
    SUM(LineDollar) / COUNT(DISTINCT(CustID, OrderNo, OrderDate))
FROM
    Lines
WHERE
    (CustID, OrderNo, OrderDate) 
IN 
    (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerWhiteCollar WHERE ContactType = 'E');

-- Revenue per Internet Order (Averaged across average customer spend per order)
WITH OrderSum AS (
    SELECT
        CustID,
        OrderNo,
        OrderDate,
        SUM(LineDollar) AS Amount
    FROM
        Lines
    WHERE
        (CustID, OrderNo, OrderDate) 
    IN 
        (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerWhiteCollar WHERE ContactType = 'E')
    GROUP BY
        CustID, OrderNo, OrderDate
), AvgCustSpend AS (
    SELECT
        CustID, 
        AVG(OrderSum.Amount) AS AvgCustSpendPerOrder
    FROM
        OrderSum
    GROUP BY
        CustID
)
SELECT
    AVG(AvgCustSpendPerOrder) AS AvgEmailSpend
FROM
    AvgCustSpend




-- ResponseRate (BlueCollar)
CREATE VIEW ResponseCustomerBlueCollar AS
    SELECT 
	    T2.CustID, 
		T2.ContactType, 
		CASE WHEN (NumOrders * 1.00 / NumContacts) IS NULL THEN 0 -- Cap individual response rate at 1
		     WHEN (NumOrders * 1.00 / NumContacts) > 1 THEN 1
			 ELSE (NumOrders * 1.00 / NumContacts) END
		AS ResponseRate
FROM
    (SELECT 
        Contacts.CustID,
        ContactType,
        COUNT(DISTINCT (Orders.OrderNo, Orders.OrderDate)) AS NumOrders -- Distinct Order is distinguished by the tuple
    FROM 
        Contacts
    LEFT JOIN Orders ON Contacts.CustID = Orders.CustID
    WHERE 
	    Contacts.CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 8 AND OccupCd <= 12) AND
        Orders.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END -- Condition to match OrderMethod with ContactType
    GROUP BY 
        Contacts.CustID, ContactType) T1 
    RIGHT OUTER JOIN
    (SELECT
        CustID, ContactType, COUNT(*) AS NumContacts -- COUNT(*) since there can be more than 1 contacts per day
    FROM
        Contacts 
	WHERE 
	    CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 8 AND OccupCd <= 12)
    GROUP BY
        CustID, ContactType) T2
    ON T1.ContactType = T2.ContactType AND T1.CustID = T2.CustID
;

-- Average Response Rate (Average Across the Individual Response Rates)
SELECT 
    ContactType, 
	AVG(ResponseRate)
FROM 
    ResponseCustomerBlueCollar
GROUP BY 
    ContactType;

-- Average Response Rate (Total Orders / Total Contacts)
SELECT
    T2.ContactType,
    SUM(NumOrders) * 1.00 / SUM(NumContacts)
FROM
    (SELECT 
        Contacts.CustID,
        ContactType,
        COUNT(DISTINCT (Orders.OrderNo, Orders.OrderDate)) AS NumOrders
    FROM 
        Contacts
    LEFT JOIN Orders ON Contacts.CustID = Orders.CustID
    WHERE 
	    Contacts.CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 8 AND OccupCd <= 12) AND
        Orders.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Add WHERE CustID FROM SELECT(DISTINCT) FROM SUmmary Table for additional criteria
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END
    GROUP BY 
        Contacts.CustID, ContactType) T1 
    RIGHT OUTER JOIN
    (SELECT
        CustID, ContactType, COUNT(*) AS NumContacts
    FROM
        Contacts 
	WHERE 
	    CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 8 AND OccupCd <= 12)
    GROUP BY
        CustID, ContactType) T2
    ON T1.ContactType = T2.ContactType AND T1.CustID = T2.CustID
GROUP BY
    T2.ContactType;
	
-- Revenue	
CREATE VIEW RevenueCustomerBlueCollar AS
    SELECT 
        Orders.CustID AS CustID, 
        Orders.OrderNo AS OrderNo, 
        Orders.OrderDate AS OrderDate, 
        ContactType
    FROM 
        Contacts
    LEFT JOIN Orders ON Contacts.CustID = Orders.CustID
    WHERE 
	    Contacts.CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 8 AND OccupCd <= 12) AND
        Orders.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Add WHERE CustID FROM SELECT(DISTINCT) FROM SUmmary Table for additional criteria
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END
;
		
-- Revenue per Catalog Order (Averaged across orders)
SELECT
    SUM(LineDollar) / COUNT(DISTINCT(CustID, OrderNo, OrderDate))
FROM
    Lines
WHERE
    (CustID, OrderNo, OrderDate) 
IN 
    (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerBlueCollar WHERE ContactType = 'C');
	
-- Revenue per Catalog Order (Averaged across average customer spend per order)
WITH OrderSum AS (
    SELECT
        CustID,
        OrderNo,
        OrderDate,
        SUM(LineDollar) AS Amount
    FROM
        Lines
    WHERE
        (CustID, OrderNo, OrderDate) 
    IN 
        (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerBlueCollar WHERE ContactType = 'C')
    GROUP BY
        CustID, OrderNo, OrderDate
), AvgCustSpend AS (
    SELECT
        CustID, 
        AVG(OrderSum.Amount) AS AvgCustSpendPerOrder
    FROM
        OrderSum
    GROUP BY
        CustID
)
SELECT
    AVG(AvgCustSpendPerOrder) AS AvgCatalogSpend
FROM
    AvgCustSpend
	
-- Revenue per Internet Order (Averaged across orders)
SELECT
    SUM(LineDollar) / COUNT(DISTINCT(CustID, OrderNo, OrderDate))
FROM
    Lines
WHERE
    (CustID, OrderNo, OrderDate) 
IN 
    (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerBlueCollar WHERE ContactType = 'E');

-- Revenue per Internet Order (Averaged across average customer spend per order)
WITH OrderSum AS (
    SELECT
        CustID,
        OrderNo,
        OrderDate,
        SUM(LineDollar) AS Amount
    FROM
        Lines
    WHERE
        (CustID, OrderNo, OrderDate) 
    IN 
        (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerBlueCollar WHERE ContactType = 'E')
    GROUP BY
        CustID, OrderNo, OrderDate
), AvgCustSpend AS (
    SELECT
        CustID, 
        AVG(OrderSum.Amount) AS AvgCustSpendPerOrder
    FROM
        OrderSum
    GROUP BY
        CustID
)
SELECT
    AVG(AvgCustSpendPerOrder) AS AvgEmailSpend
FROM
    AvgCustSpend






-- ResponseRate (NotWorking)
CREATE VIEW ResponseCustomerNoWork AS
    SELECT 
	    T2.CustID, 
		T2.ContactType, 
		CASE WHEN (NumOrders * 1.00 / NumContacts) IS NULL THEN 0 -- Cap individual response rate at 1
		     WHEN (NumOrders * 1.00 / NumContacts) > 1 THEN 1
			 ELSE (NumOrders * 1.00 / NumContacts) END
		AS ResponseRate
FROM
    (SELECT 
        Contacts.CustID,
        ContactType,
        COUNT(DISTINCT (Orders.OrderNo, Orders.OrderDate)) AS NumOrders -- Distinct Order is distinguished by the tuple
    FROM 
        Contacts
    LEFT JOIN Orders ON Contacts.CustID = Orders.CustID
    WHERE 
	    Contacts.CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 13 AND OccupCd <= 15) AND
        Orders.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END -- Condition to match OrderMethod with ContactType
    GROUP BY 
        Contacts.CustID, ContactType) T1 
    RIGHT OUTER JOIN
    (SELECT
        CustID, ContactType, COUNT(*) AS NumContacts -- COUNT(*) since there can be more than 1 contacts per day
    FROM
        Contacts 
	WHERE 
	    CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 13 AND OccupCd <= 15)
    GROUP BY
        CustID, ContactType) T2
    ON T1.ContactType = T2.ContactType AND T1.CustID = T2.CustID
;

-- Average Response Rate (Average Across the Individual Response Rates)
SELECT 
    ContactType, 
	AVG(ResponseRate)
FROM 
    ResponseCustomerNoWork
GROUP BY 
    ContactType;

-- Average Response Rate (Total Orders / Total Contacts)
SELECT
    T2.ContactType,
    SUM(NumOrders) * 1.00 / SUM(NumContacts)
FROM
    (SELECT 
        Contacts.CustID,
        ContactType,
        COUNT(DISTINCT (Orders.OrderNo, Orders.OrderDate)) AS NumOrders
    FROM 
        Contacts
    LEFT JOIN Orders ON Contacts.CustID = Orders.CustID
    WHERE 
	    Contacts.CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 13 AND OccupCd <= 15) AND
        Orders.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Add WHERE CustID FROM SELECT(DISTINCT) FROM SUmmary Table for additional criteria
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END
    GROUP BY 
        Contacts.CustID, ContactType) T1 
    RIGHT OUTER JOIN
    (SELECT
        CustID, ContactType, COUNT(*) AS NumContacts
    FROM
        Contacts 
	WHERE 
	    CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 13 AND OccupCd <= 15)
    GROUP BY
        CustID, ContactType) T2
    ON T1.ContactType = T2.ContactType AND T1.CustID = T2.CustID
GROUP BY
    T2.ContactType;
	
-- Revenue	
CREATE VIEW RevenueCustomerNoWork AS
    SELECT 
        Orders.CustID AS CustID, 
        Orders.OrderNo AS OrderNo, 
        Orders.OrderDate AS OrderDate, 
        ContactType
    FROM 
        Contacts
    LEFT JOIN Orders ON Contacts.CustID = Orders.CustID
    WHERE 
	    Contacts.CustID IN (SELECT CustID FROM Summary WHERE OccupCd >= 13 AND OccupCd <= 15) AND
        Orders.OrderDate <@ daterange(ContactDate, ContactDate + 30, '[)') AND -- Add WHERE CustID FROM SELECT(DISTINCT) FROM SUmmary Table for additional criteria
        CASE ContactType WHEN 'E' THEN OrderMethod = 'I' 
                         WHEN 'C' THEN (OrderMethod = 'P' OR OrderMethod = 'M') END
;
		
-- Revenue per Catalog Order (Averaged across orders)
SELECT
    SUM(LineDollar) / COUNT(DISTINCT(CustID, OrderNo, OrderDate))
FROM
    Lines
WHERE
    (CustID, OrderNo, OrderDate) 
IN 
    (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerNoWork WHERE ContactType = 'C');
	
-- Revenue per Catalog Order (Averaged across average customer spend per order)
WITH OrderSum AS (
    SELECT
        CustID,
        OrderNo,
        OrderDate,
        SUM(LineDollar) AS Amount
    FROM
        Lines
    WHERE
        (CustID, OrderNo, OrderDate) 
    IN 
        (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerNoWork WHERE ContactType = 'C')
    GROUP BY
        CustID, OrderNo, OrderDate
), AvgCustSpend AS (
    SELECT
        CustID, 
        AVG(OrderSum.Amount) AS AvgCustSpendPerOrder
    FROM
        OrderSum
    GROUP BY
        CustID
)
SELECT
    AVG(AvgCustSpendPerOrder) AS AvgCatalogSpend
FROM
    AvgCustSpend
	
-- Revenue per Internet Order (Averaged across orders)
SELECT
    SUM(LineDollar) / COUNT(DISTINCT(CustID, OrderNo, OrderDate))
FROM
    Lines
WHERE
    (CustID, OrderNo, OrderDate) 
IN 
    (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerNoWork WHERE ContactType = 'E');

-- Revenue per Internet Order (Averaged across average customer spend per order)
WITH OrderSum AS (
    SELECT
        CustID,
        OrderNo,
        OrderDate,
        SUM(LineDollar) AS Amount
    FROM
        Lines
    WHERE
        (CustID, OrderNo, OrderDate) 
    IN 
        (SELECT CustID, OrderNo, OrderDate FROM RevenueCustomerNoWork WHERE ContactType = 'E')
    GROUP BY
        CustID, OrderNo, OrderDate
), AvgCustSpend AS (
    SELECT
        CustID, 
        AVG(OrderSum.Amount) AS AvgCustSpendPerOrder
    FROM
        OrderSum
    GROUP BY
        CustID
)
SELECT
    AVG(AvgCustSpendPerOrder) AS AvgEmailSpend
FROM
    AvgCustSpend