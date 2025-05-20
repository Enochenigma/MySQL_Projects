# 🛠️ SQL Data Cleaning: 2022 Layoffs Dataset  

## 📌 Project Overview  
This project focuses on **cleaning and standardizing** the **2022 Layoffs Dataset** from [Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022).  
The dataset provides insights into **global layoffs** across industries, including details like:  
📌 Company | Location | Industry | Total Laid Off | % Laid Off | Funding Raised | Date  

---

## 📂 File

- `layoffs_data_cleaning.sql` – Main SQL script for transforming raw layoff data.

---

## ✅ Cleaning Steps

1. **Create a staging table**  
   - Makes a working copy of the raw `layoffs` table (`layoffs_staging`).

2. **Remove duplicate rows**  
   - Uses `ROW_NUMBER()` to eliminate exact duplicates based on key columns.

3. **Handle missing values**  
   - Replaces empty or null values in the `industry` and `stage` columns.
   - Fills missing industries by inferring from the same company.

4. **Standardize text fields**  
   - Removes trailing punctuation in `country`.
   - Normalizes variations of the "Crypto" industry label.

5. **Convert date formats**  
   - Converts `date` strings to `DATE` data type using `TRY_CAST`.

6. **Drop irrelevant rows**  
   - Removes records with no layoff data (`total_laid_off` and `percentage_laid_off` both null).

7. **Create a cleaned table**  
   - Outputs results to a new permanent table: `layoffs_cleaned`.

8. **Create index (optional)**  
   - Adds a nonclustered index on `company` and `date` to optimize query performance.

---

## 📊 Integration with Visualization Tools

You can connect the `layoffs_cleaned` table to BI tools like:

- **Power BI**
  - Use *Get Data > SQL Server*
  - Choose *DirectQuery* or *Import* mode
- **Tableau**
  - Use *Connect > Microsoft SQL Server*

---

## ⚙ Requirements

- SQL Server 2012 or later (for `TRY_CAST` and `ROW_NUMBER`)
- Raw data stored in a table named `layoffs`

---

## 🔁 Optional Extensions

- Automate refresh using SQL Server Agent ( Creating a stored procedure) 
- Join other company details that give more insight into layoffs like (COmpany financials & sector data)
- Publish a live dashboard with Power BI or Tableau

---

## Author

Created by Sanni Eshiofuneh   
Business Intelligence | Data Analysis | SQL Automation



