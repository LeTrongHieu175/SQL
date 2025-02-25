--Tuan 4 I.Batch



--1)  Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của  sản phẩm 
--có ProductID=’778’;  nếu  @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có 
--trên  500  đơn  hàng”,  ngược  lại  thì  in  ra  chuỗi  “Sản  phẩm  778  có  ít  đơn  đặt
--hàng”
DECLARE @tongsoHD INT = 499;

IF @tongsoHD > 500
    PRINT 'San pham có trên 500 đơn hàng';
ELSE
    PRINT 'San pham có ít đơn đat hàng';



--2)   Viết  một  đoạn  Batch  với  tham  số  @makh  và  @n  chứa  số  hóa  đơn  của  khách 
--hàng @makh, tham số @nam  chứa năm lập hóa đơn (ví dụ @nam=2008),    nếu
--@n>0  thì  in  ra  chuỗi:  “Khách  hàng  @makh  có  @n  hóa  đơn  trong  năm  2008” 
--ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng  @makh không có hóa đơn nào 
--trong năm 2008”

DECLARE @makh INT = 25077;  -- Giả sử khách hàng có mã 1
DECLARE @nam INT = 2008;
DECLARE @n INT;

SELECT @n = COUNT(*) 
FROM Sales.SalesOrderHeader soh
WHERE CustomerID = @makh AND YEAR(OrderDate) = @nam;

IF @n > 0
    PRINT 'Khách hàng ' + CAST(@makh AS VARCHAR) + ' có ' + CAST(@n AS VARCHAR) + ' hóa đơn trong năm ' + CAST(@nam AS VARCHAR);
ELSE
    PRINT 'Khách hàng ' + CAST(@makh AS VARCHAR) + ' không có hóa đơn nào trong năm ' + CAST(@nam AS VARCHAR);

select * from Sales.SalesOrderHeader where CustomerID=25077

--3)  Viết  một  batch  tính  số  tiền  giảm  cho  những  hóa  đơn  (SalesOrderID)  có  tổng 
--tiền>100000,  thông  tin  gồm  [SalesOrderID],  SubTotal=SUM([LineTotal]), 
--Discount (tiền giảm), với Discount được tính như  sau:
-- Những hóa đơn có SubTotal<100000 thì không  giảm,
-- SubTotal từ 100000 đến <120000 thì giảm 5% của  SubTotal
-- SubTotal từ 120000 đến <150000 thì giảm 10% của  SubTotal
-- SubTotal từ 150000 trở lên thì giảm 15% của  SubTotal
DECLARE @SalesOrderID INT;
DECLARE @SubTotal DECIMAL(18,2);
DECLARE @Discount DECIMAL(18,2);

DECLARE SalesCursor CURSOR FOR 
SELECT SalesOrderID, SUM(LineTotal) AS SubTotal
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(LineTotal) > 100000;

OPEN SalesCursor;

FETCH NEXT FROM SalesCursor INTO @SalesOrderID, @SubTotal;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Discount = 
        CASE 
            WHEN @SubTotal < 100000 THEN 0
            WHEN @SubTotal < 120000 THEN @SubTotal * 0.05
            WHEN @SubTotal < 150000 THEN @SubTotal * 0.10
            ELSE @SubTotal * 0.15
        END;

    PRINT 'Hóa đơn ' + CAST(@SalesOrderID AS VARCHAR) + ' có SubTotal ' + CAST(@SubTotal AS VARCHAR) + ', giảm giá ' + CAST(@Discount AS VARCHAR);

    FETCH NEXT FROM SalesCursor INTO @SalesOrderID, @SubTotal;
END

CLOSE SalesCursor;
DEALLOCATE SalesCursor;



--4)  Viết một Batch với 3 tham số:  @masp, @mancc, @soluongcc, chứa giá trị của 
--các  field  [ProductID],[BusinessEntityID],[OnOrderQty],  với  giá  trị  truyền  cho 
--các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ 
--gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc,   nếu
--@soluongcc trả về giá  trị là null  thì in  ra chuỗi  “Nhà cung  cấp 1650  không cung 
--cấp sản phẩm  4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650 
--cung cấp sản phẩm 4 với số lượng là  5”
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])
DECLARE @masp INT = 4;  -- Giả sử sản phẩm có mã 4
DECLARE @mancc INT = 1650; -- Giả sử nhà cung cấp có mã 1650
DECLARE @soluongcc INT;

SELECT @soluongcc = OnOrderQty 
FROM Purchasing.ProductVendor
WHERE ProductID = @masp AND BusinessEntityID = @mancc;

IF @soluongcc IS NULL
    PRINT 'Nhà cung cấp ' + CAST(@mancc AS VARCHAR) + ' không cung cấp sản phẩm ' + CAST(@masp AS VARCHAR);
ELSE IF @soluongcc = 5
    PRINT 'Nhà cung cấp ' + CAST(@mancc AS VARCHAR) + ' cung cấp sản phẩm ' + CAST(@masp AS VARCHAR) + ' với số lượng là 5';


--5)  Viết  một  batch  thực  hiện  tăng  lương  giờ  (Rate)  của  nhân  viên  trong 
--[HumanResources].[EmployeePayHistory]  theo  điều  kiện  sau:  Khi  tổng  lương 
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì  dừng.

WHILE (SELECT SUM(rate) FROM
[HumanResources].[EmployeePayHistory])<6000 
BEGIN
UPDATE [HumanResources].[EmployeePayHistory] 
SET rate = rate*1.1
IF (SELECT MAX(rate)FROM
[HumanResources].[EmployeePayHistory]) > 150 
BREAK
ELSE
CONTINUE
END

