# 🛠️ SQL Data Cleaning: 2022 Layoffs Dataset  

## 📌 Project Overview  
This project focuses on **cleaning and standardizing** the **2022 Layoffs Dataset** from [Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022).  
The dataset provides insights into **global layoffs** across industries, including details like:  
📌 Company | Location | Industry | Total Laid Off | % Laid Off | Funding Raised | Date  

### **🔍 Key Objectives**  
✅ Remove duplicate records  
✅ Handle missing and inconsistent data  
✅ Standardize text and date formats  
✅ Ensure data integrity for accurate analysis  

---

## 🏗️ Data Issues & Fixes  

### **1 Duplicate Records**  
- Identified and removed exact duplicates using `ROW_NUMBER()`.  

### **2 Handling Missing Values**  
- **Industry** → Filled using data from the same company.  
- **Stage** → Replaced `NULL` values with `"Unknown"`.  
- **Total Laid Off & % Laid Off** → Kept only if at least one field had valid data.  
- **Funding Raised** → Left as `NULL` since not all companies raise funds.  

### **3 Standardization & Formatting**  
- **Industry Names** → Standardized variations (e.g., `"Crypto Currency"` → `"Crypto"`).  
- **Country Names** → Removed trailing dots and spaces.  
- **Date Format** → Converted from `MM/DD/YYYY` to `YYYY-MM-DD`.  

---

## 💾 SQL Query for Data Cleaning  

```sql
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
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '' OR industry IS NULL;

UPDATE layoffs_staging t1
SET t1.industry = t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2
ON t1.company = t2.company
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

UPDATE layoffs_staging
SET stage = 'Unknown'
WHERE stage IS NULL;

-- STEP 4: Standardize text data
UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- STEP 5: Convert and standardize date format
UPDATE layoffs_staging
SET date = STR_TO_DATE(date, '%m/%d/%Y'); 

ALTER TABLE layoffs_staging
MODIFY COLUMN date DATE;

-- STEP 6: Remove irrelevant rows with no useful layoff data
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- STEP 7: Review cleaned data
SELECT * FROM layoffs_staging;

