USE Northwind

--1.Tüm cirom ne kadar?
SELECT SUM((UnitPrice*Quantity)*(1-Discount)) [CIRO] FROM  [Order Details]
-------------------------------------------------------------------------------------------------------------------------------------------

--2.1997'de tüm cirom ne kadar?
SELECT SUM((UnitPrice*Quantity)*(1-Discount))[1997 YILINA AIT CIRO] 
FROM Orders o JOIN [Order Details] od on o.OrderID=od.OrderID WHERE YEAR(OrderDate)=1997 

-------------------------------------------------------------------------------------------------------------------------------------------

--3.Bugün doğumgünü olan çalışanlarım kimler?

SELECT EmployeeID,FirstName,LastName FROM Employees
		WHERE YEAR(BirthDate)=GETDATE() 
		ORDER BY EmployeeID,FirstName,LastName

--------------------------------------------------------------------------------------------------------------------------------------------

--4.Hangi çalışanım hangi çalışamına bağlı? 

SElECT m.EmployeeID,m.FirstName,m.LastName, a.FirstName,a.LastName 
FROM Employees m JOIN Employees a on m.ReportsTo=a.EmployeeID
		
--------------------------------------------------------------------------------------------------------------------------------------------

--5.Çalışanlarım ne kadarlık satış yapmışlar?

SELECT e.EmployeeID,e.FirstName,e.LastName, SUM(od.UnitPrice*od.Quantity)[Yapilan Satislar] FROM Employees e 
	JOIN Orders o on e.EmployeeID=o.EmployeeID
	JOIN [Order Details] od on od.OrderID=o.OrderID 
  GROUP BY e.FirstName,e.LastName,e.EmployeeID 
  ORDER BY e.EmployeeID ASC

---------------------------------------------------------------------------------------------------------------------------------------------

--6.Hangi ülkelere ihracat yapıyorum?

SELECT distinct ShipCountry  FROM Orders

----------------------------------------------------------------------------------------------------------------------------------------------

--7.Ürünlere göre satışım nasıl?

SELECT distinct ProductName,UnitsOnOrder FROM Orders o 
		JOIN [Order Details] od on o.OrderID = od.OrderID
		JOIN Products p on p.ProductID=od.ProductID order by UnitsOnOrder desc

----------------------------------------------------------------------------------------------------------------------------------------------

--8.Ürün kategorilerine göre satışlarım nasıl? (para bazında)

SELECT c.CategoryID,c.CategoryName,SUM(od.UnitPrice*od.Quantity)[Satislar] FROM Categories c 
	JOIN Products p on c.CategoryID=p.CategoryID 
	JOIN [Order Details] od on od.ProductID=p.ProductID 
		GROUP BY c.CategoryID,c.CategoryName

----------------------------------------------------------------------------------------------------------------------------------------------

--9.Ürün kategoilerine göre satışlarım nasıl? (sayı bazında)

SELECT c.CategoryID,c.CategoryName, COUNT(OrderID) [Satis Sayisi] FROM Categories c 
	JOIN Products p on c.CategoryID=p.CategoryID 
	JOIN [Order Details] od on od.ProductID=p.ProductID 
		GROUP BY c.CategoryID,c.CategoryName

----------------------------------------------------------------------------------------------------------------------------------------------

--10.Çalışanlar ürün bazında ne kadarlık satış yapmışlar?

SELECT e.EmployeeID,e.FirstName+' '+e.LastName [CALISANLAR],o.OrderID,
	SUM(od.UnitPrice*od.Quantity)[URUN BAZINDA YAPILAN SATIS] FROM Employees e 
		JOIN Orders o on e.EmployeeID=o.EmployeeID
		JOIN [Order Details] od on od.OrderID=o.OrderID
		JOIN Products p on p.ProductID=od.ProductID 
			GROUP BY e.EmployeeID,e.FirstName+' '+e.LastName,o.OrderID

----------------------------------------------------------------------------------------------------------------------------------------------

--11.Çalışanlarım para olarak en fazla hangi ürünü satmışlar? Kişi bazında bir rapor istiyorum.
SELECT TOP 1 [EmployeeID], * FROM(
        SELECT TOP 1000  * FROM (
        SELECT EmployeeID, ProductID,  FirstName, LastName, ProductName,(
            SELECT SUM (od.Quantity * od.UnitPrice)[Satis] FROM Orders o
                JOIN [Order Details] od ON od.OrderID = o.OrderID
                JOIN Products p ON p.ProductID = od.ProductID
                WHERE EmployeeID = em.EmployeeID AND p.ProductID = pr.ProductID
                GROUP BY P.ProductID )[Satis]
        FROM Employees em
            CROSS JOIN Products pr
        )[Her Bir Calısan Satisi]
        ORDER BY [Satis] DESC
    )[TABLO]
    WHERE EmployeeID = 2

----------------------------------------------------------------------------------------------------------------------------------------------

--12.Hangi kargo şirketine toplam ne kadar ödeme yapmışım?

SELECT s.CompanyName , SUM(Freight)[Toplam Miktar] FROM Shippers s 
	JOIN Orders o on s.ShipperID=o.ShipVia
	JOIN [Order Details] od on od.OrderID=o.OrderID 
		GROUP BY s.CompanyName

----------------------------------------------------------------------------------------------------------------------------------------------

--13.Tost yapmayı seven çalışanım hangisi? (Basit bir like sorgusu )

SELECT * FROM Employees WHERE Notes like '%toast%'  

----------------------------------------------------------------------------------------------------------------------------------------------

--14.	Hangi tedarkçiden aldığım ürünlerden ne kadar satmışım? 
--(Satış bilgisi order details tablosundan alınacak)

SELECT s.SupplierID,s.CompanyName,COUNT(*)[Satilan Miktarlar] FROM Suppliers s 
	JOIN Products p on  p.SupplierID=s.SupplierID
	JOIN [Order Details] od on od.ProductID=p.ProductID 
		GROUP BY s.SupplierID,s.CompanyName

----------------------------------------------------------------------------------------------------------------------------------------------

--15.En değerli müşterim hangisi? (en fazla satış yaptığım müşteri)
SELECT top 1 CustomerID,CompanyName,Satis FROM
(SELECT c.CustomerID,c.CompanyName,SUM(od.UnitPrice*od.Quantity)[Satis] FROM Customers c 
	JOIN Orders o on c.CustomerID=o.CustomerID	
	JOIN [Order Details] od on od.OrderID=o.OrderID  
		group by c.CustomerID,c.CompanyName) tablo 
		order by Satis desc

----------------------------------------------------------------------------------------------------------------------------------------------

--16.	Hangi müşteriler para bazında en fazla hangi ürünü almışlar?  select * from customers

SELECT TOP 1 [CustomerID], * FROM(
        SELECT TOP 1000  * FROM (
        SELECT CustomerID, ProductID, CompanyName, ProductName,(
            SELECT SUM (od.Quantity * od.UnitPrice)[Satis] FROM Orders o
                JOIN [Order Details] od ON od.OrderID = o.OrderID
                JOIN Products p ON p.ProductID = od.ProductID
                WHERE CustomerID = cu.CustomerID AND p.ProductID = pr.ProductID
                GROUP BY P.ProductID )[Satis]
        FROM Customers cu
            CROSS JOIN Products pr
        )[Müsteri Satisi]
        ORDER BY [Satis] DESC
    )[TABLO]
    WHERE CustomerID = 'ALFKI'
----------------------------------------------------------------------------------------------------------------------------------------------

--17.	Hangi ülkelere ne kadarlık satış yapmışım?

SELECT o.ShipCountry, SUM(od.UnitPrice*od.Quantity)[Satis Miktari] FROM Orders o 
	JOIN [Order Details] od on o.OrderID=od.OrderID 
		GROUP BY o.ShipCountry 
		ORDER BY [Satis Miktari] desc

----------------------------------------------------------------------------------------------------------------------------------------------

--18.Zamanında teslim edemediğim siparişlerim ID’leri  nelerdir ve kaç gün geç göndermişim?

SELECT OrderID,  DATEDIFF(DAY,RequiredDate,ShippedDate) 
	as GecGonderim FROM Orders order by GecGonderim desc
----------------------------------------------------------------------------------------------------------------------------------------------

--19.Ortalama satış miktarının üzerine çıkan satışlarım hangisi?

SELECT OrderID,UnitPrice*Quantity[Satis] FROM [Order Details] 
	 WHERE Quantity*UnitPrice>(SELECT  avg(UnitPrice*Quantity) FROM [Order Details])

----------------------------------------------------------------------------------------------------------------------------------------------

--20.Satışlarımı kaç günde teslim etmişim?

SELECT OrderID, DATEDIFF(DAY,OrderDate,RequiredDate)[Teslim Tarihi] from Orders

----------------------------------------------------------------------------------------------------------------------------------------------

--21.Sipariş verilip de stoğumun yetersiz olduğu ürünler hangisidir? 
--Bu ürünlerden kaç tane eksiğim vardır?
SELECT ProductID,ProductName,Quantity-UnitsInStock[Eksik Miktar] FROM(
SELECT p.ProductID,p.ProductName,od.Quantity,UnitsInStock FROM Orders o 
	JOIN [Order Details] od on o.OrderID=od.OrderID
	JOIN Products p on p.ProductID=od.ProductID 
	WHERE Quantity>UnitsInStock 
		group by p.ProductID,p.ProductName,od.Quantity,UnitsInStock)TABLO
