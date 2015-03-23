-- SORGU Nasıl Çalışıyor.
-- Aşağıdakı sorgu IDsi elle girilen çalışanın en çok sattığı ürünü ve satışını listeler.
SELECT TOP 1 [EmployeeID], * FROM -- (A)
    (
        SELECT TOP 1000  * FROM (
        SELECT EmployeeID, ProductID,  FirstName, LastName, ProductName 
            ,(
            SELECT SUM (OD.Quantity * OD.UnitPrice)[Sale] FROM Orders O
                JOIN [Order Details] OD ON OD.OrderID = O.OrderID
                JOIN Products P ON P.ProductID = OD.ProductID
                WHERE EmployeeID = EE.EmployeeID AND P.ProductID = PP.ProductID
                GROUP BY P.ProductID
                )[Sale]
        FROM Employees EE
            CROSS JOIN Products PP
        )[Sale For Each Employee]
        ORDER BY [Sale] DESC
    )[Foo]
    WHERE EmployeeID = 1
---------------------------------------------------

-- Bize gereken ID'yi elle değil, Employees tablosundan gelen her bir ID için işlem yapmaktır.
-- Bunun için 3. tip Subquery kullanacağız.
-- 3. Tip Subquery'nin diğerlerinden farkı şudur:
-- [!!!] Sadece "1" sütun döndürebilirsiniz.
-- Hatırlayalım:

-- Çalışanın kime rapor verdiğini listeleyelim:
-- Bu tip sorgu her ne kadar JOIN ile daha kolay ve anlaşılır olsa da 
--3. tip Subquery'yi göstermek için anlaşılır bir örnektir.

SELECT FirstName, LastName, EmployeeID
    ,(
        SELECT ReportsTo FROM Employees  EE WHERE EE.EmployeeID = E.EmployeeID
    )[Kime Rapor Veriyor] -- Tek bir sütun döndüğüne dikkat edin.
FROM Employees E

-- İstersek aynı sorguya bir JOIN ilave ederek Üst yöneticinin adını soyadını da gösterebiliriz.
-- Rapor Verilen Kişinin adı ve soyadını JOIN ile gösterelim.
SELECT E.FirstName, E.LastName, E.EmployeeID
    ,(
        SELECT ReportsTo FROM Employees  EE WHERE EE.EmployeeID = E.EmployeeID
    )[Kime Rapor Veriyor] -- Tek bir sütun döndüğüne dikkat edin.
, R.FirstName, R.LastName
FROM Employees E
    LEFT JOIN Employees R ON R.EmployeeID = E.ReportsTo -- LEFT JOIN GEREKKLİ

-- (A) işaretli sorguya geri dönelim.
-- Yapacağımız iş, (A) işaretli sorguyu, 3. tip alt sorguya dönüştürmek.
-- Ve Her bir çalışan için 3 defa çalıştırmak.

-- 0. Çalışanın IDsi için.
-- 1. Çalışanın en fazla satış yaptığı ürün için
-- 2. Çalışanın bu üründen yaptığı satış için.

-- 3 defa çalıştırıyoruz çünkü 3. tip alt sorgu'da sadece 1 sütun dönebiliyor. Her bir sütun değeri için 
-- %99'u aynı olan 3 adet 3.tür alt sorgu çalıştıracağız.



-- Oynatalım: İlk sütunda EmployeeID olsun.
SELECT TOP 1 [EmployeeID] FROM 
    (
    --%--- Buradan seçip parça parça çalıştırabilirsiniz.
    -- Bu kısım her bir çalışanın bütün ürünlerler CROSS JOIN ile eşleştirir ve
    -- Her bir çalışan-ürün eşleştirmesi için toplam satış tutarlarını hesaplar
    -- Yukarıdaki `TOP 1` kısmı ise aşağıda  IDsi verilen çalışanın 
    -- En çok sattığı ürüne ait bilgiyi döndürür.
        SELECT TOP 1000  * FROM (
            SELECT EmployeeID, ProductID,  FirstName, LastName, ProductName 
                    -- Aslında buradaki `FirstName, LastName` kısmı gereksiz.
                    -- Çünkü yukarıda bu alanları kullanmadık. 
                    -- Çalışan ad-soyadı veya ProductID buradan çekilebileceği gibi, aşağıya yeni bir
                        -- JOIN Employees EMP2 ON EMP2.EmployeeID = ... eklenerek de yapılabilir.
                    -- Fakat buradan çekmek daha performanslı olsa gerek. Çünkü zaten bu bilgiler elimizde varken
                    -- Tekrar bir JOIN ile Employees tablosundan veri çekmek performans kaybına yol açacaktır.
                ,(
                SELECT SUM (OD.Quantity * OD.UnitPrice)[Sale] FROM Orders O
                    JOIN [Order Details] OD ON OD.OrderID = O.OrderID
                    JOIN Products P ON P.ProductID = OD.ProductID
                    WHERE EmployeeID = EE.EmployeeID AND P.ProductID = PP.ProductID
                    GROUP BY P.ProductID
                    )[Sale]
            FROM Employees EE
                CROSS JOIN Products PP
        )[Sale For Each Employee]
        ORDER BY [Sale] DESC
    --%--- Buradan seçip parça parça çalıştırabilirsiniz.
    )[Foo]
    WHERE EmployeeID = 1 -- EMP.EmployeeID "EMP.EmployeeID, 1'in yerine koyarak bu sorgunun her bir çalışan IDsi için çalışmasını sağlayacağız" 



-- Aynı sorgu sadece ilk satırda çalışan ID yerine ProductName geldi. Bu bilginin aşağıdaki (B) işaretli sorgudan geldiğine dikkat edin.
-- Yani bu sorguyu (B) satırında olan tüm sütunlar için (ProductID, FirstName, LastName, ProductName) için tekrarlayabilirdik.
SELECT TOP 1 [ProductName] FROM 
    (
    --%--- Buradan seçip parça parça çalıştırabilirsiniz.
        SELECT TOP 1000  * FROM (
            SELECT EmployeeID, ProductID,  FirstName, LastName, ProductName -- (B) 
                ,(
                SELECT SUM (OD.Quantity * OD.UnitPrice)[Sale] FROM Orders O
                    JOIN [Order Details] OD ON OD.OrderID = O.OrderID
                    JOIN Products P ON P.ProductID = OD.ProductID
                    WHERE EmployeeID = EE.EmployeeID AND P.ProductID = PP.ProductID
                    GROUP BY P.ProductID
                    )[Sale]
            FROM Employees EE
                CROSS JOIN Products PP
            )[Sale For Each Employee]
            ORDER BY [Sale] DESC
    --%--- Buradan seçip parça parça çalıştırabilirsiniz.
    )[Foo]
    WHERE EmployeeID = 1 -- EMP.EmployeeID


-- Çalışanın en çok sattığı ürünün toplam satış tutarının iste (C) satırındaki [Sale] değerinden alıyoruz.
SELECT TOP 1 [Sale] FROM 
    (
    --%--- Buradan seçip parça parça çalıştırabilirsiniz.
        SELECT TOP 1000  * FROM (
            SELECT EmployeeID, ProductID,  FirstName, LastName, ProductName -- (B) 
                ,(
                SELECT SUM (OD.Quantity * OD.UnitPrice)[Sale] FROM Orders O -- (C)
                    JOIN [Order Details] OD ON OD.OrderID = O.OrderID
                    JOIN Products P ON P.ProductID = OD.ProductID
                    WHERE EmployeeID = EE.EmployeeID AND P.ProductID = PP.ProductID
                    GROUP BY P.ProductID
                    )[Sale]
            FROM Employees EE
                CROSS JOIN Products PP
            )[Sale For Each Employee]
            ORDER BY [Sale] DESC
    --%--- Buradan seçip parça parça çalıştırabilirsiniz.
    )[Foo]
    WHERE EmployeeID = 1 -- EMP.EmployeeID





-- Yukarıdaki sorguları birleştirdiğimizde:
SELECT EmployeeID, FirstName, LastName
,(
SELECT TOP 1 [Sale] FROM
    (
        SELECT TOP 1000  * FROM (  -- TOP 1000 Koymazsak Subquery İçinde Order By kullanamayız.
                                   -- 1000 yerine gelecek veriden büyük herhangi bir sayı yazılması yeterli ve güvenli olur.
                                   -- TOP komutundan sonra daha küçük bir sayı kullanırsak ne olur?
                                   -- Nasıl olsa 9 çalışanımız ve 77 ürünümüz var diye TOP 100 kullandık
                                   -- Diyelim ki 1 nolu Çalışanımız bütün ürünlerde (77 adet ürünümüz var) en çok satışı yaptı.
                                   -- Ve 5 nolu çalışanımız da 40 üründe en çok satışı yaptı.
                                   -- TOP 100 ile gelen sorguda, sadece 1 ve 5 nolu çalışanın en çok sattığı ürünler listelenecektir.
                                   -- Bize her bir çalışan için tek bir ürün ve satış gerektiği için diğer çalışanlara ait satışlar, 
                                   -- 100'den sonra gelecek ve istediğimiz veriyi elde edemeyecektik.

        SELECT EmployeeID, ProductID,  FirstName, LastName, ProductName -- (B) 
            ,(
            SELECT SUM (OD.Quantity * OD.UnitPrice)[Sale] FROM Orders O
                JOIN [Order Details] OD ON OD.OrderID = O.OrderID
                JOIN Products P ON P.ProductID = OD.ProductID
                WHERE EmployeeID = EE.EmployeeID AND P.ProductID = PP.ProductID
                GROUP BY P.ProductID
                )[Sale]
        FROM Employees EE
            CROSS JOIN Products PP
        )[Sale For Each Employee]
        ORDER BY [Sale] DESC
    )[Foo]
    WHERE EmployeeID = EMP.EmployeeID
)[Sale] -- Burada bir isim vermek mecburi değil. Yani [Sale] değeri olmasa da sorgu çalışır. Sadece sütun ismi gözükmez.

,(
SELECT TOP 1 [ProductName] FROM
    (
        SELECT TOP 1000  * FROM (
            SELECT EmployeeID, ProductID,  FirstName, LastName, ProductName 
                ,(
                SELECT SUM (OD.Quantity * OD.UnitPrice)[Sale] FROM Orders O
                    JOIN [Order Details] OD ON OD.OrderID = O.OrderID
                    JOIN Products P ON P.ProductID = OD.ProductID
                    WHERE EmployeeID = EE.EmployeeID AND P.ProductID = PP.ProductID
                    GROUP BY P.ProductID
                    )[Sale]
            FROM Employees EE
                CROSS JOIN Products PP
            )[Sale For Each Employee]
            ORDER BY [Sale] DESC
        )[Foo]
        WHERE EmployeeID = EMP.EmployeeID
)[Product]
 FROM Employees [EMP]
