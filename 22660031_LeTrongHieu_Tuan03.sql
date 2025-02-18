
--1) Tạo hai bảng mới trong cơ sở dữ liệu AdventureWorks2008 theo cấu trúc sau:
create table
MyDepartment (
DepID smallint not null primary key, 
DepName nvarchar(50),
GrpName nvarchar(50)
)
create table MyEmployee (
EmpID int not null primary key, 
FrstName nvarchar(50),
MidName nvarchar(50),
LstName nvarchar(50),
DepID smallint not null foreign key
references MyDepartment(DepID)
)
--2) Dùng lệnh insert <TableName1> select <fieldList> from
--<TableName2> chèn dữ liệu cho bảng MyDepartment, lấy dữ liệu từ
--bảng [HumanResources].[Department].
insert into MyDepartment
select DepartmentID, Name, GroupName 
from [HumanResources].[Department]

--3) Tương tự câu 2, chèn 20 dòng dữ liệu cho bảng MyEmployee lấy dữ liệu
--từ 2 bảng
--[Person].[Person] và
--[HumanResources].[EmployeeDepartmentHistory]
insert into MyEmployee
select top 4 d.BusinessEntityID, FirstName, MiddleName, LastName, DepartmentID
from HumanResources.EmployeeDepartmentHistory d join Person.Person p on p.BusinessEntityID = d.BusinessEntityID
where DepartmentID = 1
select * from MyEmployee

insert into MyEmployee
select top 8 d.BusinessEntityID, FirstName, MiddleName, LastName, DepartmentID
from HumanResources.EmployeeDepartmentHistory d join Person.Person p on p.BusinessEntityID = d.BusinessEntityID
where DepartmentID = 7
select * from MyEmployee

insert into MyEmployee
select top 8 d.BusinessEntityID, FirstName, MiddleName, LastName, DepartmentID
from HumanResources.EmployeeDepartmentHistory d join Person.Person p on p.BusinessEntityID = d.BusinessEntityID
where DepartmentID = 3
select * from MyEmployee

--4) Dùng lệnh delete xóa 1 record trong bảng MyDepartment với DepID=1,
--có thực hiện được không? Vì sao?
delete from MyDepartment where DepID = 1
-- Không vì mất cha con mồ côi

--5) Thêm một default constraint vào field DepID trong bảng MyEmployee,
--với giá trị mặc định là 1.
-- Thêm default constraint vào trường DepID trong bảng MyEmployee
ALTER TABLE MyEmployee
ADD CONSTRAINT DF_MyEmployee_DepID DEFAULT (1) FOR DepID

--6) Nhập thêm một record mới trong bảng MyEmployee, theo cú pháp sau:
--insert into MyEmployee (EmpID, FrstName, MidName,
--LstName) values(1, 'Nguyen','Nhat','Nam'). Quan sát giá trị
--trong field depID của record mới thêm.
INSERT INTO MyEmployee (EmpID, FrstName, MidName, LstName)
VALUES (1, 'Nguyen', 'Thanh', 'Giap')
-- Quan sát giá trị trong field DepID của record mới thêm.
--7) Xóa foreign key constraint trong bảng MyEmployee, thiết lập lại khóa ngoại
--DepID tham chiếu đến DepID của bảng MyDepartment với thuộc tính on
--delete set default.
alter table [dbo].[MyEmployee] drop constraint [FK__MyEmploye__DepID__16644E42]
alter table [dbo].[MyEmployee] with check
add constraint FK_MyEmployee foreign key (DepID) references MyDepartment (DepID) 
on delete set default

--8) Xóa một record trong bảng MyDepartment có DepID=7, quan sát kết quả
--trong hai bảng MyEmployee và MyDepartment
delete from MyDepartment where DepID = '7'
-- Quan sát kết quả trong hai bảng MyEmployee và MyDepartment

--9) Xóa foreign key trong bảng MyEmployee. Hiệu chỉnh ràng buộc khóa
--ngoại DepID trong bảng MyEmployee, thiết lập thuộc tính on delete
--cascade và on update cascade
ALTER TABLE MyEmployee
ADD CONSTRAINT [FK__MyEmploye__DepID__20E1DCB5]
FOREIGN KEY (DepID) REFERENCES MyDepartment(DepID)
ON DELETE CASCADE
ON UPDATE CASCADE
--10)Thực hiện xóa một record trong bảng MyDepartment với DepID =3, có
--thực hiện được không?
delete from MyDepartment where DepID = 3
-- Có thể thực hiện được do đã thiết lập ràng buộc cascade trong bước trước

--11)Thêm ràng buộc check vào bảng MyDepartment tại field GrpName, chỉ cho
--phép nhận thêm những Department thuộc group Manufacturing
ALTER TABLE MyDepartment WITH NOCHECK
ADD CONSTRAINT CHK_GrpName
CHECK (GrpName = 'Manufacturing')
--12)Thêm ràng buộc check vào bảng [HumanResources].[Employee], tại cột
--BirthDate, chỉ cho phép nhập thêm nhân viên mới có tuổi từ 18 đến 60
ALTER TABLE [HumanResources].[Employee] WITH NOCHECK
ADD CONSTRAINT CHK_Employee_AgeRange
CHECK (DATEDIFF(year, BirthDate, GETDATE()) BETWEEN 18 AND 60)
----II. Phần View
--1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng 
--Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm 
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
GO
CREATE view products1 as 
    select pp.ProductID, pp.Name, pp.Color, pp.Size, pp.Style, 
        ppch.StandardCost, ppch.EndDate, ppch.StartDate
    from production.Product as pp join Production.ProductCostHistory as ppch
    on pp.ProductID = ppch.ProductID
GO
-- kiểm tra kết quả
select * from products1
--2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt 
--hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID, 
--Product_Name, CountOfOrderID và SubTotal.
GO
CREATE view List_Product_View as
    select pp.ProductID, pp.Name as 'Product_Name', CountOfOrderID = count(*), 
        SubTotal = sum(ssod.OrderQty * ssod.UnitPrice)
    from Production.Product as pp join Sales.SalesOrderDetail as ssod
    on pp.ProductID = ssod.ProductID join Sales.SalesOrderHeader as ssoh
    on ssod.SalesOrderID = ssoh.SalesOrderID
    where datepart(q, ssoh.OrderDate) = 1 and year(ssoh.OrderDate) = 2008
    group by pp.ProductID, pp.Name
    HAVING count(*) > 500 and sum(ssod.OrderQty * ssod.UnitPrice) > 10000
GO
-- kiểm tra kết quả
select * from List_Product_View

--3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột 
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm 
--CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS 
--OrderMonth, SUM(TotalDue).
GO
CREATE VIEW dbo.vw_CustomerTotals AS
SELECT CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY CustomerID, YEAR(OrderDate), MONTH(OrderDate)
GO
---Kiểm tra kết quả---
select * from dbo.vw_CustomerTotals

--4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân 
--viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty
GO
CREATE VIEW dbo.vw_EmployeeTotalQuantity 
AS
SELECT SalesPersonID, YEAR(OrderDate) AS OrderYear, SUM(OrderQty) AS sumOfOrderQty
FROM Sales.SalesOrderHeader soh JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY SalesPersonID, YEAR(OrderDate)
GO
---Kiểm tra kết quả---
select * from dbo.vw_EmployeeTotalQuantity
--5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn 
--đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên 
--(FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).
GO
CREATE VIEW dbo.ListCustomer_view 
AS
SELECT PersonID, FirstName + ' ' + LastName AS FullName, COUNT(*) AS CountOfOrders
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) BETWEEN 2007 AND 2008
GROUP BY PersonID, FirstName, LastName
HAVING COUNT(*) > 25
GO

--6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với 
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông 
--tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
--Sales.SalesOrderHeader, Sales.SalesOrderDetail, và
--Production.Product)
GO
CREATE VIEW dbo.ListProduct_view 
AS
SELECT p.ProductID, p.Name, YEAR(soh.OrderDate) AS Year, SUM(sod.OrderQty) AS SumOfOrderQty
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE p.Name LIKE 'Bike%' OR p.Name LIKE 'Sport%'
GROUP BY p.ProductID, p.Name, YEAR(soh.OrderDate)
HAVING SUM(sod.OrderQty) > 50
GO
---Kiểm tra kết quả---
select * from dbo.ListProduct_view 

--7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate: 
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID), 
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng 
--[HumanResources].[Department], 
--[HumanResources].[EmployeeDepartmentHistory], 
--[HumanResources].[EmployeePayHistory].
GO
CREATE VIEW dbo.List_department_View 
AS
SELECT d.DepartmentID, d.Name, AVG(eph.Rate) AS AvgOfRate
FROM HumanResources.Department d JOIN HumanResources.EmployeeDepartmentHistory edh ON d.DepartmentID = edh.DepartmentID
JOIN HumanResources.EmployeePayHistory eph ON edh.BusinessEntityID = eph.BusinessEntityID
GROUP BY d.DepartmentID, d.Name
HAVING AVG(eph.Rate) > 30
GO
---Kiểm tra kết quả---
select * from dbo.List_department_View 

--8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm 
--OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal 
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
GO
CREATE VIEW Sales.vw_OrderSummary WITH ENCRYPTION 
AS
SELECT YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(TotalDue) AS OrderTotal
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
GO
---Kiểm tra kết quả---
select * from Sales.vw_OrderSummary

--9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING 
--gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng 
--ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng 
--Product. Có xóa được không? Vì sao?
GO
CREATE VIEW Production.vwProducts WITH SCHEMABINDING AS
SELECT  p.ProductID, p.Name, pch.StartDate, pch.EndDate, ListPrice
FROM Production.Product p JOIN Production.ProductCostHistory pch ON p.ProductID = pch.ProductID
GO
---Kiểm tra kết quả---
select * from Production.vwProducts

--10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các 
--phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality 
--Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
--a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm 
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có 
--chèn được không? Giải thích.
-- Không thể chèn được vì WITH CHECK OPTION đã kiểm tra điều kiện
--b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một 
--phòng thuộc nhóm “Quality Assurance”.
-- Có thể chèn được vì các điều kiện trong WITH CHECK OPTION được đáp ứng
--c. Dùng câu lệnh Select xem kết quả trong bảng Department.
-- a. Tạo view với FROM và WITH CHECK OPTION
-- 10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
-- phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
-- Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
GO
create view view_Department as
    select hrd.DepartmentID, hrd.Name, hrd.GroupName
    from [HumanResources].[Department] as hrd
    where GroupName='Manufacturing' or GroupName='Quality Assurance'
    WITH CHECK OPTION
go
-- Kiểm tra kết quả
select * from view_Department

-- a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
-- “Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
-- chèn được không? Giải thích.
insert into view_Department values( 'nhan su', 'a')
-- không chèn được vì thuộc tính with check option kiểm tra không cho chèn
select *from [HumanResources].[Department]

-- b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một
-- phòng thuộc nhóm “Quality Assurance”.
insert into view_Department values( 'nhan su', 'Manufacturing'),
                            ('nhan su 2', 'Quality Assurance')
-- chèn được
-- c. Dùng câu lệnh Select xem kết quả trong bảng Department.
select *from [HumanResources].[Department]
