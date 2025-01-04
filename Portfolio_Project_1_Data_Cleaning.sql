-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022 

-- STEP 1 (Ephemeral Storage) 
-- Create a staging table. (For redundancies in case we run into issues while cleaning) 
-- Staging table creation was because the data needed to be validated and transformed before being loaded into the main table.

-- Step 1: Create a staging table and populate it with data
CREATE TABLE layoffs_staging AS
SELECT * FROM layoffs;

-- Step 2: Remove duplicate rows
WITH RowNumberCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
               ORDER BY company
           ) AS row_num
    FROM layoffs_staging
)
DELETE FROM layoffs_staging
WHERE EXISTS (
    SELECT 1
    FROM RowNumberCTE cte
    WHERE layoffs_staging.company = cte.company
      AND layoffs_staging.row_num > 1
);

-- Step 3: Handle nulls and standardize data
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '' OR industry IS NULL;

UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2
ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

UPDATE layoffs_staging
SET date = STR_TO_DATE(date, '%Y-%m-%d');

ALTER TABLE layoffs_staging
MODIFY COLUMN date DATE;

-- Step 4: Remove irrelevant rows
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Step 5: Review cleaned data
SELECT * FROM layoffs_staging;
