-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022 

-- STEP 1 (Ephemeral Storage) 
-- Create a staging table. (For redundancies in case we run into issues while cleaning) 
-- Staging table creation was because the data needed to be validated and transformed before being loaded into the main table.

CREATE TABLE world_layoffs.layoffs_staging  -- creates a new table 
LIKE world_layoffs.layoffs; -- this clause copies the structure (schema) of the existing table world_layoffs.layoffs

-- STEP 2
-- Update table with data from 
INSERT layoffs_staging -- specifies the target table
SELECT * FROM world_layoffs.layoffs; -- selects all the data (all columns and rows) from the world_layoffs.layoffs table

-- DATA CLEANING PROCEDURE -- 
-- To clean the Data we apply the below steps 
-- 1. Check and remove duplicates, if any 
-- 2. Standardize data and Fix any existing errors 
-- 3. Look out for NULLs in the dataset, 
-- 4. Normalize the data (Remove unnecessary rows or columns) 

-- 1. CHECK AND REMOVE DUPLICATES

SELECT * -- shows a list of all fields and records in the table  
FROM world_layoffs.layoffs_staging
LIMIT 100 
;

  SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER ( 
			PARTITION BY company, industry, total_laid_off,`date`) AS row_num -- The row_num  helps identify duplicate records within the same group \
	FROM 
		world_layoffs.layoffs_staging;


SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;

-- Review ODA to confirm 
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda' ;


-- The query below returns duplicate values in every column 

SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;

-- To delete these duplicates we can add a column to show the row_num, and this will allow us, delete all records where row_num > 2 

ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT; -- adds a new field 

SELECT *
FROM world_layoffs.layoffs_staging -- confirm changes to table 
  ; 


CREATE TABLE `world_layoffs`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
  
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging;



-- To delete records with row_num > 2 

DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;


-- 2. STANDARDIZE THE DATA 

SELECT * 
FROM world_layoffs.layoffs_staging2; 

-- There seem to be some NULL values in Industry 

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry; -- this query returns all records with Industry NULL 

-- Airbnb has null values  

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'airbnb%';

-- It seems that the values were just not filled looking at categorization 
-- To resolve this let's write a query to update records with the same company name with the non-null industry value



-- Set Blanks to NULL 

UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Confirm that changes have been applied 

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;


-- To populate the nulls 

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


--  Bally's was the only one without a populated row to populate the null values
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- There seems to be multiple variations in the Crypto Industry field 
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency'); -- Changes records with either ('Crypto Currency' or 'CryptoCurrency') into Crypto

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry; -- Confirm Changes


-- There seems to be 2 variations of 'United States' with a period and without, Let's standardize that  

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Confirm changes 
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;


-- Fixing the Date column 
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Convert data-type to DATE 
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; 

SELECT *
FROM world_layoffs.layoffs_staging2; -- confirm changes 


-- ## 3. SEARCH OUT NULLS ##
-- After working on the NULLs with the Industry and Updating the table, only total_laid_off, percentage_laid_off, and funds_raised_millions have NULL values 
-- This will assist in making calculations easier, if we want to carry out EDA


-- NORMALIZE DATA 

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


--Delete redundant columns

DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM world_layoffs.layoffs_staging2; -- confirm changes 

-- Delete the ROW_NUM column 

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * 
FROM world_layoffs.layoffs_staging2; -- confirm chnages 




