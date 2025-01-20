select * from [dbo].[Nashville Housing Data for Data Cleaning]


--------------------populate Property Address (Git red of Nulls)
  select * from [dbo].[Nashville Housing Data for Data Cleaning] 
 -- where PropertyAddress is null
  order by ParcelID


    select a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULl(a.PropertyAddress,b.PropertyAddress)
	from [dbo].[Nashville Housing Data for Data Cleaning] a
	join [dbo].[Nashville Housing Data for Data Cleaning] b 
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID] 
	where a.PropertyAddress is null 



	Update a 
	set PropertyAddress = ISNULl(a.PropertyAddress,b.PropertyAddress)
	from [dbo].[Nashville Housing Data for Data Cleaning] a
	join [dbo].[Nashville Housing Data for Data Cleaning] b 
	 on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID] 
	where a.PropertyAddress is null 

------------- Breaking out Address into Individual Columns (Address, City, State)

select propertyAddress 
from [dbo].[Nashville Housing Data for Data Cleaning] 

select 
SUBSTRING(propertyAddress,1,CharIndex(',',PropertyAddress) -1) as Address
, SUBSTRING(propertyAddress,CharIndex(',',PropertyAddress) +1 , len(propertyAddress)) as Address
from [dbo].[Nashville Housing Data for Data Cleaning] 

Alter table [dbo].[Nashville Housing Data for Data Cleaning] 
Add PropertySplitAddress Nvarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning] 
Set  PropertySplitAddress = SUBSTRING(propertyAddress,1,CharIndex(',',PropertyAddress) -1) 

Alter table [dbo].[Nashville Housing Data for Data Cleaning] 
Add PropertySplitCity Nvarchar(255);

Update [dbo].[Nashville Housing Data for Data Cleaning] 
Set  PropertySplitCity = SUBSTRING(propertyAddress,CharIndex(',',PropertyAddress) +1 , len(propertyAddress)) 

Select *
From [dbo].[Nashville Housing Data for Data Cleaning]



select ownerAddress
From [dbo].[Nashville Housing Data for Data Cleaning]

Select 
PARSENAME(Replace(OwnerAddress, ',' , '.' ) ,3)
,PARSENAME(Replace(OwnerAddress, ',' , '.' ) ,2)
,PARSENAME(Replace(OwnerAddress, ',' , '.' ) ,1)
From [dbo].[Nashville Housing Data for Data Cleaning]

Alter TABLE  [dbo].[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitAddress Nvarchar(255);

Update  [dbo].[Nashville Housing Data for Data Cleaning]
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',' , '.' ) ,3)

Alter TABLE  [dbo].[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitCity Nvarchar(255);

Update  [dbo].[Nashville Housing Data for Data Cleaning]
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',' , '.' ) ,2)

Alter TABLE  [dbo].[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitState Nvarchar(255);

Update  [dbo].[Nashville Housing Data for Data Cleaning]
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',' , '.' ) ,1)

Select *
From [dbo].[Nashville Housing Data for Data Cleaning]

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct (SoldAsVacant), count (SoldAsVacant)
From [dbo].[Nashville Housing Data for Data Cleaning]
group by SoldAsVacant
order by 2

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
ALTER COLUMN SoldAsVacant VARCHAR(3)  -- or another suitable length



SELECT 
    SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 1 THEN 'Yes'
        WHEN SoldAsVacant = 0 THEN 'No'
        ELSE 'Unknown' -- or NULL if you prefer to handle any NULLs
    END AS SoldAsVacantStatus
FROM [dbo].[Nashville Housing Data for Data Cleaning]

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE when SoldAsVacant = '1' then 'Yes'
                   when SoldAsVacant = '0' then 'No'
				   else SoldAsVacant
				   end 
-- Remove Duplicates


WITH ROWNUMCTE AS (
    SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM [dbo].[Nashville Housing Data for Data Cleaning]
)

SELECT * 
FROM ROWNUMCTE
WHERE row_num > 1
ORDER BY PropertyAddress;




select * FROM [dbo].[Nashville Housing Data for Data Cleaning]


-- Delete Unused Columns


ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select * FROM [dbo].[Nashville Housing Data for Data Cleaning]


