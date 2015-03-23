-------------16 Subat Odev Soru-Cevaplari(sp)--------------------------

--birim fiyatlarini dýsarýdan yollayabýlcegým,gonderdýgým
 --fýyatlarýn arasýndaký urunlerý gosteren bir sp yazýnýz(sp:stored procedure)
-------------------------------------------------------------------------------------------------------------------------
ALTER procedure FiyatAraligi
@ilkFiyati varchar(50),
@sonFiyati varchar(50)
as
SELECT ProductID,ProductName,UnitPrice FROM  Products WHERE UnitPrice BETWEEN @ilkFiyati AND @sonFiyati

exec FiyatAraligi 5,20


----------------------------------------------------------------------------------------------------------------------------------
--en fazla satýlan 6 urunu gosteren sp yazýn
GO
alter procedure CokSatilanUrun
as
SELECT TOP 6* FROM Products ORDER BY UnitsOnOrder DESC
exec CokSatilanUrun


--------------------------------------------------------

-- en son satýlan 6 urunumu gosteren sp yazýn
ALTER procedure SonSatilanUrun
as
SELECT top 6*FROM
	(SELECT o.OrderID,o.OrderDate FROM Orders o group by o.OrderID,o.OrderDate)TABLO 
		order by OrderDate desc
EXEC SonSatilanUrun

-----------------------------------------------------------------------------

----id sini verdýgým musterýmýn bana kac para kazandýrdýgýný gosteren sp yazýn
ALTER procedure KazancDurumu
@musteriId varchar(50)
as
SELECT CustomerID,CompanyName,[Kazanc] FROM
(SELECT c.CustomerID,c.CompanyName,SUM(od.UnitPrice*od.Quantity)[Kazanc] FROM Customers c 
	JOIN Orders o on c.CustomerID=o.CustomerID
	JOIN [Order Details] od on od.OrderID=o.OrderID group by c.CustomerID,c.CompanyName)TABLO WHERE CustomerID=@musteriId

exec KazancDurumu 'ALFKI'

----------------------------------------------------------------------------------------------------------------------

----baslangýc ve býtýs satýs aralýgýný verdýgým musterýmýn sýparýslerýný goruntuleyen sp yazýn
ALTER procedure MusteriSiparis
@baslangic date,
@bitis date
as
SELECT OrderID,CustomerID,OrderDate FROM Orders WHERE OrderDate BETWEEN @baslangic AND @bitis

exec MusteriSiparis '03.28.1997','03.31.1997'

---------------------------------------------------------------------------------------------------------------------------

----dýsarýdan verdýgým tarýh arasýnda her bir calýsanýmýn bana kac para kazandýrdýgýný gosteren bir sp yazýn
ALTER procedure CalýsanKazanc
@ilkTarih date,
@sonTarih date
as
SELECT distinct FirstName,LastName,SUM([Kazanc]) FROM
(SELECT e.FirstName,e.LastName,o.OrderDate, SUM(od.Quantity*od.UnitPrice)[Kazanc] FROM Employees e 
	JOIN Orders o on e.EmployeeID=o.EmployeeID
	JOIN [Order Details] od on od.OrderID=o.OrderID WHERE OrderDate BETWEEN @ilkTarih AND @sonTarih
	group by e.FirstName,e.LastName,o.OrderDate )TABLO  GROUP BY FirstName,LastName

exec CalýsanKazanc '07.25.1996','09.17.1996'
	

----------------------------------------------------------------------------------------------------------

----dýsarýdan isim ve soyýsým verdýgým calýsanýmýn sýparýslerýný hangý naklýyecý tasýdýgýný gosteren sp yazýn
ALTER procedure TasýnanSiparis
@Isim varchar(50),
@Soyisim varchar(50)
as
SELECT distinct FirstName,LastName,CompanyName FROM
(SELECT e.FirstName,e.LastName,s.CompanyName FROM Employees e 
	JOIN Orders o on e.EmployeeID=o.EmployeeID
	JOIN Shippers s on s.ShipperID=o.ShipVia)TABLO WHERE FirstName=@Isim and LastName=@Soyisim

exec TasýnanSiparis 'nancy','davolio'

select * from Employees 
---------------------------------------------------------------------------------------------------------------------------	

