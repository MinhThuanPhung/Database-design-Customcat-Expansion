

-- SCRIPT 1: CREATE DATABASE + TABLES + DATA


-- 1. Create database 
DROP DATABASE IF EXISTS customcat_database_1;
CREATE DATABASE customcat_database_1;

-- =====================================================
-- 2. CREATE TABLES
-- =====================================================

USE customcat_database_1;

-- Branch
CREATE TABLE Branch (
  BranchID      CHAR(5)      NOT NULL,
  Name          VARCHAR(30)  NOT NULL,
  Location      VARCHAR(120),
  FoundationDate DATE,
  PRIMARY KEY (BranchID)
);

-- Tier
CREATE TABLE Tier (
  TierID    CHAR(5)      NOT NULL,
  TierName  VARCHAR(30)  NOT NULL,
  Chargeback CHAR(1),
  PRIMARY KEY (TierID)
);

-- Supplier
CREATE TABLE Supplier (
  SupplierID CHAR(5)      NOT NULL,
  Name       VARCHAR(30)  NOT NULL,
  Location   VARCHAR(120),
  Email      VARCHAR(80),
  JoiningDate DATE,
  PRIMARY KEY (SupplierID)
);

-- Machine
CREATE TABLE Machine (
  MachineID CHAR(5)     NOT NULL,
  Name      VARCHAR(30) NOT NULL,
  Decoration VARCHAR(30),
  Status    VARCHAR(20),
  BranchID  CHAR(5)     NOT NULL,
  BuyDate   DATE,
  PRIMARY KEY (MachineID),
  FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
  ON UPDATE CASCADE ON DELETE CASCADE
);

-- Employee 
CREATE TABLE Employee (
  EmployeeID CHAR(5)      NOT NULL,
  FullName   VARCHAR(30)  NOT NULL,
  DOB        DATE,
  Gender     CHAR(1),
  HireDate   DATE         NOT NULL,
  Salary     DECIMAL(10,2),
  Email      VARCHAR(80),
  BranchID   CHAR(5)      NOT NULL,
  PRIMARY KEY (EmployeeID),
  FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
  ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE OfficeStaff (
  EmployeeID CHAR(5)      NOT NULL,
  Department VARCHAR(50),
  JobTitle   VARCHAR(50),
  PRIMARY KEY (EmployeeID),
  FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
  ON UPDATE CASCADE ON DELETE CASCADE
);
-- ProductionStaff
CREATE TABLE ProductionStaff (
  EmployeeID      CHAR(5)      NOT NULL,
  Shift           VARCHAR(20),
  MachineAssigned CHAR(5),
  SkillLevel      VARCHAR(20),
  PRIMARY KEY (EmployeeID),
  FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
  ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (MachineAssigned) REFERENCES Machine(MachineID)
  ON UPDATE CASCADE
  ON DELETE CASCADE
);

-- InventoryStaff (subtype)
CREATE TABLE InventoryStaff (
  EmployeeID CHAR(5)      NOT NULL,
  Shift      VARCHAR(20),
  Location   VARCHAR(60),
  PRIMARY KEY (EmployeeID),
  FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
  ON UPDATE CASCADE
  ON DELETE CASCADE
);

-- Sales
CREATE TABLE Sales (
  EmployeeID CHAR(5)       NOT NULL,
  Level      VARCHAR(20),
  KPI        DECIMAL(10,2),
  Commission DECIMAL(10,2),
  PRIMARY KEY (EmployeeID),
  FOREIGN KEY (EmployeeID) REFERENCES OfficeStaff(EmployeeID)
  ON UPDATE CASCADE
  ON DELETE CASCADE
);

-- Support 
CREATE TABLE Support (
  EmployeeID  CHAR(5)      NOT NULL,
  SLAProfile  VARCHAR(50),
  Channel     VARCHAR(30),
  PRIMARY KEY (EmployeeID),
  FOREIGN KEY (EmployeeID) REFERENCES OfficeStaff(EmployeeID)
  ON UPDATE CASCADE
  ON DELETE CASCADE
);

-- Seller
CREATE TABLE Seller (
  SellerID     CHAR(5)      NOT NULL,
  Type         VARCHAR(20)  NOT NULL,  -- 'Individual' or 'Company'
  Location     VARCHAR(120),
  Phone        VARCHAR(20),
  AccountEmail VARCHAR(80)  NOT NULL,
  JoiningDate  DATE,
  RepID        CHAR(5),
  PRIMARY KEY (SellerID),
  FOREIGN KEY (RepID) REFERENCES Sales(EmployeeID)
  ON UPDATE CASCADE ON DELETE SET NULL
);

-- CompanySeller
CREATE TABLE CompanySeller (
  SellerID     CHAR(5)      NOT NULL,
  CompanyName  VARCHAR(100),
  OwnerEmail   VARCHAR(80),
  OwnerName    VARCHAR(30),
  SupportEmail VARCHAR(80),
  Size         VARCHAR(20),
  Tier         CHAR(5),
  TierSetDate  DATE,
  PRIMARY KEY (SellerID),
  FOREIGN KEY (SellerID) REFERENCES Seller(SellerID),
  FOREIGN KEY (Tier)     REFERENCES Tier(TierID)
);

-- IndividualSeller
CREATE TABLE IndividualSeller (
  SellerID           CHAR(5)      NOT NULL,
  IntegrationPlatform VARCHAR(50),
  Name               VARCHAR(30),
  Gender             CHAR(1),
  PRIMARY KEY (SellerID),
  FOREIGN KEY (SellerID) REFERENCES Seller(SellerID)
);


-- Product
CREATE TABLE Product (
  SKU         CHAR(5)      NOT NULL,
  ProductID   CHAR(5)      NOT NULL,
  ProductName VARCHAR(100) NOT NULL,
  Decoration  VARCHAR(30),
  Size        VARCHAR(10),
  Color       VARCHAR(20),
  Category    VARCHAR(100),
  SupplierID  CHAR(5),
  BasePrice   DECIMAL(10,2) NOT NULL,
  SellerPrice DECIMAL(10,2),
  MachineID   CHAR(5),
  PRIMARY KEY (SKU),
  FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
  FOREIGN KEY (MachineID) REFERENCES Machine(MachineID)
  ON UPDATE CASCADE 
);

-- Inventory
CREATE TABLE Inventory (
  SKU        CHAR(5)      NOT NULL,
  BranchID   CHAR(5)      NOT NULL,
  Location   VARCHAR(60),
  Quantity   INT          NOT NULL,
  SupplierID CHAR(5),
  PRIMARY KEY (SKU, BranchID),
  FOREIGN KEY (SKU) REFERENCES Product(SKU),
  FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
  FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
  ON UPDATE CASCADE ON DELETE RESTRICT
);


-- Customer 
CREATE TABLE Customer (
  CustomerID   CHAR(6)      NOT NULL,
  CustomerName VARCHAR(50)  NOT NULL,
  AddressLine1 VARCHAR(120) NOT NULL,
  AddressLine2 VARCHAR(120),
  City         VARCHAR(60)  NOT NULL,
  State        VARCHAR(60),
  Zipcode      VARCHAR(10)  NOT NULL,
  CountryID    CHAR(2)      NOT NULL,
  PRIMARY KEY (CustomerID)
);

-- ShippingPartner
CREATE TABLE ShippingPartner (
  PartnerID CHAR(5)      NOT NULL,
  Name      VARCHAR(30)  NOT NULL,
  RepName   VARCHAR(30)  NOT NULL,
  PRIMARY KEY (PartnerID)
);

-- OrderInfo 
CREATE TABLE OrderInfo (
  OrderID          CHAR(11)     NOT NULL,
  TransactionID    VARCHAR(50)  NOT NULL,
  OrderDate        DATE         NOT NULL,
  ShippingDate     DATE,
  DeliveryDate     DATE,
  PaymentMethod    VARCHAR(20)  NOT NULL,
  TotalOrder       DECIMAL(10,2) NOT NULL,
  ShippingCost     DECIMAL(10,2) NOT NULL,
  SellerID         CHAR(5)      NOT NULL,
  ShippingPartnerID CHAR(5)     NOT NULL,
  CustomerID       CHAR(6)      NOT NULL,
  ShippingMethod   VARCHAR(30),
  PRIMARY KEY (OrderID),
  FOREIGN KEY (SellerID)         REFERENCES Seller(SellerID),
  FOREIGN KEY (ShippingPartnerID) REFERENCES ShippingPartner(PartnerID),
  FOREIGN KEY (CustomerID)       REFERENCES Customer(CustomerID)
  ON UPDATE CASCADE ON DELETE RESTRICT
);

-- OrderItem
CREATE TABLE OrderItem (
  OrderID   CHAR(11)     NOT NULL,
  LineItemID CHAR(5)     NOT NULL,
  SKU       CHAR(5)      NOT NULL,
  quantity  INT          NOT NULL,
  machineID CHAR(5),
  status    VARCHAR(20),
  PRIMARY KEY (OrderID, LineItemID),
  FOREIGN KEY (OrderID)  REFERENCES OrderInfo(OrderID),
  FOREIGN KEY (SKU)      REFERENCES Product(SKU),
  FOREIGN KEY (machineID) REFERENCES Machine(MachineID)
  ON UPDATE CASCADE ON DELETE RESTRICT
);

-- OrderIssue
CREATE TABLE OrderIssue (
  TicketID   CHAR(5)      NOT NULL,
  TicketDate DATE         NOT NULL,
  ClosedDate DATE,
  OrderID    CHAR(11)     NOT NULL,
  LineItemID CHAR(5),
  IssueType  VARCHAR(20)  NOT NULL,
  IssueName  VARCHAR(30)  NOT NULL,
  Status     VARCHAR(20)  NOT NULL,
  CSID       CHAR(5)      NOT NULL,
  Solution   VARCHAR(100),
  PRIMARY KEY (TicketID),
  FOREIGN KEY (OrderID) REFERENCES OrderInfo(OrderID),
  FOREIGN KEY (CSID)   REFERENCES Support(EmployeeID),
  FOREIGN KEY (OrderID, LineItemID) REFERENCES OrderItem(OrderID, LineItemID)
  ON UPDATE CASCADE ON DELETE RESTRICT
  
);

-- RefundIssue
CREATE TABLE RefundIssue (
  TicketID    CHAR(5)      NOT NULL,
  RefundAmount  DECIMAL(10,2),
  RefundMethod  VARCHAR(20),
  PRIMARY KEY (TicketID),
  FOREIGN KEY (TicketID) REFERENCES OrderIssue(TicketID)
);

-- ReplacementIssue
CREATE TABLE ReplacementIssue (
  TicketID   CHAR(5)      NOT NULL,
  NewOrderID  CHAR(11),
  ReplacementShippingDate  DATE,
  PRIMARY KEY (TicketID),
  FOREIGN KEY (TicketID) REFERENCES OrderIssue(TicketID)
);


-- ==========================================
-- INSERT DATA FOR ALL TABLES
-- ==========================================



INSERT INTO Branch (BranchID, Name, Location, FoundationDate) VALUES
  ('BR001', 'Detroit HQ',          'Detroit, MI',       '2019-01-01'),
  ('BR002', 'Houston Branch',      'Houston, TX',       '2020-05-10'),
  ('BR003', 'Los Angeles Branch',  'Los Angeles, CA',   '2021-03-15');
  
  INSERT INTO Tier (TierID, TierName, Chargeback) VALUES
  ('T001', 'Silver', 'Y'),
  ('T002', 'Gold', 'Y'),
  ('T003', 'Platinum', 'N'),
  ('T004', 'Diamond', 'N'),
  ('T005', 'Starter', 'Y'),
  ('T006', 'Premium', 'Y'),
  ('T007', 'Enterprise', 'N'),
  ('T008', 'Trial', 'Y');
  
  INSERT INTO Supplier (SupplierID, Name, Location, Email, JoiningDate) VALUES
  ('SUP01', 'BlankBase Co', 'Detroit, US', 'contact@blankbase.com', '2022-01-01'),
  ('SUP02', 'TextileSource', 'Houston, US', 'sales@textilesource.com', '2022-03-15'),
  ('SUP03', 'MugWorld', 'Dallas, US', 'info@mugworld.com', '2022-05-10'),
  ('SUP04', 'CanvasPro', 'Los Angeles, US', 'support@canvaspro.com', '2022-07-20'),
  ('SUP05', 'GlobalFabrics', 'Berlin, DE', 'service@globalfabrics.de', '2022-09-01'),
  ('SUP06', 'PrintBlanks Ltd', 'London, UK', 'hello@printblanks.co.uk', '2023-01-15'),
  ('SUP07', 'AsiaTextiles', 'Hanoi, VN', 'sales@asiatextiles.vn', '2023-03-01'),
  ('SUP08', 'PremiumMugs', 'New York, US', 'contact@premiummugs.com', '2023-04-10');

INSERT INTO Machine (MachineID, Name, Decoration, Status, BranchID, BuyDate) VALUES
  ('MAC01', 'DTG Printer 1', 'Digisoft', 'Active', 'BR001', '2021-01-01'),
  ('MAC02', 'Sublimation 1', 'Sublimation', 'Maintenance', 'BR002', '2020-06-15'),
  ('MAC03', 'DTG Printer 2', 'Digisoft', 'Active', 'BR003', '2022-03-10'),
  ('MAC04', 'Heat Press', 'Sublimation', 'Active', 'BR003', '2023-02-20'),
  ('MAC05', 'UV Printer', 'Digisoft', 'Inactive', 'BR001', '2019-11-01'),
  ('MAC06', 'DTG Printer 3', 'Digisoft', 'Active', 'BR001', '2023-01-05'),
  ('MAC07', 'Sublimation 2', 'Sublimation', 'Active', 'BR002', '2023-02-18'),
  ('MAC08', 'Heat Press 2', 'Sublimation', 'Maintenance', 'BR001', '2023-03-22');

INSERT INTO Employee (EmployeeID, FullName, DOB, Gender, HireDate, Salary, Email, BranchID) VALUES
  ('EMP01', 'John Carter',    '1990-01-10', 'M', '2020-01-01', 32000.00, 'john.carter@customcat.com',    'BR001'),
  ('EMP02', 'Linda Green',    '1992-02-20', 'F', '2020-03-15', 34000.00, 'linda.green@customcat.com',    'BR001'),
  ('EMP03', 'Michael Scott',  '1985-05-05', 'M', '2019-06-01', 45000.00, 'michael.scott@customcat.com',  'BR002'),
  ('EMP04', 'Pam Beesly',     '1988-08-08', 'F', '2020-09-01', 38000.00, 'pam.beesly@customcat.com',     'BR002'),
  ('EMP05', 'Jim Halpert',    '1987-09-09', 'M', '2021-01-10', 39000.00, 'jim.halpert@customcat.com',    'BR003'),
  ('EMP06', 'Angela Martin',  '1986-03-12', 'F', '2021-05-20', 36000.00, 'angela.martin@customcat.com',  'BR003'),
  ('EMP07', 'Kevin Malone',   '1984-07-01', 'M', '2022-02-01', 35000.00, 'kevin.malone@customcat.com',   'BR001'),
  ('EMP08', 'Kelly Kapoor',   '1991-11-11', 'F', '2022-06-10', 33000.00, 'kelly.kapoor@customcat.com',   'BR001'),
  ('EMP09', 'Oscar Martinez', '1983-04-25', 'M', '2020-04-01', 37000.00, 'oscar.martinez@customcat.com', 'BR002'),
  ('EMP10','Toby Flenderson', '1979-09-15', 'M', '2019-10-01', 40000.00, 'toby.flenderson@customcat.com','BR002'),
  ('EMP11','Stanley Hudson',  '1975-02-02', 'M', '2018-03-01', 41000.00, 'stanley.hudson@customcat.com', 'BR003'),
  ('EMP12','Phyllis Vance',   '1978-12-20', 'F', '2018-05-15', 40500.00, 'phyllis.vance@customcat.com',  'BR003');

  INSERT INTO ProductionStaff (EmployeeID, Shift, MachineAssigned, SkillLevel) VALUES
  ('EMP01', 'Morning', 'MAC01', 'Senior'),
  ('EMP02', 'Evening', 'MAC02', 'Junior'),
  ('EMP03', 'Night',   'MAC03', 'Fresher'),
  ('EMP05', 'Morning', 'MAC04', 'Junior');


INSERT INTO InventoryStaff (EmployeeID, Shift, Location) VALUES
  ('EMP04', 'Morning', 'Zone A'),
  ('EMP06', 'Evening', 'Zone B'),
  ('EMP11', 'Night',   'Zone C');

  
  INSERT INTO OfficeStaff (EmployeeID, Department, JobTitle) VALUES
  ('EMP07', 'Sales',       'Account Manager'),
  ('EMP08', 'Sales',       'Sales Representative'),
  ('EMP09', 'Support',     'Support Specialist'),
  ('EMP10','Support',      'Support Officer'),
  ('EMP12','Administration','Office Administrator');

INSERT INTO Sales (EmployeeID, Level, KPI, Commission) VALUES
  ('EMP07', 'Senior',  95.50, 5000.00),
  ('EMP08', 'Junior',  88.00, 2500.50);
  
INSERT INTO Support (EmployeeID, SLAProfile, Channel) VALUES
  ('EMP09', '24h Response', 'Orders department'),
  ('EMP10','48h Response', 'Support department');
  
INSERT INTO Seller (SellerID, Type, Location, Phone, AccountEmail, JoiningDate, RepID) VALUES
  ('SEL01', 'Company', 'United States', '+13135550001', 'seller1@shop.com', '2023-01-01', 'EMP07'),
  ('SEL02', 'Individual', 'United States', '+13135550002', 'seller2@shop.com', '2023-02-15', 'EMP07'),
  ('SEL03', 'Company', 'Canada', '+14165550003', 'seller3@shop.com', '2023-03-10', 'EMP07'),
  ('SEL04', 'Individual', 'United Kingdom', '+441234555004', 'seller4@shop.com', '2023-04-20', 'EMP07'),
  ('SEL05', 'Company', 'Germany', '+4915123450005', 'seller5@shop.com', '2023-05-05', 'EMP08'),
  ('SEL06', 'Individual', 'France', '+33123456789', 'seller6@shop.com', '2023-06-01', 'EMP08'),
  ('SEL07', 'Company', 'Vietnam', '+84241234567', 'seller7@shop.com', '2023-06-20', 'EMP07'),
  ('SEL08', 'Individual', 'Ireland', '+3531234567', 'seller8@shop.com', '2023-07-05', 'EMP08');

INSERT INTO CompanySeller (SellerID, CompanyName, OwnerEmail, OwnerName, SupportEmail, Size, Tier, TierSetDate) VALUES
  ('SEL01', 'Alpha Merch LLC', 'owner1@alpha.com', 'Alice Smith', 'support@alpha.com', '50', 'T001', '2023-02-01'),
  ('SEL03', 'Beta Print Inc.', 'owner2@beta.com', 'Bob Jones', 'support@beta.com', '30', 'T002', '2023-03-15'),
  ('SEL05', 'Gamma Stores GmbH', 'owner3@gamma.de', 'Clara Meier', 'support@gamma.de', '80', 'T003', '2023-06-01'),
  ('SEL07', 'Epsilon Group', 'owner4@eps.com', 'Emma Lee', 'support@eps.com', '100', 'T004', '2023-08-01');

INSERT INTO IndividualSeller (SellerID, IntegrationPlatform, Name, Gender) VALUES
  ('SEL02', 'Etsy', 'EtsyShopMinh', 'F'),
  ('SEL04', 'Shopify', 'ShopifyPrints', 'F'),
  ('SEL06', 'Amazon', 'PrimeTees', 'M'),
  ('SEL08', 'Manual', 'LocalStore', 'F');



INSERT INTO Product (SKU, ProductID, ProductName, Decoration, Size, Color, Category, SupplierID, BasePrice, SellerPrice, MachineID) VALUES
  ('SKU01', 'P001', 'Classic T-Shirt', 'Digisoft', 'M', 'Black', 'Apparel', 'SUP01', 8.50, 12.99, 'MAC01'),
  ('SKU02', 'P002', 'Ceramic Mug', 'Sublimation', 'One', 'White', 'Drinkware', 'SUP03', 4.00, 7.99, 'MAC02'),
  ('SKU03', 'P003', 'Hoodie', 'Digisoft', 'L', 'Grey', 'Apparel', 'SUP02', 15.00, 22.99, 'MAC03'),
  ('SKU04', 'P004', 'Canvas Print', 'Sublimation', '30x40', 'Multi', 'Home Decor', 'SUP04', 10.00, 17.99, 'MAC04'),
  ('SKU05', 'P005', 'Blanket', 'Digisoft', 'XL', 'Blue', 'Home Decor', 'SUP05', 18.00, 25.50, 'MAC05'),
  ('SKU06', 'P006', 'Travel Mug', 'Sublimation', 'One', 'Silver', 'Drinkware', 'SUP08', 6.50, 11.90, 'MAC02'),
  ('SKU07', 'P007', 'Sweatshirt', 'Digisoft', 'M', 'Navy', 'Apparel', 'SUP02', 14.00, 21.50, 'MAC03'),
  ('SKU08', 'P008', 'Phone Case', 'Sublimation', 'One', 'Black', 'Accessories', 'SUP06', 3.00, 6.99, 'MAC07');

INSERT INTO Inventory (SKU, BranchID, Location, Quantity, SupplierID) VALUES
  ('SKU01', 'BR001', 'Zone A', 100, 'SUP01'),
  ('SKU02', 'BR001', 'Zone B', 80, 'SUP03'),
  ('SKU03', 'BR001', 'Zone A', 60, 'SUP02'),
  ('SKU03', 'BR003', 'Zone C', 40, 'SUP04'),
  ('SKU05', 'BR002', 'Zone D', 120, 'SUP05'),
  ('SKU04', 'BR002', 'Zone E', 90, 'SUP08'),
  ('SKU05', 'BR003', 'Zone F', 70, 'SUP02'),
  ('SKU05', 'BR001', 'Zone G', 50, 'SUP06');
  


INSERT INTO Customer (CustomerID, CustomerName, AddressLine1, AddressLine2, City, State, Zipcode, CountryID) VALUES
  ('CUST01', 'Anna Johnson', '123 Main St', NULL, 'Detroit', 'MI', '48201', 'US'),
  ('CUST02', 'Brian Lee', '45 River Rd', 'Apt 2', 'Houston', 'TX', '77001', 'US'),
  ('CUST03', 'Carlos Gomez', '78 Lake Ave', NULL, 'Los Angeles', 'CA', '90001', 'US'),
  ('CUST04', 'Diana Smith', '90 Ocean Dr', NULL, 'New York', 'NY', '10001', 'US'),
  ('CUST05', 'Eric Brown', '12 Green St', NULL, 'Dallas', 'TX', '75001', 'US'),
  ('CUST06', 'Fiona White', '56 Park Blvd', NULL, 'Chicago', 'IL', '60601', 'US'),
  ('CUST07', 'George King', '34 Oak St', NULL, 'Miami', 'FL', '33101', 'US'),
  ('CUST08', 'Hannah Tran', '89 Pine Rd', NULL, 'Seattle', 'WA', '98101', 'US');

INSERT INTO ShippingPartner (PartnerID, Name, RepName) VALUES
  ('P0001', 'UPS', 'Karen Hill'),
  ('P0002', 'FedEx', 'Mike Ross'),
  ('P0003', 'DHL', 'Rachel Zane'),
  ('P0004', 'USPS', 'Harvey Specter'),
  ('P0005', 'LocalExpress', 'Donna Paulsen'),
  ('P0006', 'FastShip', 'Louis Litt'),
  ('P0007', 'GlobalShip', 'Jessica Pearson'),
  ('P0008', 'VNPost', 'Minh Nguyen');


INSERT INTO OrderInfo 
(OrderID, TransactionID, OrderDate, ShippingDate, DeliveryDate, PaymentMethod, TotalOrder, ShippingCost, SellerID, ShippingPartnerID, CustomerID, ShippingMethod) VALUES
  ('ORD00000001', 'TXN001', '2025-01-01', '2025-01-03', '2025-01-05', 'PayPal',   25.50, 5.00, 'SEL01', 'P0001', 'CUST01', 'Economy'),
  ('ORD00000002', 'TXN002', '2025-01-02', '2025-01-04', '2025-01-06', 'Card',     40.00, 7.00, 'SEL02', 'P0002', 'CUST02', '2-Day'),
  ('ORD00000003', 'TXN003', '2025-01-03', NULL,         NULL,         'Payoneer', 60.75, 10.00,'SEL03', 'P0003', 'CUST03', 'Ground'),
  ('ORD00000004', 'TXN004', '2025-01-04', '2025-01-06', '2025-01-08', 'Card',     30.00, 5.50, 'SEL04', 'P0004', 'CUST04', 'International'),
  ('ORD00000005', 'TXN005', '2025-01-05', NULL,         NULL,         'PayPal',   45.25, 6.50, 'SEL05', 'P0005', 'CUST05', 'Economy');


INSERT INTO OrderItem (OrderID, LineItemID, SKU, quantity, machineID, status) VALUES
  ('ORD00000001', 'L001', 'SKU01', 1, 'MAC01', 'Shipped'),
  ('ORD00000001', 'L002', 'SKU05', 2, 'MAC05', 'Shipped'),
  ('ORD00000001', 'L003', 'SKU08', 1, 'MAC01', 'Shipped'),

  ('ORD00000002', 'L004', 'SKU02', 1, 'MAC02', 'Shipped'),
  ('ORD00000002', 'L005', 'SKU03', 2, 'MAC07', 'Shipped'),

  ('ORD00000003', 'L006', 'SKU04', 1, 'MAC03', 'In production'),
  ('ORD00000003', 'L007', 'SKU06', 1, 'MAC04', 'Printed'),
  ('ORD00000003', 'L008', 'SKU01', 3, 'MAC03', 'Printed'),

  ('ORD00000004', 'L009', 'SKU02', 1, 'MAC06', 'Shipped'),

  ('ORD00000005', 'L011', 'SKU03', 1, 'MAC02', 'In production'),
  ('ORD00000005', 'L012', 'SKU06', 2, 'MAC07', 'Printed');


INSERT INTO OrderIssue (TicketID, TicketDate, ClosedDate, OrderID, LineItemID, IssueType, IssueName, Status, CSID, Solution) VALUES
  ('T0001', '2025-01-10', '2025-01-12', 'ORD00000001', 'L001', 'Refund', 'Misprint', 'Closed', 'EMP09', 'Refund'),
  ('T0002', '2025-01-11', NULL,         'ORD00000002', 'L004', 'Replacement', 'Damaged in transit', 'Open', 'EMP09', 'Replacement'),
  ('T0003', '2025-01-12', '2025-01-14', 'ORD00000005', 'L011', 'Other',  'Late delivery', 'Closed', 'EMP10', 'Other'),
  ('T0004', '2025-01-13', NULL,         'ORD00000004', 'L009', 'Refund', 'Wrong size', 'On hold', 'EMP09', 'Refund'),
  ('T0005', '2025-01-14', NULL,         'ORD00000002', 'L005', 'Replacement',  'Color issue', 'Open', 'EMP09', 'Replacement'),
  ('T0006', '2025-01-15', '2025-01-17', 'ORD00000001', 'L002', 'Refund', 'Damaged print', 'Closed', 'EMP09', 'Refund'),
  ('T0007', '2025-01-16', NULL,         'ORD00000003', 'L006', 'Other', 'Tracking problem', 'Open', 'EMP10', 'Other'),
  ('T0008', '2025-01-17', NULL,         'ORD00000004', 'L009', 'Replacement',  'Lost package', 'Open', 'EMP10', 'Replacement');



INSERT INTO RefundIssue (TicketID, RefundAmount, RefundMethod) VALUES
  ('T0001', 25.50, 'PayPal'),
  ('T0004', 10.00, 'Card'),
  ('T0006', 12.50, 'PayPal');

INSERT INTO ReplacementIssue (TicketID, NewOrderID, ReplacementShippingDate) VALUES
  ('T0002', 'ORD00000009', '2025-01-16'),
  ('T0005', 'ORD00000010', '2025-01-18'),
  ('T0008', 'ORD00000011', '2025-01-20');

 