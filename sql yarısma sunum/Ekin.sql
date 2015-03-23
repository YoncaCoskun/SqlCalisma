use FilmDukkani

--Filme ait ödülleri listeler
create procedure FilmOdulleri
@flmId int
as
select * 
from
(select oa.OdulAdi, ok.OdulKategori, fo.Açýklama, fo.KazandiMi
from Film f join FilmOdul fo on f.FilmId=fo.FilmId
			join OdulKategori ok on ok.OdulKategoriId=fo.OdulKategoriId
			join OdulAdi oa on oa.OdulAdiId=fo.OdulAdiId
where f.FilmId = @flmId) T1
union
(select oa.OdulAdi, ok.OdulKategori, OyuncuAdi + ' ' + OyuncuSoyadi Oyuncu,  oo.KazandiMi
from Film f join OdulOyuncu oo on oo.FilmId=f.FilmId
			join Oyuncu o on o.OyuncuId=oo.OyuncuId
			join OdulKategori ok on ok.OdulKategoriId=oo.OdulKategoriId
			join OdulAdi oa on oa.OdulAdiId=oo.OdulAdiId
where f.FilmId = @flmId)
order by KazandiMi desc
			
exec FilmOdulleri 13

go
--Detaylý arama
create procedure DetayliArama
@oyuncu nvarchar(20),
@yonetmen nvarchar(20),
@yil varchar(4),
@kategori varchar(20)
as
select distinct f.FilmAdi 
from Film f join FilmOyuncu fo on fo.FilmId=f.FilmId join FilmYonetmen fy on fy.FilmId=f.FilmId
			join Oyuncu o on fo.OyuncuId=o.OyuncuId join Oyuncu	y on fy.OyuncuId=y.OyuncuId
			join FilmKategori fk on fk.FilmId=f.FilmId join Kategori k on k.KategoriId=fk.KategoriId
where y.OyuncuAdi like @yonetmen+'%' AND o.OyuncuAdi like @oyuncu+'%' AND
	  CAST(year(f.YayinlanmaTarihi) as char(4)) like @yil+'%' AND k.KategoriAdi like @kategori+'%'

exec DetayliArama 'Al','','',''

go
-- DurumId sütunu teslim olarak deðiþtirildiðinde otomatik olarak teslim tarihini giren trigger
create trigger IstekTeslimTarihi
on Siparis
for update
as
update Siparis set TeslimTarihi =  convert(date,GETDATE())
		  where SiparisId =	(select SiparisId from inserted) AND
				(select DurumId from inserted) in (3,6) AND
				(select DurumId from deleted) != (select DurumId from inserted)

go
--Çýkýþ yapýlan ürünü stoktan düþüren trigger
create trigger StokCikis
on DepoHareket
for insert
as
update Stok set Durum = 0
	where StokId = (select StokId from inserted) AND (select HareketCesidiId from inserted) in (2,5)

