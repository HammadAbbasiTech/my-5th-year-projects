/* ===============================
   CLEANUP
=============================== */
IF OBJECT_ID('trg_LowStock','TR') IS NOT NULL DROP TRIGGER trg_LowStock;
IF OBJECT_ID('GenerateSalesReport','P') IS NOT NULL DROP PROCEDURE GenerateSalesReport;
IF OBJECT_ID('RecordSale','P') IS NOT NULL DROP PROCEDURE RecordSale;
IF OBJECT_ID('AddProduct','P') IS NOT NULL DROP PROCEDURE AddProduct;
IF OBJECT_ID('AddSupplier','P') IS NOT NULL DROP PROCEDURE AddSupplier;
IF OBJECT_ID('vw_SalesReport','V') IS NOT NULL DROP VIEW vw_SalesReport;
IF OBJECT_ID('vw_Dashboard','V') IS NOT NULL DROP VIEW vw_Dashboard;
IF OBJECT_ID('StockHistory','U') IS NOT NULL DROP TABLE StockHistory;
IF OBJECT_ID('Sales','U') IS NOT NULL DROP TABLE Sales;
IF OBJECT_ID('OrderDetails','U') IS NOT NULL DROP TABLE OrderDetails;
IF OBJECT_ID('Payments','U') IS NOT NULL DROP TABLE Payments;
IF OBJECT_ID('PurchaseOrders','U') IS NOT NULL DROP TABLE PurchaseOrders;
IF OBJECT_ID('Orders','U') IS NOT NULL DROP TABLE Orders;
IF OBJECT_ID('Products','U') IS NOT NULL DROP TABLE Products;
IF OBJECT_ID('Suppliers','U') IS NOT NULL DROP TABLE Suppliers;
IF OBJECT_ID('Customers','U') IS NOT NULL DROP TABLE Customers;
IF OBJECT_ID('Categories','U') IS NOT NULL DROP TABLE Categories;
IF OBJECT_ID('ErrorLog','U') IS NOT NULL DROP TABLE ErrorLog;
IF OBJECT_ID('SalesReportOutput','U') IS NOT NULL DROP TABLE SalesReportOutput;
GO

/* ===============================
   TABLES
=============================== */
CREATE TABLE Suppliers (
    SupplierID INT IDENTITY PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    City VARCHAR(50)
);

CREATE TABLE Categories (
    CategoryID INT IDENTITY PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);

CREATE TABLE Products (
    ProductID INT IDENTITY PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) CHECK (Price>0),
    Quantity INT CHECK (Quantity>=0),
    ReorderLevel INT,
    SupplierID INT,
    CategoryID INT,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Customers (
    CustomerID INT IDENTITY PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100),
    City VARCHAR(50)
);

CREATE TABLE Orders (
    OrderID INT IDENTITY PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2),
    Status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT CHECK (Quantity>0),
    Discount DECIMAL(5,2) DEFAULT 0,
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE Sales (
    SaleID INT IDENTITY PRIMARY KEY,
    ProductID INT,
    QtySold INT CHECK (QtySold>0),
    Discount DECIMAL(5,2) DEFAULT 0,
    TotalAmount DECIMAL(10,2),
    SaleDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE StockHistory (
    HistoryID INT IDENTITY PRIMARY KEY,
    ProductID INT,
    OldQty INT,
    NewQty INT,
    ChangeDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE ErrorLog (
    ErrorID INT IDENTITY PRIMARY KEY,
    ErrNum INT,
    ErrMsg VARCHAR(300),
    ErrDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE SalesReportOutput (
    ReportLine VARCHAR(300)
);

CREATE TABLE Payments (
    PaymentID INT IDENTITY PRIMARY KEY,
    OrderID INT,
    PaymentDate DATETIME DEFAULT GETDATE(),
    Amount DECIMAL(10,2),
    PaymentMethod VARCHAR(50),
    Status VARCHAR(20) DEFAULT 'Paid',
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

CREATE TABLE PurchaseOrders (
    PurchaseID INT IDENTITY PRIMARY KEY,
    SupplierID INT,
    ProductID INT,
    Quantity INT CHECK (Quantity>0),
    PurchaseDate DATETIME DEFAULT GETDATE(),
    TotalCost DECIMAL(10,2),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

/* ===============================
   SAMPLE DATA
=============================== */
/* Suppliers */
INSERT INTO Suppliers (SupplierName,Phone,City) VALUES
('Global Traders','0301','Lahore'),('Tech Vision','0302','Islamabad'),
('Smart Solutions','0303','Karachi'),('Future Tech','0311','Peshawar'),
('NextGen Supplies','0321','Quetta'),('Digital Hub','0333','Multan'),
('Alpha Electronics','0344','Faisalabad'),('Beta Components','0355','Lahore'),
('Omega Traders','0366','Islamabad'),('Prime Supplies','0377','Karachi'),
('Next Level Tech','0388','Lahore'),('Visionary Electronics','0399','Islamabad'),
('Smart Devices Co.','0410','Karachi'),('Mega Supplies','0421','Peshawar'),
('UltraTech Traders','0432','Quetta'),('ProTech','0443','Multan'),
('Elite Components','0454','Faisalabad'),('TechNova','0465','Lahore'),
('FutureVision','0476','Islamabad'),('CyberSource','0487','Karachi');

/* Categories */
INSERT INTO Categories (CategoryName) VALUES
('Computers'),('Accessories'),('Networking'),('Mobile'),('Audio'),
('Storage'),('Peripherals'),('Office'),('Gaming'),('Power'),
('Wearables'),('SmartHome'),('Cables'),('Printers'),('Monitors'),
('Software'),('Camera'),('Tablet'),('Projector'),('Furniture');

/* Products */
INSERT INTO Products (ProductName,Price,Quantity,ReorderLevel,SupplierID,CategoryID) VALUES
('Laptop',120000,20,5,2,1),('Printer',40000,12,3,1,14),('Mouse',1500,60,10,3,2),
('Keyboard',2500,50,8,3,2),('Scanner',28000,8,2,1,14),('Monitor',45000,15,4,2,15),
('USB',2000,120,20,4,13),('HDD',15000,30,5,5,6),('Webcam',8000,20,5,6,17),
('Headphones',6000,35,6,6,5),('Router',9000,18,4,7,3),('UPS',22000,10,3,7,10),
('GPU',80000,10,2,8,1),('Motherboard',25000,15,3,8,1),('RAM 8GB',12000,40,10,9,1),
('RAM 16GB',22000,30,8,9,1),('CPU Intel',55000,12,3,10,1),('CPU AMD',48000,10,2,10,1),
('PSU',10000,20,5,10,10),('Fan',3500,50,10,10,10);

/* Customers */
INSERT INTO Customers (CustomerName,Phone,Email,City) VALUES
('Ali Khan','0301000001','ali@mail.com','Lahore'),
('Sara Ahmed','0301000002','sara@mail.com','Islamabad'),
('Omar Farooq','0301000003','omar@mail.com','Karachi'),
('Ayesha Khan','0301000004','ayesha@mail.com','Peshawar'),
('Bilal Shah','0301000005','bilal@mail.com','Quetta'),
('Hina Iqbal','0301000006','hina@mail.com','Multan'),
('Usman Riaz','0301000007','usman@mail.com','Faisalabad'),
('Mona Tariq','0301000008','mona@mail.com','Lahore'),
('Zain Ali','0301000009','zain@mail.com','Islamabad'),
('Nida Saeed','0301000010','nida@mail.com','Karachi'),
('Hassan Tariq','0301000011','hassan@mail.com','Lahore'),
('Saba Iqbal','0301000012','saba@mail.com','Islamabad'),
('Kamran Shah','0301000013','kamran@mail.com','Karachi'),
('Fariha Khan','0301000014','fariha@mail.com','Peshawar'),
('Danish Ali','0301000015','danish@mail.com','Quetta'),
('Mariam Noor','0301000016','mariam@mail.com','Multan'),
('Uzair Ahmed','0301000017','uzair@mail.com','Faisalabad'),
('Noor Fatima','0301000018','noor@mail.com','Lahore'),
('Shahid Khan','0301000019','shahid@mail.com','Islamabad'),
('Zoya Iqbal','0301000020','zoya@mail.com','Karachi');
GO
INSERT INTO ErrorLog (ErrNum, ErrMsg) VALUES
(101, 'Test error: Invalid product ID'),
(102, 'Test error: Insufficient stock'),
(103, 'Test error: Payment failed'),
(104, 'Test error: Order not found'),
(105, 'Test error: Discount exceeds limit');
GO

/* ===============================
   STORED PROCEDURES
=============================== */
CREATE PROCEDURE AddSupplier 
  @name VARCHAR(100), @phone VARCHAR(20), @city VARCHAR(50)
AS
BEGIN
    INSERT INTO Suppliers (SupplierName,Phone,City) VALUES (@name,@phone,@city);
END;
GO

CREATE PROCEDURE AddProduct
  @name VARCHAR(100), @price DECIMAL(10,2), @qty INT, @reorder INT, @supplier INT, @category INT
AS
BEGIN
    IF @qty < 0 RAISERROR('Invalid Quantity',16,1);
    INSERT INTO Products (ProductName,Price,Quantity,ReorderLevel,SupplierID,CategoryID)
    VALUES (@name,@price,@qty,@reorder,@supplier,@category);
END;
GO

CREATE PROCEDURE RecordSale
  @ProductID INT, @Qty INT, @Discount DECIMAL(5,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;
        DECLARE @price DECIMAL(10,2), @oldQty INT, @total DECIMAL(10,2);
        SELECT @price=Price,@oldQty=Quantity FROM Products WHERE ProductID=@ProductID;
        IF @oldQty < @Qty RAISERROR('Insufficient Stock',16,1);
        SET @total = (@price*@Qty) - ((@price*@Qty)*@Discount/100);
        INSERT INTO Sales (ProductID,QtySold,Discount,TotalAmount) VALUES(@ProductID,@Qty,@Discount,@total);
        UPDATE Products SET Quantity = Quantity - @Qty WHERE ProductID=@ProductID;
        INSERT INTO StockHistory (ProductID,OldQty,NewQty,ChangeDate)
        VALUES(@ProductID,@oldQty,@oldQty-@Qty,GETDATE());
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        INSERT INTO ErrorLog (ErrNum,ErrMsg,ErrDate)
        VALUES (ERROR_NUMBER(),ERROR_MESSAGE(),GETDATE());
    END CATCH
END;
GO

CREATE PROCEDURE GenerateSalesReport
AS
BEGIN
    DELETE FROM SalesReportOutput;

    DECLARE @ProductName VARCHAR(100);
    DECLARE @QtySold INT;
    DECLARE @TotalAmount DECIMAL(10,2);
    DECLARE @ReportLine VARCHAR(300);

    DECLARE sales_cursor CURSOR FOR
    SELECT P.ProductName, S.QtySold, S.TotalAmount
    FROM Sales S
    JOIN Products P ON S.ProductID = P.ProductID
    ORDER BY S.SaleDate DESC;

    OPEN sales_cursor;
    FETCH NEXT FROM sales_cursor INTO @ProductName, @QtySold, @TotalAmount;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ReportLine = 'Product:' + @ProductName + ' Qty:' + CAST(@QtySold AS VARCHAR) 
                          + ' Amount:' + CAST(@TotalAmount AS VARCHAR);
        INSERT INTO SalesReportOutput (ReportLine) VALUES (@ReportLine);
        FETCH NEXT FROM sales_cursor INTO @ProductName, @QtySold, @TotalAmount;
    END

    CLOSE sales_cursor;
    DEALLOCATE sales_cursor;
END;
GO

/* ===============================
   TRIGGER
=============================== */
CREATE TRIGGER trg_LowStock ON Products
AFTER UPDATE
AS
INSERT INTO ErrorLog (ErrNum,ErrMsg,ErrDate)
SELECT 500,'Low Stock Alert: Product '+CAST(ProductID AS VARCHAR),GETDATE()
FROM inserted
WHERE Quantity <= ReorderLevel;
GO

/* ===============================
   VIEWS
=============================== */
CREATE VIEW vw_SalesReport AS
SELECT P.ProductName,S.QtySold,S.TotalAmount,S.SaleDate
FROM Sales S
JOIN Products P ON S.ProductID=P.ProductID;
GO

CREATE VIEW vw_Dashboard AS
SELECT P.ProductName,P.Quantity,P.ReorderLevel,
CASE WHEN P.Quantity<=P.ReorderLevel THEN 'LOW' ELSE 'OK' END AS Status,
ISNULL(SUM(S.TotalAmount),0) AS Revenue
FROM Products P
LEFT JOIN Sales S ON P.ProductID=S.ProductID
GROUP BY P.ProductName,P.Quantity,P.ReorderLevel;
GO

/* ===============================
   SAMPLE SALES TEST
=============================== */
EXEC RecordSale @ProductID=1, @Qty=5, @Discount=5;
EXEC RecordSale @ProductID=3, @Qty=10, @Discount=0;
EXEC RecordSale @ProductID=7, @Qty=20, @Discount=0;
EXEC RecordSale @ProductID=10, @Qty=5, @Discount=5;
GO

EXEC GenerateSalesReport;
GO

/* ===============================
   VIEW RESULTS
=============================== */
SELECT * FROM vw_Dashboard;
SELECT * FROM vw_SalesReport;
SELECT * FROM StockHistory;
SELECT * FROM ErrorLog;
SELECT * FROM SalesReportOutput;
GO