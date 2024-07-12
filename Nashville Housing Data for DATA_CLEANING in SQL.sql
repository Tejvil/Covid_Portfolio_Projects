--CLEANING DATA IN SQL QUERY

select * from PortfolioProject..NashvilleHousing;






-- Standerdize Date Format

select SaleDateConverted, CONVERT(date,SaleDate)
from PortfolioProject..NashvilleHousing;

UPDATE PortfolioProject.dbo.NashvilleHousing 
set SaleDate = CONVERT(date,SaleDate);

Alter table NashvilleHousing
add SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing 
set SaleDateConverted = CONVERT(date,SaleDate);











-- Populate Property Address Date

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,  b.PropertyAddress )
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

Update a 
set PropertyAddress = ISNULL (a.PropertyAddress,  b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;











--Breaking Out Address into Individual Columns (Adress, City, State)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address , 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing ;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing 
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress));









--Spliting Owners Address
select OwnerAddress
from PortfolioProject..NashvilleHousing;

select 
PARSENAME (Replace(OwnerAddress, ',', '.'), 3),
PARSENAME (Replace(OwnerAddress, ',', '.'), 2),
PARSENAME (Replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing 
SET OwnerSplitAddress = PARSENAME (Replace(OwnerAddress, ',', '.'), 3);

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing 
set OwnerSplitCity = PARSENAME (Replace(OwnerAddress, ',', '.'), 2);

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing 
set OwnerSplitState = PARSENAME (Replace(OwnerAddress, ',', '.'), 1);










--Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT distinct (SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing 
group by SoldAsVacant
order by 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from PortfolioProject.dbo.NashvilleHousing 

UPDATE PortfolioProject.dbo.NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;











-- Remove Duplicates

With RowNumCTE AS(
SELECT * ,
	Row_Number()over(
	Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID) row_num

from PortfolioProject.dbo.NashvilleHousing 
--order by ParcelID
)
--select * 
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress;







--DELETE unused data columns

alter table  PortfolioProject.dbo.NashvilleHousing 
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;




