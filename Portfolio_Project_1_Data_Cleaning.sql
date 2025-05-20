-- SQL Project - Data Cleaning

-- ==========================================
-- Layoffs Data Cleaning Script (SQL Server)
-- ==========================================

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022 

-- STEP 1: Create a staging table for safe data transformation
SELECT * INTO layoffs_staging FROM layoffs;

-- STEP 2: Remove exact duplicate records using ROW_NUMBER
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM layoffs_staging
)
DELETE FROM CTE WHERE rn > 1;

-- STEP 3: Handle missing values

-- Replace empty or NULL industry with NULL
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '' OR industry IS NULL;

-- Fill missing industries using other rows from the same company
UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2
  ON t1.company = t2.company
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Replace NULL in stage with 'Unknown'
UPDATE layoffs_staging
SET stage = 'Unknown'
WHERE stage IS NULL;

-- STEP 4: Standardize text data

-- Remove trailing period from country names
UPDATE layoffs_staging
SET country = 
    CASE 
        WHEN RIGHT(country, 1) = '.' THEN LEFT(country, LEN(country) - 1)
        ELSE country
    END;

-- Normalize crypto industry naming
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- STEP 5: Convert and standardize date format

-- Convert string to DATE using TRY_CAST
UPDATE layoffs_staging
SET date = TRY_CAST(date AS DATE);

-- Alter column type to DATE (if needed)
ALTER TABLE layoffs_staging
ALTER COLUMN date DATE;

-- STEP 6: Remove rows with no layoff data
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- STEP 7: Create a permanent cleaned table
IF OBJECT_ID('dbo.layoffs_cleaned', 'U') IS NOT NULL
    DROP TABLE dbo.layoffs_cleaned;

SELECT * INTO dbo.layoffs_cleaned FROM layoffs_staging;

-- (Optional) STEP 8: Create an index to improve performance
CREATE NONCLUSTERED INDEX idx_company_date ON dbo.layoffs_cleaned(company, date);

-- STEP 9: Review final cleaned data
SELECT * FROM dbo.layoffs_cleaned;

