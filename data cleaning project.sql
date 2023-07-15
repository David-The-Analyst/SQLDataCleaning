/*
CLEANING DATA IN SQL QUERIES FOR A HOUSING DATA
*/
--------------------------------------------------------------------------------------------------------
-- STANDARDIZE DATE FORMAT

select SALESDATE
from NashvilleHousing;

ALTER TABLE NASHVILLEHOUSING
ADD SALESDATE DATE;

UPDATE NashvilleHousing
SET SALESDATE = CONVERT(DATE,SALEDATE)
--------------------------------------------------------------------------------------------------------
-- POPULATE PROPERTY ADDRESS DATA
select *
from NashvilleHousing

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

update a
set propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
	JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------
-----BREAKING UP THE FULL PROPERTY ADDRESS INTO ADDRESS AND CITY

alter table nashvillehousing
ADD propertysplitaddress nvarchar(255)


alter table nashvillehousing
ADD propertysplitcity nvarchar(255)

update NashvilleHousing
set propertysplitaddress = PARSENAME(REPLACE(propertyaddress,',','.'),2)

update NashvilleHousing
set propertysplitcity = PARSENAME(REPLACE(propertyaddress,',','.'),1)
----------------------------------------------------------------------------------------------------------
-----BREAKING UP THE OWNERS ADDRESS INTO ADDRESS,CITY,STATE

alter table nashvillehousing
ADD ownersplitaddress nvarchar(255)

alter table nashvillehousing
ADD ownersplitcity nvarchar(255)

alter table nashvillehousing
ADD ownersplitstate nvarchar(255)

update NashvilleHousing
set ownersplitaddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

update NashvilleHousing
set ownersplitcity = PARSENAME(REPLACE(owneraddress,',','.'),2)

update NashvilleHousing
set ownersplitstate = PARSENAME(REPLACE(owneraddress,',','.'),1)
-----------------------------------------------------------------------------------------------------------
-- CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	 WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
  ELSE SoldAsVacant
	 END

-----------------------------------------------------------------------------------------------------------
-- REMOVE DUPLICATES
with RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY PARCELID,
				 PROPERTYADDRESS,
				 SalePrice,
				 saledate,
				 legalreference
				 order by
				 uniqueid
				 ) row_num
FROM NashvilleHousing
)
delete 
FROM RowNumCTE
where row_num > 1
---------------------------------------------------------------------------------------------------------
-- DELETE UNUSED COLUMNS

ALTER TABLE NASHVILLEHOUSING
DROP COLUMN OWNERADDRESS,TAXDISTRICT,PROPERTYADDRESS

SELECT *
FROM NashvilleHousing
