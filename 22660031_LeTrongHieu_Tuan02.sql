
--I)  Câu lệnh SELECT sử dụng các hàm thống kê với các mệnh đề Group by và 
--Having:
--1)  Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng  6  năm 2008  có 
--tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate,  SubTotal,  trong đó 
--SubTotal  =SUM(OrderQty*UnitPrice).
SELECT SalesOrderHeader.SalesOrderID, OrderDate, SUM(OrderQty * UnitPrice) AS SubTotal
FROM Sales.SalesOrderHeader
JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
WHERE MONTH(OrderDate) = 6 AND YEAR(OrderDate) = 2008
GROUP BY SalesOrderHeader.SalesOrderID, OrderDate
HAVING SUM(OrderQty * UnitPrice) > 70000

--2)  Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia 
--có  mã  vùng  là  US  (lấy  thông  tin  từ  các  bảng  Sales.SalesTerritory, 
--Sales.Customer,  Sales.SalesOrderHeader,  Sales.SalesOrderDetail).  Thông  tin 
--bao  gồm  TerritoryID,  tổng  số  khách  hàng  (CountOfCust),  tổng  tiền 
--(SubTotal) với  SubTotal = SUM(OrderQty*UnitPrice)
SELECT st.TerritoryID, COUNT(c.CustomerID) AS CountOfCust, SUM(soh.SubTotal) AS SubTotal
FROM Sales.SalesTerritory st
JOIN Sales.Customer c ON st.TerritoryID = c.TerritoryID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
WHERE st.CountryRegionCode = 'US'
GROUP BY st.TerritoryID
--3)  Tính  tổng  trị  giá  của  những  hóa  đơn  với  Mã  theo  dõi  giao  hàng
--(CarrierTrackingNumber)  có  3  ký  tự  đầu  là  4BD,  thông  tin  bao  gồm 
--SalesOrderID, CarrierTrackingNumber,  SubTotal=SUM(OrderQty*UnitPrice)
SELECT SalesOrderHeader.SalesOrderID, CarrierTrackingNumber, SUM(OrderQty * UnitPrice) AS SubTotal
FROM Sales.SalesOrderHeader
JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
WHERE LEFT(CarrierTrackingNumber, 3) = '4BD'
GROUP BY SalesOrderHeader.SalesOrderID, CarrierTrackingNumber


--4)  Liệt  kê  các  sản  phẩm  (Product)  có  đơn  giá  (UnitPrice)<25  và  số  lượng  bán 
--trung bình >5, thông tin gồm ProductID, Name,  AverageOfQty.
SELECT SalesOrderDetail.ProductID, Name, AVG(OrderQty) AS AverageOfQty
FROM Production.Product
JOIN Sales.SalesOrderDetail ON Production.Product.ProductID = Sales.SalesOrderDetail.ProductID
WHERE UnitPrice < 25
GROUP BY SalesOrderDetail.ProductID, Name
HAVING AVG(OrderQty) > 5

--5)  Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm 
--JobTitle,  C ountOfPerson=Count(*)
SELECT JobTitle, COUNT(*) AS CountOfPerson
FROM HumanResources.Employee
GROUP BY JobTitle
HAVING COUNT(*) > 20
--6)  Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên 
--kết  thúc  bằng  ‘Bicycles’  và  tổng  trị  giá  >  800000,  thông  tin  gồm 
--BusinessEntityID, Vendor_Name, ProductID, SumOfQty,  SubTotal
--(sử dụng các bảng [Purchasing].[Vendor] , [Purchasing].[PurchaseOrderHeader] và 
--[Purchasing].[PurchaseOrderDetail])
SELECT PV.BusinessEntityID, PV.Name, PPOD.ProductID,
    SumOfQty = SUM(PPOD.OrderQty), SubTotal = SUM(PPOD.OrderQty * PPOD.UnitPrice)
FROM Purchasing.Vendor PV
    join Purchasing.PurchaseOrderHeader PPOH on PV.BusinessEntityID = PPOH.VendorID
    join Purchasing.PurchaseOrderDetail PPOD on PPOH.PurchaseOrderID = PPOD.PurchaseOrderID
WHERE PV.Name like '%Bicycles'
GROUP BY PV.BusinessEntityID, PV.Name, PPOD.ProductID
HAVING SUM(PPOD.OrderQty * PPOD.UnitPrice) > 800000


--7)  Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng 
--trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và 
--SubTotal
SELECT Production.Product.ProductID, Name AS Product_Name, COUNT(Sales.SalesOrderHeader.SalesOrderID) AS CountOfOrderID, SUM(OrderQty * UnitPrice) AS SubTotal
FROM Production.Product
JOIN Sales.SalesOrderDetail ON Production.Product.ProductID = Sales.SalesOrderDetail.ProductID
JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
WHERE YEAR(OrderDate) = 2008 AND MONTH(OrderDate) BETWEEN 1 AND 3
GROUP BY Production.Product.ProductID, Name
HAVING COUNT(Sales.SalesOrderHeader.SalesOrderID) > 500 AND SUM(OrderQty * UnitPrice) > 10000


--8)  Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến 
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +'   '+ LastName 
--as FullName), Số hóa đơn  (CountOfOrders).
SELECT SC.PersonID, FullName = (PP.FirstName + ' ' + PP.LastName), CountOfOrders = COUNT(SOH.SalesOrderID)
FROM Person.Person PP
    join Sales.Customer SC on PP.BusinessEntityID = SC.CustomerID
    join Sales.SalesOrderHeader SOH on SOH.CustomerID = SC.CustomerID
WHERE YEAR(SOH.OrderDate) BETWEEN 2007 and 2008
GROUP BY  SC.PersonID, PP.FirstName + ' ' + PP.LastName
HAVING COUNT(SOH.SalesOrderID) > 25
--9)  Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng 
--bán  trong  mỗi  năm  trên  500  sản  phẩm,  thông  tin  gồm  ProductID,  Name, 
--CountOfOrderQty,  Year.  (Dữ  liệu  lấy  từ  các  bảng  Sales.SalesOrderHeader, 
--Sales.SalesOrderDetail  và Production.Product)
Select P.ProductID, Name, COUNT(OrderQty)
FROM Sales.SalesOrderDetail O JOIN Sales.SalesOrderHeader H ON H.SalesOrderID = O.SalesOrderID
JOIN Production.Product P ON P.ProductID = O.ProductID
WHERE Name LIKE 'BIKE%' OR NAME LIKE 'Sport%'
GROUP BY P.ProductID, NAME, YEAR(OrderDate)
HAVING COUNT(OrderQty) >500
--10)  Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông 
--tin  gồm  Mã  phòng  ban  (DepartmentID),  tên  phòng  ban  (Name),  Lương  trung
--bình (AvgofRate).  Dữ  liệu  từ  các  bảng
--[HumanResources].[Department], 
--[HumanResources].[EmployeeDepartmentHistory], 
--[HumanResources].[EmployeePayHistory].
-- 10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
-- tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
-- bình (AvgofRate). Dữ liệu từ các bảng
-- [HumanResources].[Department],
-- [HumanResources].[EmployeeDepartmentHistory],
-- [HumanResources].[EmployeePayHistory]
SELECT HDR.DepartmentID, HDR.Name, AvgofRate = AVG(HEPH.Rate)
FROM HumanResources.Department HDR
    join HumanResources.EmployeeDepartmentHistory HEDH on HDR.DepartmentID = HEDH.DepartmentID
    join HumanResources.EmployeePayHistory HEPH on HEDH.BusinessEntityID = HEPH.BusinessEntityID
GROUP BY HDR.DepartmentID, HDR.Name
HAVING AVG(HEPH.Rate) > 30
--II)  Subquery 
--1) Liệt kê các sản phẩm  gồm các thông tin  Product  Names  và  Product ID  có 
--trên 100 đơn đặt hàng trong tháng 7 năm  2008
SELECT PP.ProductID, PP.Name
from Production.Product as PP
where PP.ProductID in (
    SELECT SOD.ProductID
    from Sales.SalesOrderDetail as SOD join Sales.SalesOrderHeader as SOH
    on SOD.SalesOrderID = SOH.SalesOrderID
WHERE MONTH(SOH.OrderDate) = 7 and YEAR(SOH.OrderDate) = 2008
group by SOD.ProductID
having count(*) > 100
)

--2)  Liệt  kê  các  sản  phẩm  (ProductID,  Name)  có  số  hóa  đơn  đặt  hàng  nhiều  nhất
--trong tháng  7/2008
SELECT PP.ProductID, PP.Name
from Production.Product PP join Sales.SalesOrderDetail SOD
    on PP.ProductID = SOD.ProductID
    join Sales.SalesOrderHeader SOH on SOD.SalesOrderID = SOH.SalesOrderID
where MONTH(SOH.OrderDate) = 7 and YEAR(SOH.OrderDate) = 2008
group by PP.ProductID, PP.Name
having COUNT(*)>=all( 
    SELECT COUNT(*)
    from Sales.SalesOrderDetail d join Sales.SalesOrderHeader h
    on d.SalesOrderID=h.SalesOrderID
where MONTH(OrderDate)=7 and YEAR(OrderDate)=2008
group by ProductID
)

--3)  Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm: 
--CustomerID, Name,  CountOfOrder
SELECT c.CustomerID, CountofOrder=COUNT(*)
FROM Sales.Customer c join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
group by c.CustomerID
having COUNT(*)>=all (
    SELECT COUNT(*)
    FROM Sales.Customer c join Sales.SalesOrderHeader h 
    on c.CustomerID=h.CustomerID
    group by c.CustomerID
)
--4)  Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với 
--tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng 
--bảng Production.Product và  Production.ProductModel) 
SELECT ProductID, Name
FROM Production.Product
WHERE ProductModelID IN 
    (SELECT ProductModelID
	 FROM Production.ProductModel
	 WHERE EXISTS 
        (SELECT 1
         FROM Production.Product
         WHERE ProductModelID = Production.ProductModel.ProductModelID
         AND Name LIKE 'Long-Sleeve Logo Jersey%')
	)

--5)  Tìm các  mô hình  sản phẩm (ProductModelID)  mà giá niêm  yết (list price) tối
--đa cao hơn giá trung bình của tất cả các mô  hình.
SELECT PPM.ProductModelID, PPM.Name, max(PP.ListPrice)
from Production.ProductModel PPM join Production.Product PP
    on PPM.ProductModelID = PP.ProductModelID
group by PPM.ProductModelID, PPM.Name
having max(PP.ListPrice) >= all (
    SELECT avg(PP.ListPrice)
    from Production.ProductModel PPM join Production.Product PP
    on PPM.ProductModelID = PP.ProductModelID
	)

--6)  Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng 
--đặt hàng > 5000 (dùng IN,  EXISTS)
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID IN 
    (SELECT ProductID
    FROM Sales.SalesOrderDetail
    GROUP BY ProductID
    HAVING SUM(OrderQty) > 5000)

--7)  Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao 
--nhất trong bảng  Sales.SalesOrderDetail
SELECT TOP 1 WITH TIES ProductID, UnitPrice
FROM Sales.SalesOrderDetail
ORDER BY UnitPrice DESC
--8)  Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID, 
--Nam; dùng 3 cách Not in, Not exists và Left  join.
select * from Production.Product
where ProductID Not in 
						(select ProductID from Sales.SalesOrderDetail)
--
select * from Production.Product p
where not exists
						(select ProductID from Sales.SalesOrderDetail o
						where o.ProductID = p.productID)
--
select p.productID, Name, SalesOrderID
from Production.Product p left join Sales.SalesOrderDetail o on o.ProductID = p.ProductID
where SalesOrderID is Null

--9)  Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm 
--EmployeeID,  FirstName,  LastName  (dữ  liệu  từ  2  bảng 
--HumanResources.Employees và Sales.SalesOrdersHeader)
SELECT EmployeeID = PP.BusinessEntityID, PP.FirstName, PP.LastName
from Person.Person as PP
where PP.BusinessEntityID in (
    SELECT SOH.SalesPersonID
    from Sales.SalesOrderHeader as SOH
    where SOH.OrderDate > '2008-05-01'
)
--10)  Liệt  kê  danh  sách  các  khách  hàng  (CustomerID,  Name)  có  hóa  đơn  dặt  hàng
--trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm  2008.
SELECT distinct SOH.CustomerID
from Sales.SalesOrderHeader as SOH
where SOH.CustomerID in (
    SELECT SOH1.CustomerID
    from Sales.SalesOrderHeader as SOH1
    where YEAR(SOH1.OrderDate) = 2007
) 
and SOH.CustomerID not in (
    SELECT SOH2.CustomerID
    from Sales.SalesOrderHeader as SOH2
    where YEAR(SOH2.OrderDate) = 2008
)
