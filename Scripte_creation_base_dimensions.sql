CREATE DATABASE BD_store;
GO

USE BD_store;
Go

CREATE TABLE dbo.DimDate(
  DateKey INT PRIMARY KEY,
  [Date] Date not NULL,
  [Day] TINYINT NOT NULL,
  DayName NVARCHAR(10) NOT NULL,
  [Month] TINYINT NOT NULL,
  MonthName NVARCHAR(10) NOT NULL,
  [Quarter] TINYINT NOT NULL,
  [YEAR] SMALLINT not null,
  IsWeekend BIT NOT NULL
  );
 GO

 CREATE TABLE dbo.DimProduct(
 ProductKey INT IDENTITY(1,1) Primary KEY,
 productID NVARCHAR(50) NOT NULL,
 ProductName NVARCHAR(255) NOT NULL,
 Category NVARCHAR(50) NOT NULL,
 SubCategory NVARCHAR(50) NOT NULL,
 UnitPrice DECIMAL(19,4) null
 );

 GO

 CREATE TABLE  dbo.DimCustomer(
 CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
 CustomerID NVARCHAR(50) NOT NULL,
 CustomerName NVARCHAR(255) NOT NULL,
 Segment NVARCHAR(50) not null
 );

 GO

 CREATE TABLE dbo.DimGeography(
 GeoKey INT IDENTITY(1,1) PRIMARY KEY,
 Country NVARCHAR(50) NOT NULL,
 Region NVARCHAR(50) not null,
 State NVARCHAR(50) NOT NULL,
 City  NVARCHAR(50) not null,
 PostalCode NVARCHAR(50) not null
 );

 GO

 CREATE TABLE dbo.DimShipMode(
 ShipModeKey INT IDENTITY(1,1) PRIMARY KEY,
 ShipMode NVARCHAR(50) NOT NULL
 );

 GO
  CREATE TABLE dbo.FactSales(
  FactSalesKey INT IDENTITY(1,1) PRIMARY KEY,
  OrderID_BK NVARCHAR(50) NOT NULL,
  OrderDateKey Int not null,
  ShipDateKey int not null,
  CustomerKey int not null,
  ProductKey int not null,
  GeoKey int not null,
  ShipModeKey int not null,
  Quantity int not null,
  SalesAmount Decimal(19,4) not null,
  DiscountParent Decimal(19,4) not null,
  DiscountAmount Decimal(19,4) not null,
  ProfitAmount  Decimal(19,4) not null,

  CONSTRAINT FK_FactSales_DimDate_Order FOREIGN KEY (OrderDateKey) REFERENCES DimDate(DateKey),
  CONSTRAINT FK_FactSales_DimDate_Ship FOREIGN KEY (ShipDateKey) REFERENCES DimDate(DateKey),
  CONSTRAINT FK_FactSales_DimCustomer FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
  CONSTRAINT FK_FactSales_DimProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),
  CONSTRAINT FK_FactSales_DimGeography FOREIGN KEY (GeoKey) REFERENCES DimGeography(GeoKey),
  CONSTRAINT FK_FactSales_DimShipMode FOREIGN Key (ShipModeKey) REFERENCES DimShipMode(ShipModeKey)
  );
  GO
  