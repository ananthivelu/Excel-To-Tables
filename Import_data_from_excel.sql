USE [Ananthi]
GO
/****** Object:  StoredProcedure [dbo].[InsertdataFromExcel]    Script Date: 8/26/2021 5:33:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[InsertdataFromExcel]
AS
BEGIN 
--Declaration of variables

--
declare @customerid int, @firstname nvarchar(50),@lastname nvarchar(50),@phonenumber nvarchar(50),
@address nvarchar(50),@city nvarchar(50),@object nvarchar(50),@quantity int, @rate nvarchar(50),
@price nvarchar(50),@purchasedate nvarchar(50)

------------ Loop to process the Customers ----------------
while  exists (select 1 FROM [Temp_Customers])   ----- if the name is not existed in excel sheet means, new customer.
begin
        SELECT @customerID = NULL
        select top 1 @firstname=  firstname , @lastname=  lastname , @phonenumber= phonenumber, @address=  address, @city=  city 
		from [Temp_Customers]

        select @customerID = ID FROM Act_Customers WHERE firstname = @firstname and lastname = @lastname

        --- If customer does not exists, then Insert into Act_Customer ---------
        IF (@customerID IS NULL)
        BEGIN
            insert into [act_Customers](firstname,lastname,phonenumber,address,city) 
            values(@firstname,@lastname,@phonenumber,@address,@city)
        end
        ---- Remove the processed customer record from Temp_Customers 
        DELETE FROM Temp_Customers WHERE firstname = @firstname and lastname = @lastname
END

--------------- Loop to process the Products for the Customers ----------------
while  exists (select 1 FROM [Temp_Products])   ----- if the name is not existed in excel sheet means, new customer.
begin
    SELECT @customerID = NULL

    SELECT TOP 1 @firstname=  firstname , @lastname=  lastname , @object= [object], @quantity=  quantity, @rate=  rate,
    @price=  price, @purchasedate=  purchasedate 
    FROM [Temp_Products]

    select @customerID = ID FROM Act_Customers WHERE firstname = @firstname and lastname = @lastname

    IF (@customerID IS NOT NULL)
    BEGIN
            insert into [act_Products] (customerid,object,quantity,rate,price,purchasedate)
            values(@customerid,@object,@quantity,@rate,@price,@purchasedate)
    END
    ELSE
             SELECT 'Customer not found for Product:'+ @object+' with price '+convert(varchar,@price) 

DELETE FROM Temp_Products WHERE firstname = @firstname and lastname = @lastname 
and [object] = @object and purchasedate = @purchasedate and quantity = @quantity 
and rate = @rate and price = @price

END
END
