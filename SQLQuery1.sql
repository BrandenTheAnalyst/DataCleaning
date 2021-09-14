/*

Cleaning data in SQL


SELECT * FROM NashvilleHousing..NashvilleHousing

*/

SELECT * FROM dbo.NashvilleHousing


--Standardize Date Format

SELECT SaleDate2, CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing 
ADD SaleDate2 Date;

UPDATE NashvilleHousing
SET SaleDate2 = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


--------------------------------------------------------------------------------------------

--Breaking Adress into individual columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD ConvertedAddress NVARCHAR(250);

UPDATE NashvilleHousing
SET ConvertedAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing 
ADD ConvertedCity NVARCHAR(250);

UPDATE NashvilleHousing
SET ConvertedCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing 
ADD ConvertedOwnerAddress NVARCHAR(100);

UPDATE NashvilleHousing
SET ConvertedOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing 
ADD ConvertedOwnerCity NVARCHAR(100);

UPDATE NashvilleHousing
SET ConvertedOwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing 
ADD ConvertedOwnerState NVARCHAR(100);

UPDATE NashvilleHousing
SET ConvertedOwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


---------------------------------------------------------------------------------------------------------

--Change Y to N to Yes to No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing..NashvilleHousing


UPDATE NashvilleHousing..NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

----------------------------------------------------------------------------------------------

--Removing Duplicates


WITH row_numCTE AS (
SELECT *, ROW_NUMBER () OVER (
		 PARTITION BY ParcelID,
					  PropertyAddress,
					  SalePrice,
					  SaleDate,
					  LegalReference
					  ORDER BY
						UniqueID
						)row_num
FROM NashvilleHousing..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM row_numCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--------------------------------------------------------------------------------------------------

--Delete Unused Columns



ALTER TABLE NashvilleHousing..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE NashvilleHousing..NashvilleHousing
DROP COLUMN SaleDate