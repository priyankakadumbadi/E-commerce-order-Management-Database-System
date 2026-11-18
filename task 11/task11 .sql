USE inventory_db;

-- 1. Customer Order Report
CREATE OR REPLACE VIEW Customer_Order_Report AS
SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID;

SELECT * FROM Customer_Order_Report;


-- 2. Product Sales Report
CREATE OR REPLACE VIEW Product_Sales_Report AS
SELECT
    p.Product_Name,
    SUM(od.Quantity) AS Quantity_Sold,
    SUM(od.Quantity * p.Price) AS Total_Revenue
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name;


-- 3. Payment Status Report
CREATE OR REPLACE VIEW Payment_Status_Report AS
SELECT
    Order_ID,
    Payment_Mode,
    Payment_Status,
    Amount AS Transaction_Amount
FROM Payment;

SELECT * FROM Payment_Status_Report;


-- 4. Update Order Status
DELIMITER //

CREATE PROCEDURE UpdateOrderStatus(
    IN p_OrderID INT,
    IN p_NewStatus VARCHAR(50)
)
BEGIN
    UPDATE Orders
    SET Order_Status = p_NewStatus
    WHERE Order_ID = p_OrderID;
END //

DELIMITER ;

CALL UpdateOrderStatus(1, 'Shipped');


-- 5. Add New Customer Order
DELIMITER //

CREATE PROCEDURE AddNewCustomerOrder(
    IN p_Customer_ID INT,
    IN p_Product_ID INT,
    IN p_Quantity INT
)
BEGIN
    DECLARE v_Price DECIMAL(10,2);
    DECLARE v_Order_ID INT;

    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    SELECT Price INTO v_Price
    FROM Products
    WHERE Product_ID = p_Product_ID;

    IF v_Price IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Product ID';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM Customers
        WHERE Customer_ID = p_Customer_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Customer ID';
    END IF;

    INSERT INTO Orders
    (Customer_ID, Order_Date, Total_Amount, Order_Status)
    VALUES
    (p_Customer_ID, CURDATE(),
     v_Price * p_Quantity, 'Pending');

    SET v_Order_ID = LAST_INSERT_ID();

    INSERT INTO Order_Details
    (Order_ID, Product_ID, Quantity)
    VALUES
    (v_Order_ID, p_Product_ID, p_Quantity);

END //

DELIMITER ;


-- 6. Get Customer Purchase History
DELIMITER //

CREATE PROCEDURE GetCustomerPurchaseHistory(
    IN p_Cust_ID INT
)
BEGIN
    SELECT
        o.Order_ID,
        o.Order_Date,
        p.Product_Name,
        od.Quantity,
        o.Total_Amount AS Purchase_Amount,
        o.Order_Status
    FROM Orders o
    JOIN Order_Details od
    ON o.Order_ID = od.Order_ID
    JOIN Products p
    ON od.Product_ID = p.Product_ID
    WHERE o.Customer_ID = p_Cust_ID;
END //

DELIMITER ;

CALL GetCustomerPurchaseHistory(1);


-- 7. Calculate Total Sales
DELIMITER //

CREATE FUNCTION CalculateTotalSales(
    p_StartDate DATE,
    p_EndDate DATE
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_TotalSales DECIMAL(12,2);

    SELECT COALESCE(SUM(Total_Amount), 0)
    INTO v_TotalSales
    FROM Orders
    WHERE DATE(Order_Date)
    BETWEEN p_StartDate AND p_EndDate;

    RETURN v_TotalSales;
END //

DELIMITER ;

SELECT CalculateTotalSales(
    '2025-01-01', '2025-12-31'
) AS Total_Sales;


-- 8. Calculate Customer Spending
DELIMITER //

CREATE FUNCTION CalculateCustomerSpending(
    p_Cust_ID INT
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_TotalSpending DECIMAL(12,2);

    SELECT COALESCE(SUM(Total_Amount), 0)
    INTO v_TotalSpending
    FROM Orders
    WHERE Customer_ID = p_Cust_ID;

    RETURN v_TotalSpending;
END //

DELIMITER ;

SELECT CalculateCustomerSpending(1) AS Total_Spending;


-- 9. Calculate Product Revenue
DELIMITER //

CREATE FUNCTION CalculateProductRevenue(
    p_Prod_ID INT
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_ProductRevenue DECIMAL(12,2);

    SELECT COALESCE(SUM(od.Quantity * p.Price), 0)
    INTO v_ProductRevenue
    FROM Order_Details od
    JOIN Products p
    ON od.Product_ID = p.Product_ID
    WHERE od.Product_ID = p_Prod_ID;

    RETURN v_ProductRevenue;
END //

DELIMITER ;

SELECT CalculateProductRevenue(1) AS Product_Revenue;


-- 10. Daily Sales Report
SELECT
    DATE(Order_Date) AS Sales_Date,
    COUNT(Order_ID) AS Total_Orders,
    SUM(Total_Amount) AS Daily_Revenue
FROM Orders
GROUP BY DATE(Order_Date)
ORDER BY Sales_Date;


-- 11. Monthly Sales Report
SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    COUNT(Order_ID) AS Total_Orders,
    SUM(Total_Amount) AS Monthly_Revenue
FROM Orders
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Sales_Year, Sales_Month;


-- 12. Low Stock Report
SELECT
    Item_Name AS Product_Name,
    Stock_Quantity,
    Reorder_Level,
    'Low Stock' AS Stock_Status
FROM Inventory
WHERE Stock_Quantity <= Reorder_Level;


-- 13. Add Inventory Stock
DELIMITER //

CREATE PROCEDURE AddInventoryStock(
    IN p_Item_ID INT,
    IN p_Quantity INT
)
BEGIN
    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    UPDATE Inventory
    SET Stock_Quantity = Stock_Quantity + p_Quantity
    WHERE Item_ID = p_Item_ID;
END //

DELIMITER ;


-- 14. Reduce Inventory Stock
DELIMITER //

CREATE PROCEDURE ReduceInventoryStock(
    IN p_Product_ID INT,
    IN p_Quantity INT
)
BEGIN
    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    UPDATE Inventory i
    JOIN Products p
    ON i.Item_Name = p.Product_Name
    SET i.Stock_Quantity = i.Stock_Quantity - p_Quantity
    WHERE p.Product_ID = p_Product_ID
    AND i.Stock_Quantity >= p_Quantity;
END //

DELIMITER ;


-- Final Verification
SELECT * FROM Customer_Order_Report;
SELECT * FROM Product_Sales_Report;
SELECT * FROM Payment_Status_Report;

CALL GetCustomerPurchaseHistory(1);

SELECT CalculateTotalSales(
    '2025-01-01', '2025-12-31'
) AS Total_Sales;

SELECT CalculateCustomerSpending(1) AS Total_Spending;

SELECT CalculateProductRevenue(1) AS Product_Revenue;

SHOW FULL TABLES IN inventory_db
WHERE TABLE_TYPE = 'VIEW';

SHOW PROCEDURE STATUS
WHERE Db = 'inventory_db';

SHOW FUNCTION STATUS
WHERE Db = 'inventory_db';
