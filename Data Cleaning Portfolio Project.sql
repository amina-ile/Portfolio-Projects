/*

Data Cleaning

*/

SELECT *
FROM
PortfolioProject..MadisonHousing

-- Change Saledate format


SELECT SaleDateConverted
FROM
PortfolioProject..MadisonHousing

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM
PortfolioProject..MadisonHousing

ALTER TABLE PortfolioProject..MadisonHousing
ADD SaleDateConverted Date


UPDATE PortfolioProject..MadisonHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDate, SaleDateConverted
FROM
PortfolioProject..MadisonHousing


-- Populate Property Address with Data from Duplicated records

SELECT PropertyAddress
FROM PortfolioProject..MadisonHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT *
FROM PortfolioProject..MadisonHousing a
JOIN PortfolioProject..MadisonHousing b
ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..MadisonHousing a
JOIN PortfolioProject..MadisonHousing b
ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

UPDATE a
SET propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	PortfolioProject..MadisonHousing a
JOIN PortfolioProject..MadisonHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL
	
-- Splitting Property address into address, city, state

SELECT PropertyAddress
FROM PortfolioProject..MadisonHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..MadisonHousing

ALTER TABLE PortfolioProject..MadisonHousing
ADD PropertySplitAddress nvarchar(255);

SELECT PropertySplitAddress
FROM PortfolioProject..MadisonHousing

UPDATE PortfolioProject..MadisonHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject..MadisonHousing
ADD propertySplitCity nvarchar (255);

SELECT propertySplitCity
FROM PortfolioProject..MadisonHousing

UPDATE PortfolioProject..MadisonHousing
SET propertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))


-- Splitting Owner address into address, city, state

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME (REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME (REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..MadisonHousing

ALTER TABLE PortfolioProject..MadisonHousing
ADD ownerSplitAddress nvarchar (255);

UPDATE PortfolioProject..MadisonHousing
SET ownerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE PortfolioProject..MadisonHousing
ADD ownerSplitCity nvarchar (255);

UPDATE PortfolioProject..MadisonHousing
SET ownerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE PortfolioProject..MadisonHousing
ADD ownerSplitState nvarchar (255);

UPDATE PortfolioProject..MadisonHousing
SET ownerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'),1)


-- Change Y and N to Yes and No

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM
PortfolioProject..MadisonHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
	FROM
PortfolioProject..MadisonHousing

UPDATE PortfolioProject..MadisonHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-- Find and remove duplicate rows

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num
FROM
PortfolioProject..MadisonHousing
ORDER BY ParcelID

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num
FROM
PortfolioProject..MadisonHousing
--ORDER BY ParcelID
)

--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1

DELETE 
FROM RowNumCTE
WHERE row_num > 1

--Remove unused Colums
SELECT *
FROM PortfolioProject..MadisonHousing

ALTER TABLE PortfolioProject..MadisonHousing
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress
