# Database-design-Customcat-Expansion
CustomCat's rapid expansion and growing customer base exposed inefficiencies caused by fragmented databases, manual spreadsheet-based data management, and poor order tracking. Therefore, the company requires an integrated database system to centralize data, improve operational efficiency, enhance order visibility, and support future growth.

# CustomCat Database Design Project

## Project Overview

CustomCat is a print-on-demand company established in Detroit, USA, in 2019. The company enables online sellers on platforms such as Shopify, Etsy, and Amazon to create and sell customized products including apparel, mugs, blankets, posters, and canvas prints. CustomCat manages production, fulfillment, and delivery on behalf of sellers.

As the company expanded across multiple branches, operational challenges emerged due to fragmented data storage, manual spreadsheet management, and inefficient order tracking processes. This project proposes a centralized relational database system to improve operational efficiency, data consistency, and reporting capabilities.

---

## Business Problems

### Lack of Data Integration

Different departments maintained separate data files, making it difficult to track order status, production activities, and customer issues.

### Inefficient Issue Management

Customer complaints and order issues were managed through emails without a centralized tracking system, resulting in poor visibility and delayed resolution.

### Limited Reporting Capability

Management could not easily generate operational reports such as issue trends, branch performance, refund statistics, or employee productivity metrics.

---

## Database Objectives

The proposed database system aims to:

- Centralize business data across departments
- Improve order and issue management
- Track inventory across branches
- Manage suppliers and shipping partners
- Support reporting and business analytics

---

# Part A: Conceptual Data Model

## Main Entities

The database consists of the following core entities:

- Seller
- OrderInfo
- Product
- Branch
- Employee
- Machine
- Inventory
- Supplier
- ShippingPartner
- OrderIssue
- Tier

These entities support CustomCat's key business processes including order fulfillment, inventory management, production operations, and customer support.

---

## Enhanced ER Modelling

### Seller Specialization

Seller is specialized into:

- IndividualSeller
- CompanySeller

This distinction allows the system to store seller-specific attributes while avoiding redundancy.

### Employee Specialization

Employee is specialized into:

- ProductionStaff
- InventoryStaff
- OfficeStaff

OfficeStaff is further divided into:

- SalesStaff
- SupportStaff

### OrderIssue Specialization

OrderIssue is specialized into:

- RefundIssue
- ReplacementIssue

This enables different issue types to share common attributes while maintaining issue-specific information.

---

## Key Relationships

| Relationship | Cardinality |
|-------------|------------|
| Seller - OrderInfo | 1:M |
| Branch - Employee | 1:M |
| Branch - Machine | 1:M |
| ShippingPartner - OrderInfo | 1:M |
| OrderInfo - OrderIssue | 1:M |
| SalesStaff - Seller | 1:M |
| SupportStaff - OrderIssue | 1:M |
| Product - Supplier | M:M |
| Product - OrderInfo | M:M |

---

## Business Rules

- Each seller must belong to either IndividualSeller or CompanySeller.
- Each order must be associated with one seller.
- Each order is processed by one branch.
- Each order issue is assigned to one support employee.
- Each company seller belongs to one tier.
- Every employee belongs to exactly one employee subtype.

---

# Part B: Physical Data Model

## Main Tables

### Seller

- SellerID (PK)
- Type
- Location
- Phone
- AccountEmail
- JoiningDate
- RepID (FK)

### Product

- SKU (PK)
- ProductName
- Category
- BasePrice
- SellerPrice
- SupplierID (FK)

### OrderInfo

- OrderID (PK)
- OrderDate
- OrderStatus
- PaymentMethod
- TotalOrder
- ShippingCost
- SellerID (FK)
- BranchID (FK)
- ShippingPartnerID (FK)

### Employee

- EmployeeID (PK)
- FullName
- HireDate
- Salary
- BranchID (FK)

---

## Logical Model Rules

### Entity Integrity

- Every table must have a unique primary key.
- Primary keys cannot be null.

### Referential Integrity

- Foreign keys must reference valid parent records.
- Parent records cannot be deleted if dependent records exist.

### Business Constraints

- A seller can have multiple orders.
- A support employee can handle multiple issues.
- Inventory is managed separately for each branch.

---

# Database Normalization

## First Normal Form (1NF)

All attributes are atomic and each row represents a single occurrence.

## Second Normal Form (2NF)

Order-level attributes were separated from line-item attributes to remove partial dependencies.

Created:

- OrderInfo
- OrderItem

## Third Normal Form (3NF)

Customer information was separated from OrderInfo to eliminate transitive dependencies.

Created:

- Customer
- OrderInfo
- OrderItem

---

# Final Enterprise Data Model

The final database design integrates:

- Sales Management
- Order Processing
- Production Management
- Inventory Control
- Supplier Management
- Shipping Operations
- Customer Support

The design satisfies Third Normal Form (3NF), reduces data redundancy, improves data integrity, and provides a scalable foundation for future reporting and analytics.

---

## Technologies & Concepts

- Conceptual Data Modelling
- Enhanced ER Modelling
- Relational Database Design
- Primary & Foreign Keys
- Referential Integrity
- Business Rules
- Database Normalization (1NF, 2NF, 3NF)
