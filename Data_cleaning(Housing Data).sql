/*
Cleaning Data in SQL Queries
*/
---------------------------------------------------------------------

-- Standardize Date Format
SELECT 
    "SaleDate"
FROM 
    "Nashville_Housing_Data"

UPDATE
    "Nashville_Housing_Data"
SET 
    "SaleDate" =  to_date("SaleDate", 'MONTH/DD/YYYY')


--------------------------------------------------------------------

-- Populate Property Address data

SELECT 
    "PropertyAddress"
FROM 
    "Nashville_Housing_Data"

SELECT 
    *
FROM 
    "Nashville_Housing_Data"
WHERE 
    "PropertyAddress" IS NULL    
ORDER BY "ParcelID"



SELECT 
    "a"."ParcelID", "a"."PropertyAddress", "b"."ParcelID", "b"."PropertyAddress", COALESCE("a"."PropertyAddress", "b"."PropertyAddress") 
FROM 
    "Nashville_Housing_Data" a
JOIN     
    "Nashville_Housing_Data" b
ON 
    "a"."ParcelID" = "b"."ParcelID" AND
    "a"."UniqueID" <> "b"."UniqueID"    
WHERE 
    "a"."PropertyAddress" IS NULL


UPDATE 
    "Nashville_Housing_Data" 
SET 
    "PropertyAddress" = COALESCE("Nashville_Housing_Data"."PropertyAddress", "b"."PropertyAddress" )

FROM
    "Nashville_Housing_Data" b
WHERE
    "Nashville_Housing_Data"."ParcelID" = "b"."ParcelID" AND
    "Nashville_Housing_Data"."UniqueID" <> "b"."UniqueID" AND 
    "Nashville_Housing_Data"."PropertyAddress" IS NULL
   
--------------------------------------------------------------------

-- Breaking out Adrdress into Individual columns(Address, City, State)

SELECT 
    "PropertyAddress"
FROM 
    "Nashville_Housing_Data"
    
SELECT
    split_part( "PropertyAddress", ',', 1) AS "Address",
    split_part("PropertyAddress", ',', 2) AS "City"
FROM 
    "Nashville_Housing_Data"


ALTER TABLE 
    "Nashville_Housing_Data"
ADD 
    PropertySplitAddress VARCHAR(255)

UPDATE 
    "Nashville_Housing_Data"
SET
    PropertySplitAddress = split_part( "PropertyAddress", ',', 1)

    
    
ALTER TABLE 
    "Nashville_Housing_Data"
ADD 
    PropertySplitCity VARCHAR(255)

UPDATE
    "Nashville_Housing_Data"
SET
    PropertySplitCity = split_part( "PropertyAddress", ',', 2)    



SELECT 
    "OwnerAddress"
FROM 
    "Nashville_Housing_Data"

SELECT 
    split_part("OwnerAddress", ',', 1),
    split_part("OwnerAddress", ',', 2),
    split_part("OwnerAddress", ',', 3)
FROM 
    "Nashville_Housing_Data"




ALTER TABLE 
    "Nashville_Housing_Data"
ADD 
    OwnerSplitAddress VARCHAR(255)

UPDATE 
    "Nashville_Housing_Data"
SET
    OwnerSplitAddress = split_part( "OwnerAddress", ',', 1)

    
    
ALTER TABLE 
    "Nashville_Housing_Data"
ADD 
    OwnerSplitCity VARCHAR(255)

UPDATE
    "Nashville_Housing_Data"
SET
    OwnerSplitCity = split_part( "OwnerAddress", ',', 2) 


ALTER TABLE 
    "Nashville_Housing_Data"
ADD 
    OwnerSplitState VARCHAR(255)

UPDATE
    "Nashville_Housing_Data"
SET
    OwnerSplitState = split_part( "OwnerAddress", ',', 3); 
        
    




--------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold vs Vacant" field

SELECT DISTINCT
    "SoldAsVacant", count("SoldAsVacant")
FROM 
    "Nashville_Housing_Data"
GROUP BY
    "SoldAsVacant"
ORDER BY 2;    

SELECT 
    "SoldAsVacant",
CASE 
    WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
    WHEN "SoldAsVacant" = 'N' THEN 'No'
    ELSE "SoldAsVacant"
    END
FROM
    "Nashville_Housing_Data";

UPDATE 
    "Nashville_Housing_Data"
SET 
    "SoldAsVacant" = CASE 
    WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
    WHEN "SoldAsVacant" = 'N' THEN 'No'
    ELSE "SoldAsVacant"
    END;
 
    

--------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT
    *, 
    ROW_NUMBER() OVER (
    PARTITION BY "ParcelID",
                 "SalePrice",
                 "SaleDate",
                 "LegalReference"
                 ORDER BY 
                 "UniqueID"
                 ) row_num
    
FROM 
    "Nashville_Housing_Data"
), 

cte_subset AS ( 

SELECT * 
FROM 
    RowNumCTE
WHERE 
    row_num > 1
 )
DELETE FROM "Nashville_Housing_Data"
USING cte_subset
WHERE cte_subset."ParcelID" = "Nashville_Housing_Data"."ParcelID" 
-- order by
--     "PropertyAddress";



   
---------------------------------------------------------------------- Delete unused columns

SELECT 
    *
FROM
    "Nashville_Housing_Data"

ALTER TABLE
    "Nashville_Housing_Data"
DROP COLUMN
    "OwnerAddress",
DROP COLUMN
    "TaxDistrict",
DROP COLUMN    
    "PropertyAddress"
