/* 
Cleaning Data in SQL Queries
*/

SELECT *
FROM PorfolioProject..NashvilleHousing
----------------------------------------------------------------------------------

-- Standardize Date Format (SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PorfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

----------------------------------------------------------------------------------
-- Populate Property Address data (PropertyAddress)

SELECT *
FROM PorfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT *
FROM PorfolioProject..NashvilleHousing


SELECT a.ParcelID,
		a.PropertyAddress,
		b.ParcelID,
		b.PropertyAddress,
		ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PorfolioProject..NashvilleHousing AS a
JOIN PorfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PorfolioProject..NashvilleHousing AS a
JOIN PorfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
----------------------------------------------------------------------------------
--Breaking oit Adress into Individual Columns (Adress, City, state)

SELECT PropertyAddress
FROM PorfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM PorfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--Check back
SELECT *
FROM PorfolioProject..NashvilleHousing

-- Individual Address
Select OwnerAddress
From PorfolioProject..NashvilleHousing

--REPLACE "," that mean we look for the comma in there &  "." made it change into period

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PorfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Let's check again 
Select *
From PorfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PorfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PorfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

----------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PorfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From PorfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------
-- Delete Unused Columns
Select *
From PorfolioProject.dbo.NashvilleHousing


ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
