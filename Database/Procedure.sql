﻿USE SorDecor
GO

/* PROCEDURE */

-- PROC mã hóa dữ liệu
CREATE PROC sp_Encrypt @Pass NVARCHAR(128)
AS
BEGIN
	SELECT dbo.Func_Encrypt(@Pass)
END



-- PROC giải mã dữ liệu
CREATE PROC sp_Decrypt @Code VARBINARY(MAX)
AS
BEGIN
	SELECT dbo.Func_Decrypt(@Code)
END


/* --- TEST --- */
-- Test PROC mã hóa
EXEC sp_Encrypt @Pass = '123'
GO
-- Done
--Test PROC giải mã
EXEC sp_Decrypt @Code = 0x020000006167A4044B76E53A0E4763DE9E17460ECF5E4EA06DC78B409C274972F71866F566336285EBC717F1C1CEE08B898AB2DC
GO
--Done

-- PROC Client đăng nhập
CREATE PROC sp_Login @UserName VARCHAR(50), @Pass VARCHAR(MAX)
AS
BEGIN
	DECLARE @count INT
	DECLARE @res BIT

	SELECT @count = COUNT(*) FROM dbo.UserAccounts WHERE UserName = @UserName AND  Pass = @Pass
	IF @count > 0
		SET @res = 1
	ELSE
		SET @res = 0
	SELECT @res
END

sp_Login @UserName = 'admin', @Pass = '123'


-- PROC sinh mã tự động cho SP
CREATE PROC sp_AutoID_Product 
@ProductName NVARCHAR(MAX), 
@Made BIGINT, 
@Info NVARCHAR(MAX),
@Descript NVARCHAR(MAX), 
@Price DECIMAL(19,4), 
@Size BIGINT,
@Sale DECIMAL(19,4), 
@Category BIGINT,
@Freeship BIT, 
@Image VARBINARY(MAX),
@ImageUrl NVARCHAR(MAX),
@SL INT,
@DateUpdate DATETIME,
@STT INT
AS
BEGIN
	DECLARE @ID VARCHAR(128)
	IF(SELECT COUNT(ID) FROM dbo.Products) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 5)) FROM dbo.Products
		SELECT @ID = CASE
			WHEN @ID >= 0 AND @ID < 9 THEN 'SP0000' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)	-- Ex: SP00004
			WHEN @ID >= 9 AND @ID < 99 THEN 'SP000' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)	-- Ex: SP00032
			WHEN @ID >=99 AND @ID < 999 THEN 'SP00' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)	-- Ex: SP00742
			WHEN @ID >=999 AND @ID <9999 THEN 'SP0' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)	-- Ex: SP01525
			WHEN @ID >=9999 THEN 'SP' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)
		END
		SET @ID = MAX(LEFT(@ID, 7))
	INSERT INTO dbo.Products VALUES (
		@ID, @ProductName, @Made, @Info, @Descript, @Price, @Size, @Sale, @Category, @Freeship, @Image, @ImageUrl, @SL, @DateUpdate, @STT
	)
END


-- PROC Delete Item in Cart
CREATE PROC sp_DeleteItemInCart
@ProductID VARCHAR(128),
@CartID VARCHAR(128)
AS
BEGIN
	DECLARE @first INT
	DECLARE @res BIT
	DECLARE @last INT
	SELECT @first =  COUNT(*) FROM dbo.ItemInCarts WHERE CartItemID = @CartID


	DELETE FROM dbo.ItemInCarts
	WHERE ProductID = @ProductID AND CartItemID = @CartID
	SELECT @last = COUNT(*) FROM dbo.ItemInCarts WHERE CartItemID = @CartID

	IF(@last < @first)
		SET @res = 1
	ELSE
		SET @res = 0

	SELECT @res
END


-- PROC Update SL item in cart
CREATE PROC sp_UpdateSLItemInCart
@IDCart VARCHAR(128),
@IDProduct VARCHAR(128),
@SL INT
AS
BEGIN
	DECLARE @res BIT

	UPDATE dbo.ItemInCarts
	SET SL = @SL
	WHERE ProductID = @IDProduct AND CartItemID = @IDCart

		SET @res = 1
	SELECT @res
END


-- PROC create hóa đơn
CREATE PROC sp_AddOrderBill 
@UserID VARCHAR(128), 
@UserName NVARCHAR(128), 
@UserAddress NVARCHAR(MAX),
@Phone VARCHAR(20),
@Note NVARCHAR(MAX),
@Paid BIT,
@DateOrder DATETIME,
@Email VARCHAR(MAX)
AS
BEGIN
	DECLARE @IDafter VARCHAR(128)

	INSERT INTO dbo.OrderBills VALUES (0, @UserID, @UserName, @UserAddress, @Phone, @Note, @Paid, 0, @DateOrder, NULL, 0, @Email)
	SELECT @IDafter = ID FROM dbo.OrderBills WHERE DateOrder = @DateOrder AND UserID = @UserID
	SELECT @IDafter
END


--PROC update SL tồn kho
CREATE PROC sp_UpdateSLProduct
@ID VARCHAR(128)
AS
BEGIN
	DECLARE @res BIT

	UPDATE dbo.Products
	SET SL = a.SL - b.SL
	FROM dbo.Products a, dbo.OrderInfo b
	WHERE a.ID = b.ProductID AND ItemOrder = @ID
	
	SET @res = 1
	SELECT @res
END


-- PROC Admin đăng nhập
CREATE PROC sp_AdminLogin @UserName NVARCHAR(128), @Pass NVARCHAR(128)
AS
BEGIN
	DECLARE @count INT
	DECLARE @res BIT

	SELECT @count = COUNT(*) FROM dbo.Admins WHERE UserName = @UserName AND Pass = @Pass
	IF @count > 0
		SET @res = 1
	ELSE
		SET @res = 0

	SELECT @res
END

-- PROC List SP
CREATE PROC sp_Product_ListAll
AS
BEGIN
	SELECT ID, ProductName, Made, Info, Descript, Price, Size, Sale, Category, Freeship, Image, ImageUrl, SL, DateUpdate, STT
	FROM dbo.Products
	ORDER BY [ProductName] ASC
	--SELECT ID, ProductName, Made, Info, Descript, CAST(CAST(Price AS decimal(19,4)) AS FLOAT) AS Price, Size, CAST(CAST(Sale AS decimal(19,4)) AS FLOAT) AS Sale, Promotions, Images, SL
	--FROM dbo.Product
	--ORDER BY [ProductName] ASC
END
=============================================================

-- PROC AutoID_UserAccount
CREATE PROC sp_AutoID_UserAccount
@UserName VARCHAR(50),
@LastName NVARCHAR(50),
@Email NVARCHAR(MAX),
@Pass NVARCHAR(MAX)
AS
BEGIN
	DECLARE @ID VARCHAR(128)
	IF(SELECT COUNT(ID) FROM dbo.UserAccounts) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 5)) FROM dbo.UserAccounts
		SELECT @ID = CASE
			WHEN @ID >= 0 AND @ID < 9 THEN 'US0000' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)	-- Ex: SP00004
			WHEN @ID >= 9 AND @ID < 99 THEN 'US000' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)	-- Ex: SP00032
			WHEN @ID >=99 AND @ID < 999 THEN 'US00' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)	-- Ex: SP00742
			WHEN @ID >=999 AND @ID <9999 THEN 'US0' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)	-- Ex: SP01525
			WHEN @ID >=9999 THEN 'US' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)
		END
		SET @ID = MAX(LEFT(@ID, 7))
	INSERT INTO dbo.UserAccounts(ID, UserName, Pass, Email, LastName) VALUES (@ID, @UserName, @Pass, @Email, @LastName)


	DECLARE @count INT
	DECLARE @res BIT

	SELECT @count = COUNT(*) FROM dbo.Admin WHERE Acc = @Acc AND Pass = @Pass
	IF @count > 0
		SET @res = 1
	ELSE
		SET @res = 0

	SELECT @res
END



















-- PROC xuất DS theo tên thẻ tag
CREATE PROC ListAll_CategoryName @CategoryName NVARCHAR(50)
AS
BEGIN
	SELECT ProductName, Images, CategoryName, Price
	FROM Product A, Categories B, CateProduct C
	WHERE B.CategoryName = @CategoryName AND (A.ID = C.ProductID AND B.ID = C.CateID)
END
-- TEST
ListAll_CategoryName @CategoryName = 'Trang trí'
-- DONE



-- PROC UPDATE Cart
CREATE PROC sp_UpdateItem 
@ProductID VARCHAR(128),
@SL INT,
@IDCart VARCHAR(128)
AS
BEGIN
	
	UPDATE dbo.ItemInCart
	SET SL = @SL
	WHERE ProductID = @ProductID AND CartItemID = @IDCart

	DECLARE @res BIT = 1

	SELECT @res
END






-- PROC update SL SP trong giỏ
CREATE PROC sp_UpdateSL
@IDCart VARCHAR(128),
@IDProduct VARCHAR(128),
@SL INT
AS
BEGIN
	DECLARE @res BIT
	UPDATE dbo.ItemInCart
	SET SL = @SL
	WHERE CartItemID = @IDCart AND ProductID = @IDProduct
	SET @res = 1
	SELECT @res
END



-- PROC duyệt đơn cho admin
CREATE PROC sp_Confirm
@ID VARCHAR(128)
AS
BEGIN
	DECLARE @res BIT

	UPDATE dbo.ItemOrder
	SET DeliverySTT = 1
	WHERE ID = @ID

	SET @res = 1
	SELECT @res
END

-- PROC hủy duyệt đơn cho admin
CREATE PROC sp_UnConfirm
@ID VARCHAR(128)
AS
BEGIN
	DECLARE @res BIT

	UPDATE dbo.ItemOrder
	SET DeliverySTT = 0
	WHERE ID = @ID

	SET @res = 1
	SELECT @res
END

-- PROC đơn đã giao đến người dùng
CREATE PROC sp_CompleteDeli
@ID VARCHAR(128)
AS
BEGIN
	DECLARE @res BIT

	UPDATE dbo.ItemOrder
	SET DeliverySTT = 1, DeliveryDate = GETDATE()
	WHERE ID = @ID

	SET @res = 1
	SELECT @res
END

-- PROC doanh thu hàng tháng
CREATE PROC sp_EarningPerMonth
AS
BEGIN
	--DECLARE @month INT = MONTH(GETDATE())
	--DECLARE @year INT = YEAR(GETDATE())
	DECLARE @this DATETIME
	DECLARE @tong DECIMAL(19,4)
	SET @this = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) 
	
	SELECT @tong = SUM(Total)
	FROM dbo.ItemOrder A, dbo.OrderInfo B
	WHERE (a.ID = b.ItemOrder AND a.DeliveryDate IS NOT NULL) AND a.DeliveryDate> @this

	SELECT @tong
END

-- PROC doanh thu hàng năm
CREATE PROC sp_EarningPerYear
AS
BEGIN
	DECLARE @this DATETIME
	DECLARE @tong DECIMAL(19,4)
	SET @this = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)

	SELECT @tong = SUM(Total)
	FROM dbo.ItemOrder A, dbo.OrderInfo B
	WHERE (a.ID = b.ItemOrder AND a.DeliveryDate IS NOT NULL) AND a.DeliveryDate> @this

	SELECT @tong
END

select hhangni = MONTH(GETDATE())
select namni = YEAR(GETDATE())
select ngaydauofyear = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)

select DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) 

select sum(Total)
from dbo.ItemOrder a, dbo.OrderInfo b
where (a.ID = b.ItemOrder and a.DeliveryDate is not null) and a.DeliveryDate>'2021/7/1'

sp_EarningPerMonth