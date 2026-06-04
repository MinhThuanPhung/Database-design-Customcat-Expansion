
-- SCRIPT 2:LIST OF FREQUENTLY USED QUERIES 

USE customcat_database_1;

-- =====================================================
-- A) CONCATENATION
-- =====================================================

-- A1) Seller contact info (commonly used for reporting / customer support lookup)
SELECT 
    SellerID,
    CONCAT(SellerID, ' - ', AccountEmail, ' (', Location, ')') AS SellerContactInfo
FROM Seller;

-- Purpose:
-- Create a human-readable seller contact field for quick viewing in reports/UI without changing table structure.
-- Why this query is used frequently:
-- Staff often need a single “contact string” when searching or exporting seller information.
-- Problems encountered:
-- NULL fields can produce NULL output in some systems, so NULL handling may be needed.


-- =====================================================
-- B) UPDATE 
-- =====================================================

-- B1) Update product pricing (common cases: vendor price updates, campaigns/promotions)

UPDATE Product
SET SellerPrice = 13.5,
    BasePrice   = 13
WHERE SKU = 'SKU01';

-- Purpose:
-- Update SellerPrice and BasePrice for a specific SKU to keep product pricing accurate.
-- Why this query is used frequently:
-- Prices change due to supplier updates, promotions, or pricing strategy adjustments.
-- Problems encountered:
-- If the WHERE clause is incorrect or missing, multiple SKUs may be updated accidentally.
-- Best practice is to SELECT the row first, then UPDATE, and ensure SKU is unique.


-- B2) Increase an employee’s salary (common HR update: increment/bonus adjustments)

UPDATE Employee
SET Salary = Salary + 1000
WHERE EmployeeID = 'EMP01';

-- Purpose:
-- Apply a salary increment to a single employee
-- Why this query is used frequently:
-- Payroll adjustments (annual raises/bonuses) require controlled updates to numeric fields.
-- Problems encountered:
-- Forgetting the WHERE clause updates every employee. Also ensure Salary data type supports decimals if needed.


-- =====================================================
-- C) DELETE 
-- =====================================================

-- C1) Remove staff when they leave company


DELETE FROM Employee
WHERE EmployeeID = 'EMP05';

-- Purpose:
-- Remove an employee who has permanently left the company.

-- Why this query is used frequently:
-- Employee turnover requires regular cleanup of employee records
-- to maintain accurate staffing and payroll data.


-- =====================================================
-- D) SEARCH CONDITIONS
-- =====================================================

-- D1) Orders not yet delivered (most common operational question)

SELECT 
    OrderID, OrderDate, ShippingDate, DeliveryDate, ShippingMethod
FROM OrderInfo
WHERE DeliveryDate IS NULL;

-- Purpose:
-- Identify orders still in progress (not delivered yet).
-- Why this query is used frequently:
-- Operations/support teams monitor open orders daily to manage customer expectations and check if there any delay in production system.
-- Problems encountered:
-- If DeliveryDate is populated late or inconsistently, results may be inaccurate; process discipline is required.


-- D2) Filter orders with long delivery time (DeliveryDate - ShippingDate > 1 day; adjust threshold as needed)
SELECT
    OrderID,
    ShippingDate,
    DeliveryDate,
    DATEDIFF(DeliveryDate, ShippingDate) AS DeliveryDays
FROM OrderInfo
WHERE 
    ShippingDate IS NOT NULL
    AND DeliveryDate IS NOT NULL
    AND DATEDIFF(DeliveryDate, ShippingDate) > 1;

-- Purpose:
-- Detect potentially delayed deliveries by calculating delivery duration in days.
-- Why this query is used frequently:
-- Helps monitor shipping performance and identify late shipments for escalation.
-- Problems encountered:
-- NULL dates must be excluded; otherwise DATEDIFF returns NULL and the filter will not work correctly.


-- D3) Filter orders with long production time + category (ShippingDate - OrderDate > 1 day)
SELECT
    o.OrderID,
    o.OrderDate,
    o.ShippingDate,
    DATEDIFF(o.ShippingDate, o.OrderDate) AS ProductionDays,
    p.Category
FROM OrderInfo o
JOIN OrderItem oi ON o.OrderID = oi.OrderID
JOIN Product p    ON oi.SKU = p.SKU
WHERE
    o.ShippingDate IS NOT NULL
    AND DATEDIFF(o.ShippingDate, o.OrderDate) > 1
ORDER BY ProductionDays DESC;

-- Purpose:
-- Identify orders taking longer to produce and show the product category to spot slow-producing categories.
-- Why this query is used frequently:
-- Production teams use it to detect if there any delay in production and improve workflow by category/product type.
-- Problems encountered:
-- One OrderID can appear multiple times (multiple items/categories per order). If “one row per order” is required,
-- a business rule is needed (e.g., primary item) or categories must be aggregated.


-- =====================================================
-- E) AGGREGATE FUNCTIONS , SUBQUERIES, JOINS
-- =====================================================

-- E1) Total orders and revenue by month across the all branches

SELECT
    DATE_FORMAT(OrderDate, '%Y-%m') AS YearMonth,
    COUNT(OrderID) AS TotalOrders,
    SUM(TotalOrder) AS Revenue
FROM OrderInfo
GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
ORDER BY YearMonth;

-- Purpose:
-- Provide monthly summary of order volume and revenue across all branch
-- Why this query is used frequently:
-- Monthly performance reporting is a standard management requirement. stakeholder need to see the total revenue of the company


-- E2) Revenue and order count per seller (seller performance overview)
SELECT 
    s.SellerID,
    s.Type AS SellerType,
    DATE_FORMAT(o.OrderDate, '%Y-%m') AS YearMonth,
    COUNT(o.OrderID)        AS NumberOfOrders,
    SUM(o.TotalOrder)       AS TotalRevenue,
    ROUND(AVG(o.TotalOrder), 2) AS AverageOrderValue
FROM OrderInfo o
JOIN Seller s 
    ON o.SellerID = s.SellerID
GROUP BY 
    s.SellerID,
    s.Type,
    DATE_FORMAT(o.OrderDate, '%Y-%m')
ORDER BY 
    YearMonth,
    TotalRevenue DESC;

-- Purpose:
-- Summarise seller performance using COUNT, SUM, and AVG.
-- Why this query is used frequently:
-- Helps evaluate seller contribution and prioritise account management support.
-- Problems encountered:
-- Using OrderInfo.TotalOrder may differ from line-item revenue if compnay plan to use shipping/discounts (exist)



-- E3) Quantity sold by SKU (best-selling products)
SELECT 
    oi.SKU, 
    SUM(oi.quantity) AS TotalQuantityOrdered
FROM OrderItem oi
GROUP BY oi.SKU
ORDER BY TotalQuantityOrdered DESC;

-- Purpose:
-- Rank SKUs by total quantity sold.
-- Why this query is used frequently:
-- Supports demand planning, inventory replenishment, and product strategy decisions.
-- Problems encountered:
-- If cancelled items exist, status filters are needed to avoid overstating demand.


-- E4) Total stock per SKU per branch (inventory visibility by location)
SELECT 
    SKU,
    BranchID,
    SUM(Quantity) AS TotalStock
FROM Inventory
GROUP BY 
    SKU,
    BranchID
ORDER BY 
    SKU,
    BranchID;

-- Purpose:
-- Calculate stock levels for each SKU at each branch.
-- Why this query is used frequently:
-- Operations teams track stock per location to reduce stockouts and overstock. and ordering more for item will be out of stock soon
-- Problems encountered:
-- If Inventory includes reserved/damaged stock, extra fields or filters may be required for available stock.


-- E5) Branch revenue and total orders by month (operational performance )

SELECT
    b.BranchID,
    b.Name AS BranchName,
    DATE_FORMAT(o.OrderDate, '%Y-%m') AS YearMonth,
    COUNT(*) AS TotalOrders,
    SUM(o.TotalOrder) AS Revenue
FROM OrderInfo o
JOIN OrderItem oi ON o.OrderID = oi.OrderID
JOIN Machine m    ON oi.MachineID = m.MachineID
JOIN Branch b     ON m.BranchID = b.BranchID
WHERE oi.LineItemID = (   -- because each order have multiple item , if we join orderInfo with orderitem, which cause duplicate orderID, So we need to get only 1 line of orderitem
    SELECT MIN(oi2.LineItemID)
    FROM OrderItem oi2
    WHERE oi2.OrderID = o.OrderID
)
GROUP BY
    b.BranchID, b.Name, DATE_FORMAT(o.OrderDate, '%Y-%m')
ORDER BY
    YearMonth, Revenue DESC;
    


-- Purpose:
-- Measure branch performance by month based on where items were produced (Machine → Branch).
-- Why this query is used frequently:
-- Supports capacity planning and branch-level operational reporting. then evaluate effectivities the how each branch work 


-- E6) Revenue by employee + KPI comparison (%) (SUBQUERY; performance monitoring for sales reps)
SELECT
    e.EmployeeID,
    e.FullName,
    sa.KPI AS KPI_Target,
    emp_rev.ActualRevenue,
    ROUND((emp_rev.ActualRevenue / sa.KPI) * 100, 2) AS KPI_Completion_Percentage
FROM Employee e

JOIN (
    SELECT 
        s.RepID AS EmployeeID,
        SUM(o.TotalOrder) AS ActualRevenue
    FROM Seller s
    JOIN OrderInfo o ON s.SellerID = o.SellerID
    GROUP BY s.RepID
) emp_rev
    ON e.EmployeeID = emp_rev.EmployeeID

JOIN Sales sa ON e.EmployeeID = sa.EmployeeID

ORDER BY KPI_Completion_Percentage DESC;


-- Purpose:
-- Calculate revenue generated per employee (sales rep) and compare against KPI using a percentage.
-- Why this query is used frequently:
-- Managers monitor performance vs targets and identify top/low performers.
-- Problems encountered:
-- KPI must be non-zero; otherwise Revenue/KPI may error or return NULL. Data validation is required.
-- Also, employees without assigned sellers will not appear unless LEFT JOIN logic is used.


-- E7) Average ticket resolution time by support staff
SELECT
    e.EmployeeID,
    e.FullName,
    ROUND(AVG(DATEDIFF(oi.ClosedDate, oi.TicketDate)), 2) AS Avg_Response_Days
FROM OrderIssue oi
JOIN Employee e ON oi.CSID = e.EmployeeID
WHERE 
    oi.ClosedDate IS NOT NULL
GROUP BY
    e.EmployeeID,
    e.FullName
ORDER BY
    Avg_Response_Days;

-- Purpose:
-- Measure average ticket resolution time per support employee (ClosedDate - TicketDate).
-- Why this query is used frequently:
-- Helps monitor SLA performance and workload effectiveness in customer support then improve customer satisfaction
-- Problems encountered:
-- Open tickets are excluded (ClosedDate is NULL). Extremely long tickets can skew averages,
-- so in practice, median/outlier analysis may be used.
