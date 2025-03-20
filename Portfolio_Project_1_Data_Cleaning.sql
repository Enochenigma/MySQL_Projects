-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022 

-- STEP 1 
-- Create a staging table. (in case we run into issues while cleaning) 
-- Staging table creation was because the data needed to be validated and transformed before being loaded into the main table.

-- STEP 1: Create a staging table for safe data transformation
CREATE TABLE layoffs_staging AS
SELECT * FROM layoffs;

-- STEP 2: Remove exact duplicate records
DELETE FROM layoffs_staging
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM layoffs_staging
    GROUP BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
);

-- STEP 3: Handle missing values

-- Convert empty 'industry' values to NULL
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '' OR industry IS NULL;

-- Fill missing industry values using the same company's existing data
UPDATE layoffs_staging t1
SET t1.industry = t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2
ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Set missing 'stage' values to 'Unknown'
UPDATE layoffs_staging
SET stage = 'Unknown'
WHERE stage IS NULL;

-- STEP 4: Standardize text data

-- Remove trailing dots from country names
UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);

-- Standardize 'Crypto' industry name
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- STEP 5: Convert and standardize date format
UPDATE layoffs_staging
SET date = STR_TO_DATE(date, '%m/%d/%Y'); 

ALTER TABLE layoffs_staging
MODIFY COLUMN date DATE;

-- STEP 6: Remove irrelevant rows where no useful layoff data exists
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- STEP 7: Review cleaned data
SELECT * FROM layoffs_staging;

