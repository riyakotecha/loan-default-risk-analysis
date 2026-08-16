# Loan Default Risk Analysis

## Project Overview

This project analyses a dataset of **148,670 mortgage loans** to identify borrower and loan characteristics associated with default risk.

The analysis was conducted using **Excel, PostgreSQL and Python**, combining dashboard-based exploratory analysis, SQL querying and Python data analysis to investigate individual risk factors, identify higher-risk segments and explore how multiple risk characteristics interact.

## Tools Used

- **Excel** – data analysis, PivotTables, calculated fields and dashboard visualisation
- **PostgreSQL / SQL** – querying, filtering, aggregation, CASE statements, CTEs and window functions
- **Python** – data cleaning, exploratory data analysis, risk segmentation and visualisation
- **Python libraries** – Pandas, NumPy, Matplotlib and Seaborn

---

## Excel Dashboard

The Excel dashboard provides an overview of the loan portfolio and explores how default rates vary across several borrower and loan characteristics.

![Loan Default Risk Dashboard](loan_dashboard.png)

### Dashboard Findings

- The portfolio contains **148,670 loans**.
- **36,639 loans defaulted**, giving an overall default rate of approximately **24.6%**.
- The **North-East** had the highest regional default rate.
- Loans with **LTV above 100%** had a substantially higher default rate.
- Default rates varied relatively little across credit score bands.
- DTI bands showed considerable differences in default rates.

---

## SQL Analysis

The SQL analysis extends the dashboard by investigating additional potential risk factors and relationships within the loan portfolio.

The analysis includes:

- Portfolio-level default analysis
- Credit score and LTV analysis
- Income quartile analysis
- Loan purpose and loan type analysis
- Occupancy and loan term analysis
- Multi-factor risk segmentation

The full SQL analysis is available in [`loan_analysis.sql`](loan_analysis.sql).

### Key SQL Findings

Income showed a clear relationship with default risk. Borrowers in the **lowest income quartile** had a default rate of approximately **35.2%**, compared with **18.7%** for borrowers in the highest income quartile.

Loan type was also associated with default risk, with **Type 2 loans** displaying a substantially higher default rate than Type 1 and Type 3 loans.

Loans with terms between **21 and 25 years** had a particularly high default rate of approximately **53.7%**.

### SQL Multi-Factor Risk Segmentation

Based on the exploratory analysis, three characteristics were selected to construct a simple descriptive risk score:

- Lowest income quartile
- Type 2 loan
- Loan term between 21 and 25 years

Each loan received one point for each characteristic present.

| Risk Score | Total Loans | Default Rate |
|------------|------------:|-------------:|
| 0 | 97,055 | 19.85% |
| 1 | 42,486 | 30.75% |
| 2 | 8,879 | 46.50% |
| 3 | 250 | 72.40% |

Default rates increased substantially as additional risk characteristics were present, suggesting that combining multiple factors provides more useful risk segmentation than considering individual characteristics alone.

---

## Python Analysis

Python was used to extend the analysis by examining data quality, exploring individual risk factors and investigating combinations of characteristics associated with higher default rates.

The analysis includes:

- Missing-value and data-quality assessment
- Credit score analysis
- Loan-to-value (LTV) analysis
- Debt-to-income (DTI) analysis
- Loan type and loan purpose analysis
- Income and loan amount comparisons
- Combined risk-factor analysis
- Data visualisation using Matplotlib and Seaborn

The full Python analysis is available in [`python/loan_default_python_analysis.ipynb`](python/loan_default_python_analysis.ipynb).

### Key Python Findings

**Loan-to-value ratio was one of the strongest risk indicators identified.** Loans with an LTV above 100% had a default rate of approximately **65.1%**, compared with approximately **12.9%** for loans with an LTV between 60% and 80%.

**Loan type was also associated with default risk.** Type 2 loans had a default rate of approximately **34.5%**, compared with **22.8%** for Type 1 and **25.1%** for Type 3 loans.

**Loan purpose P2** had the highest default rate among the loan-purpose categories at approximately **33.1%**.

Credit score bands showed relatively similar default rates, ranging from approximately **24.3% to 25.2%**. This suggests that credit score alone was not a strong discriminator of default risk within this dataset.

Borrowers who defaulted also had lower average and median income than non-defaulting borrowers, suggesting that borrower income may provide additional information when assessing risk.

### Python Combined Risk-Factor Analysis

Three characteristics identified during the exploratory analysis were combined:

- **High LTV:** LTV greater than 100%
- **High DTI:** DTI greater than 50
- **High-Risk Loan Type:** Type 2 loan

Loans with missing LTV or DTI values were excluded from this analysis so that each observation could be consistently assessed against all three factors, leaving **124,547 loans**.

The analysis showed substantial differences in default rates across risk-factor combinations.

| Risk Combination | Loans | Default Rate |
|------------------|------:|-------------:|
| No Selected Risk Factors | 104,137 | 12.5% |
| Type 2 | 10,612 | 26.1% |
| High DTI + Type 2 | 3,921 | 28.1% |
| High LTV + High DTI | 266 | 45.1% |
| High DTI | 4,372 | 54.6% |
| High LTV | 900 | 61.0% |
| High LTV + Type 2 | 259 | 100.0% |
| High LTV + High DTI + Type 2 | 80 | 100.0% |

The results indicate that **high LTV is particularly associated with elevated default risk**, while combinations of multiple risk characteristics can identify smaller segments with very high observed default rates.

The 100% default rates observed for some combinations should be interpreted cautiously because these groups contain relatively small numbers of loans.

---

## Key Project Findings

Across the Excel, SQL and Python analyses, several patterns consistently emerged:

- **Very high LTV is strongly associated with default risk**, with loans above 100% LTV showing substantially higher default rates.
- **Type 2 loans consistently display higher default rates** than Type 1 and Type 3 loans.
- **Income is associated with default risk**, with lower-income borrowers showing higher default rates in the SQL analysis.
- **Credit score alone provides limited separation** between default and non-default risk in this dataset.
- Combining multiple borrower and loan characteristics can identify **higher-risk segments that may not be apparent when analysing individual variables alone**.

---

## Skills Demonstrated

### Excel
- Exploratory data analysis
- PivotTables
- Calculated fields and metrics
- Interactive dashboard development
- Data visualisation

### SQL
- Data querying and filtering
- Aggregate functions
- `CASE` statements
- Common Table Expressions (CTEs)
- Window functions
- `NTILE()`
- Risk segmentation

### Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
- Data cleaning
- Missing-value analysis
- Grouping and aggregation
- Feature engineering
- Risk-factor segmentation
- Data visualisation

### Analytical Skills
- Exploratory data analysis
- Credit-risk analysis
- Identifying patterns and risk drivers
- Comparing borrower and loan segments
- Interpreting analytical results
- Translating analysis into business insights

---

## Limitations

The analyses in this project are **descriptive rather than validated predictive models**. Relationships identified between borrower or loan characteristics and default should therefore be interpreted as associations rather than evidence of causation.

The risk factors were selected using patterns observed within the same dataset on which they were subsequently evaluated. Further validation using unseen data would be required before using these results for lending or credit-risk decisions.

Some variables contain missing, extreme or unusual values, particularly LTV, while several categorical variables use coded labels whose underlying business definitions would need to be confirmed.

Some of the highest observed default rates also occur in relatively small borrower segments and should therefore be interpreted cautiously.

---

## Future Development

Potential extensions to this project include:

- Developing an interactive **Power BI dashboard**
- Investigating correlations and relationships between additional variables
- Building and evaluating a **predictive classification model**
- Comparing model performance using appropriate classification metrics
- Testing the stability of identified risk factors on unseen data
