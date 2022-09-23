Cleaning Data in SQL
*/

Standarize Date Format
*/
select SaleDate, CONVERT(Date, SaleDate) AS Date
FROM [PortfolioProject].[dbo].[nash]

Update [PortfolioProject].[dbo].[nash]
set SaleDate = CONVERT(Date, SaleDate)

--Populate Property Address data

select *
FROM [PortfolioProject].[dbo].[nash]
--where PropertyAddress is null
order by [ParcelID]

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].[dbo].[nash] a
join [PortfolioProject].[dbo].[nash] b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].[dbo].[nash] a
join [PortfolioProject].[dbo].[nash] b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into Individual Colums (Address, City, State)

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address --How to remove ,
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress)) as Address --How to remove .
FROM [PortfolioProject].[dbo].[nash]

ALTER TABLE [PortfolioProject].[dbo].[nash]
Add SalesDateConverted Date;

Update [PortfolioProject].[dbo].[nash]
SET SalesDateConverted = CONVERT(Date, SaleDate)


ALTER TABLE [PortfolioProject].[dbo].[nash]
Add PropertySplitAddress Nvarchar(255);

Update [PortfolioProject].[dbo].[nash]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [PortfolioProject].[dbo].[nash]
Add PropertySplitCity Nvarchar(255);

Update [PortfolioProject].[dbo].[nash]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress))


--How to split colums for Address, City, State

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Street
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as State
From [PortfolioProject].[dbo].[nash]


ALTER TABLE [PortfolioProject].[dbo].[nash]
Add OwnerSplitAddress Nvarchar(255);

Update [PortfolioProject].[dbo].[nash]
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [PortfolioProject].[dbo].[nash]
Add OwnerSplitCity Nvarchar(255);

Update [PortfolioProject].[dbo].[nash]
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [PortfolioProject].[dbo].[nash]
Add OwnerSplitState Nvarchar(255);

Update [PortfolioProject].[dbo].[nash]
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct SoldAsVacant, Count(SoldAsVacant)
 From [PortfolioProject].[dbo].[nash]
 Group by SoldAsVacant
 order by 2


select SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 End
From [PortfolioProject].[dbo].[nash]

Update [PortfolioProject].[dbo].[nash]
Set SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 End

	 -- Remove duplicates

	 WITH RowNumCTE AS(
	 select *, 
	 ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
				  UniqueID
				  ) row_num
 From [PortfolioProject].[dbo].[nash]
 )
 Select *
 From RowNumCTE
 Where row_num > 1
 Order by PropertyAddress


 --Delete Unused Colums

 Select *
 From [PortfolioProject].[dbo].[nash]

 ALTER TABLE [PortfolioProject].[dbo].[nash]
 DROP COLUMN [OwnerAddress], [TaxDistrict], [PropertyAddress], [SaleDate]
