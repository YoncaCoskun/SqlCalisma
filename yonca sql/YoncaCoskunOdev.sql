-------------16 Subat Odev Soru-Cevaplari(sp)--------------------------

--birim fiyatlarini d�sar�dan yollayab�lceg�m,gonderd�g�m
 --f�yatlar�n aras�ndak� urunler� gosteren bir sp yaz�n�z(sp:stored procedure)
-------------------------------------------------------------------------------------------------------------------------
ALTER procedure FiyatAraligi
@ilkFiyati varchar(50),
@sonFiyati varchar(50)
as
SELECT ProductID,ProductName,UnitPrice FROM  Products WHERE UnitPrice BETWEEN @ilkFiyati AND @sonFiyati

exec FiyatAraligi 5,20


----------------------------------------------------------------------------------------------------------------------------------
--en fazla sat�lan 6 urunu gosteren sp yaz�n
GO
alter procedure CokSatilanUrun
as
SELECT TOP 6* FROM Products ORDER BY UnitsOnOrder DESC
exec CokSatilanUrun


--------------------------------------------------------

-- en son sat�lan 6 urunumu gosteren sp yaz�n
ALTER procedure SonSatilanUrun
as
SELECT top 6*FROM
	(SELECT o.OrderID,o.OrderDate FROM Orders o group by o.OrderID,o.OrderDate)TABLO 
		order by OrderDate desc
EXEC SonSatilanUrun

-----------------------------------------------------------------------------

----id sini verd�g�m muster�m�n bana kac para kazand�rd�g�n� gosteren sp yaz�n
ALTER procedure KazancDurumu
@musteriId varchar(50)
as
SELECT CustomerID,CompanyName,[Kazanc] FROM
(SELECT c.CustomerID,c.CompanyName,SUM(od.UnitPrice*od.Quantity)[Kazanc] FROM Customers c 
	JOIN Orders o on c.CustomerID=o.CustomerID
	JOIN [Order Details] od on od.OrderID=o.OrderID group by c.CustomerID,c.CompanyName)TABLO WHERE CustomerID=@musteriId

exec KazancDurumu 'ALFKI'

----------------------------------------------------------------------------------------------------------------------

----baslang�c ve b�t�s sat�s aral�g�n� verd�g�m muster�m�n s�par�sler�n� goruntuleyen sp yaz�n
ALTER procedure MusteriSiparis
@baslangic date,
@bitis date
as
SELECT OrderID,CustomerID,OrderDate FROM Orders WHERE OrderDate BETWEEN @baslangic AND @bitis

exec MusteriSiparis '03.28.1997','03.31.1997'

---------------------------------------------------------------------------------------------------------------------------

----d�sar�dan verd�g�m tar�h aras�nda her bir cal�san�m�n bana kac para kazand�rd�g�n� gosteren bir sp yaz�n
ALTER procedure Cal�sanKazanc
@ilkTarih date,
@sonTarih date
as
SELECT distinct FirstName,LastName,SUM([Kazanc]) FROM
(SELECT e.FirstName,e.LastName,o.OrderDate, SUM(od.Quantity*od.UnitPrice)[Kazanc] FROM Employees e 
	JOIN Orders o on e.EmployeeID=o.EmployeeID
	JOIN [Order Details] od on od.OrderID=o.OrderID WHERE OrderDate BETWEEN @ilkTarih AND @sonTarih
	group by e.FirstName,e.LastName,o.OrderDate )TABLO  GROUP BY FirstName,LastName

exec Cal�sanKazanc '07.25.1996','09.17.1996'
	

----------------------------------------------------------------------------------------------------------

----d�sar�dan isim ve soy�s�m verd�g�m cal�san�m�n s�par�sler�n� hang� nakl�yec� tas�d�g�n� gosteren sp yaz�n
ALTER procedure Tas�nanSiparis
@Isim varchar(50),
@Soyisim varchar(50)
as
SELECT distinct FirstName,LastName,CompanyName FROM
(SELECT e.FirstName,e.LastName,s.CompanyName FROM Employees e 
	JOIN Orders o on e.EmployeeID=o.EmployeeID
	JOIN Shippers s on s.ShipperID=o.ShipVia)TABLO WHERE FirstName=@Isim and LastName=@Soyisim

exec Tas�nanSiparis 'nancy','davolio'

select * from Employees 
---------------------------------------------------------------------------------------------------------------------------	

