--Data cleaning 
SELECT *
FROM [dbo].[nashville housingdata]

--Data standardize, to format the saledate column

SELECT saledate, CONVERT(Date, saledate)
FROM [dbo].[nashville housingdata]

UPDATE [dbo].[nashville housingdata]
SET SaleDate = CONVERT(Date, saledate)

--because it won't automatically update itself we can use alter (alter table can use to neither add, delete drop, modify, renamae)
ALTER TABLE [dbo].[nashville housingdata]
ADD saleDateConverted DATE;

UPDATE [dbo].[nashville housingdata]
SET saleDateConverted = CONVERT(Date, saledate)

SELECT SaleDateConverted
FROM [dbo].[nashville housingdata]

ALTER TABLE [dbo].[nashville housingdata]
DROP COLUMN SaleDate;

--UP NEXT, populate property address data
SELECT*
FROM [dbo].[nashville housingdata]
--WHERE PropertyAddress is NULL
-- we did a research to figure out why there's null in the propertyaddress and you'll notice that you have two identical parcelid with the
--same addresss and some wasn't repeated hence the NULL since the parcelid and propertyaddress is the same, we can modify the null by saying 
--if the two identical parcelid is there and one has address the other says null populate the former into the latter since it's the same.
--the below query shows how by self join
ORDER BY ParcelID



SELECT A.ParcelID, A.propertyaddress, B.ParcelID, B.PropertyAddress
FROM [dbo].[nashville housingdata] AS A
JOIN [dbo].[nashville housingdata] AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]  --WHat we are doing here is, saying where the parcelid is equal the parcelid but has a diff uniqueid cos they all do
WHERE A.PropertyAddress is null--you'll see null but on the right side, b side it's being corrected,so populate b into a 
--like this 
SELECT A.ParcelID, A.propertyaddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) AS Populatedpropertyaddress
FROM [dbo].[nashville housingdata] AS A
JOIN [dbo].[nashville housingdata] AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ] 
WHERE A.PropertyAddress is null--it's being populated on another column so we update

--BUT USING update in a join statement we use the alias rather than the table name itself 
UPDATE A
SET propertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [dbo].[nashville housingdata] AS A
JOIN [dbo].[nashville housingdata] AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ] 
WHERE A.PropertyAddress is null

SELECT *
FROM [dbo].[nashville housingdata]
WHERE PropertyAddress is null ---we no longer have any null that is good 

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY & STATE)
SELECT PropertyAddress
FROM [dbo].[nashville housingdata]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX (',',propertyAddress)) AS Address--using this query alone the minus wont get eliminated to eliminate it y
--you need to insert -1

FROM [dbo].[nashville housingdata]


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX (',',propertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX (',',propertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM [dbo].[nashville housingdata]

ALTER TABLE [dbo].[nashville housingdata]
ADD Propertyspiltaddress nvarchar(225);

UPDATE[dbo].[nashville housingdata]
SET Propertyspiltaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX (',',propertyAddress)-1)

ALTER TABLE [dbo].[nashville housingdata]
ADD Propertyspiltcity nvarchar(225); 


UPDATE [dbo].[nashville housingdata]
SET Propertyspiltcity = SUBSTRING(PropertyAddress, CHARINDEX (',',propertyAddress) +1 , LEN(PropertyAddress))

SELECT*
FROM [dbo].[nashville housingdata]

--NOW TO SPILT OWNER'S ADDRESS using a simple method
SELECT OwnerAddress
FROM[dbo].[nashville housingdata]--WE HAVEE THE ADDRESS, CITY AND STATE

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS OwnerspiltAddress --USING paresename it recognizes only periods(.) that's why we had to replace the comma with periods but it counts bacward i.e 1 picks the state use the numbers in reverse to get 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS Ownerspiltcity
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS Ownerspiltstate
FROM[dbo].[nashville housingdata]

ALTER TABLE [dbo].[nashville housingdata]
ADD OwnerspiltAddress NVARCHAR (225);

UPDATE[dbo].[nashville housingdata]
SET OwnerspiltAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE [dbo].[nashville housingdata]
ADD Ownerspiltcity NVARCHAR (225);

UPDATE [dbo].[nashville housingdata]
SET Ownerspiltcity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE [dbo].[nashville housingdata]
ADD Ownerspiltstate NVARCHAR (225);

UPDATE [dbo].[nashville housingdata]
SET Ownerspiltstate = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


--CHANGE N AND Y  TO YES AND  NO IN SOLDASVACANT FIELD
SELECT SoldAsVacant
FROM [dbo].[nashville housingdata]
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'n';

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM[dbo].[nashville housingdata]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE
	   WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
	   END AS Updatedsoldasvacant
FROM[dbo].[nashville housingdata]

UPDATE [dbo].[nashville housingdata]
SET SoldAsVacant = 
	CASE
	   WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
	   END 

--it's been changed now the field is free from y and n


--REMOVE DUPLICATES
WITH ROWNUMCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY parcelid,
				 propertyaddresS,
				 saleprice,
				 saledateconverted,
				 legalreference
				 ORDER BY
					UNIQUEID
					) AS ROW_NUM
FROM[dbo].[nashville housingdata]
--ORDER BY ParcelID
)
DELETE 
FROM ROWNUMCTE
WHERE ROW_NUM > 1
--ORDER BY PropertyAddress

--DELETE UNUSED COLUMNS
SELECT *
FROM[dbo].[nashville housingdata]

ALTER TABLE[dbo].[nashville housingdata]
DROP COLUMN Propertyaddress, owneraddress, taxdistrict

ALTER TABLE[dbo].[nashville housingdata]
DROP COLUMN  taxdistrict


ALTER TABLE [dbo].[nashville housingdata]
ADD  taxdistrict nvarchar (225);

CREATE VIEW someviews AS
SELECT  OwnerName, saleprice, saledateconverted,  YearBuilt, Propertyspiltcity,Propertyspiltaddress, LandUse
FROM [dbo].[nashville housingdata]

select *
from[dbo].[someviews]
