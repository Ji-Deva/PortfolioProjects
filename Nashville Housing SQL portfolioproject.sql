/*
cleaning data in sql
*/
select *
from SQLportfolioproject..Nashvillehousing

--standardize date format
select SaleDateConverted, CONVERT(date,SaleDate)
from SQLportfolioproject..Nashvillehousing

update Nashvillehousing
set SaleDate=CONVERT(date,SaleDate)
--altering table by adding new column
alter table Nashvillehousing
Add SaleDateConverted Date

update Nashvillehousing
set SaleDateConverted=CONVERT(date,SaleDate)


--populate property address

select *
from SQLportfolioproject..Nashvillehousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from SQLportfolioproject..Nashvillehousing as a
join SQLportfolioproject..Nashvillehousing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from SQLportfolioproject..Nashvillehousing as a
join SQLportfolioproject..Nashvillehousing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Splitting address into individual columns
--property address
select PropertyAddress
from SQLportfolioproject..Nashvillehousing
--where PropertyAddress is null
--order by ParcelID

select 
substring(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1) as Address
,substring(PropertyAddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress)) as City
from SQLportfolioproject..Nashvillehousing

--altering table

alter table Nashvillehousing
Add PropertyAddressNew nvarchar(255)

update Nashvillehousing
set PropertyAddressNew=substring(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1)

alter table Nashvillehousing
Add PropertyCity nvarchar(255)

update Nashvillehousing
set PropertyCity=substring(PropertyAddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))

select *
from SQLportfolioproject..Nashvillehousing
--owner address
select OwnerAddress
from SQLportfolioproject..Nashvillehousing

select
PARSENAME(replace(owneraddress,',','.'),3)
,PARSENAME(replace(owneraddress,',','.'),2)
,PARSENAME(replace(owneraddress,',','.'),1)
from SQLportfolioproject..Nashvillehousing

--altering table

alter table Nashvillehousing
Add OwnerAddressNew nvarchar(255)

update Nashvillehousing
set OwnerAddressNew=PARSENAME(replace(owneraddress,',','.'),3)


alter table Nashvillehousing
Add OwnerCity nvarchar(255)

update Nashvillehousing
set OwnerCity=PARSENAME(replace(owneraddress,',','.'),2)

alter table Nashvillehousing
Add OwnerState nvarchar(255)

update Nashvillehousing
set OwnerState=PARSENAME(replace(owneraddress,',','.'),1)

-- change Y and N in sold as vacant field
--counting to see values
select distinct(SoldAsVacant),count(soldasvacant)
from SQLportfolioproject..Nashvillehousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,case when SoldAsVacant='Y' then 'Yes'
	  when SoldAsVacant='N' then 'No'
	  else SoldAsVacant
	  end
from SQLportfolioproject..Nashvillehousing
--updating soldasvacant field
update Nashvillehousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
	  when SoldAsVacant='N' then 'No'
	  else SoldAsVacant
	  end

--remove duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by Parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference 
				 order by uniqueid) as row_num
from SQLportfolioproject..Nashvillehousing
--order by ParcelID
)

delete
from RowNumCTE
where row_num>1
--order by PropertyAddress


--delete unused columns
select *
from SQLportfolioproject..Nashvillehousing

alter table SQLportfolioproject..Nashvillehousing
drop column owneraddress, propertyaddress, taxdistrict

alter table SQLportfolioproject..Nashvillehousing
drop column saledate