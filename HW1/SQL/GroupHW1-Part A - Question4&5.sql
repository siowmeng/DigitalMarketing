-- QUESTION 4 PER CUSTOMER Average Days between orders
WITH internet_differences AS(
	SELECT CustID, OrderMethod, OrderDate,OrderDate - coalesce(lag(OrderDate) OVER(PARTITION BY CustID ORDER BY OrderDate)) AS Diff
	FROM orders
	WHERE OrderMethod = 'I'),
internet_days AS(
	SELECT CustID, OrderMethod, AVG(Diff) AS AverageDays
	FROM internet_differences 
	GROUP BY CustID, OrderMethod
	HAVING AVG(Diff) > 0)
SELECT OrderMethod, AVG(AverageDays)
FROM internet_days
GROUP BY OrderMethod;


WITH catalogue_differences AS(
	SELECT CustID, OrderMethod, OrderDate,OrderDate - coalesce(lag(OrderDate) OVER(PARTITION BY CustID ORDER BY OrderDate)) AS Diff
	FROM orders
	WHERE OrderMethod = 'M' OR OrderMethod = 'P'),
catalogue_days AS(
	SELECT CustID, OrderMethod, AVG(Diff) AS AverageDays
	FROM catalogue_differences 
	GROUP BY CustID, OrderMethod
	HAVING AVG(Diff) > 0)
SELECT OrderMethod, AVG(AverageDays)
FROM catalogue_days
GROUP BY OrderMethod;

-- QUESTION 5 PER CUSTOMER Average Line Item Values of Orders
WITH grouped_orders AS(
	SELECT Lines.CustID, Lines.LineDollar, orders.OrderMethod
	FROM Lines JOIN orders
	ON Lines.OrderNo = orders.OrderNo),
internet_avgs AS(
	SELECT CustID, OrderMethod, AVG(LineDollar) AS AverageOrder
	FROM grouped_orders
	WHERE OrderMethod = 'I'
	GROUP BY CustID, OrderMethod)
SELECT OrderMethod, AVG(AverageOrder)
FROM internet_avgs
GROUP BY OrderMethod;


WITH grouped_orders AS(
	SELECT Lines.CustID, Lines.LineDollar, orders.OrderMethod
	FROM Lines JOIN orders
	ON Lines.OrderNo = orders.OrderNo),
catalogue_avgs AS(
	SELECT CustID, OrderMethod, AVG(LineDollar) AS AverageOrder
	FROM grouped_orders
	WHERE OrderMethod = 'M' OR OrderMethod = 'P'
	GROUP BY CustID, OrderMethod)
SELECT OrderMethod, AVG(AverageOrder)
FROM catalogue_avgs
GROUP BY OrderMethod;