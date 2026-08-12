-- SECTION 1: EXPLORATORY LOAN RISK ANALYSIS

-- 1.1 Dataset overview

-- Check number of records
SELECT COUNT(*) AS total_loans
FROM loan_default;

-- Preview dataset
SELECT *
FROM loan_default
LIMIT 10;

-- 1.2 Overall portfolio default risk

SELECT
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE status = 1) AS defaults,
    ROUND(
        COUNT(*) FILTER (WHERE status = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM loan_default;

-- The portfolio contains 148,670 loans, of which 36,639 defaulted.
-- This gives an overall default rate of approximately 24.64%.

-- 1.3 Credit score analysis

-- Compare average credit score for defaulted and non-defaulted loans
SELECT
    status,
    ROUND(AVG(credit_score), 2) AS average_credit_score
FROM loan_default
GROUP BY status
ORDER BY status;

-- 1.4 Loan-to-value (LTV) analysis

-- Compare average LTV for defaulted and non-defaulted loans
SELECT
    status,
    ROUND(AVG(ltv), 2) AS average_ltv
FROM loan_default
GROUP BY status
ORDER BY status;

-- Investigate the range of LTV values
SELECT
    ROUND(MIN(ltv), 2) AS minimum_ltv,
    ROUND(AVG(ltv), 2) AS average_ltv,
    ROUND(MAX(ltv), 2) AS maximum_ltv
FROM loan_default;

-- Investigate extreme LTV observations
SELECT
    id,
    loan_amount,
    property_value,
    ROUND(ltv, 2) AS ltv,
    status
FROM loan_default
WHERE ltv > 200
ORDER BY ltv DESC;

-- Interpretation:
-- Defaulted loans have a somewhat higher average LTV than non-defaulted loans,
-- suggesting that higher LTV may be associated with greater default risk.
-- However, the dataset contains extreme LTV values associated with unusually
-- low property values, so these observations should be treated with caution.

-- 1.5 Credit score band analysis

-- Compare default rates across credit score bands
SELECT
    CASE
        WHEN credit_score < 600 THEN 'Low'
        WHEN credit_score < 700 THEN 'Medium'
        WHEN credit_score < 800 THEN 'Good'
        ELSE 'Very Good'
    END AS credit_score_band,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE status = 1) AS defaults,
    ROUND(
        COUNT(*) FILTER (WHERE status = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM loan_default
GROUP BY credit_score_band
ORDER BY default_rate DESC;

-- Interpretation:
-- Default rates are relatively similar across the credit score bands,
-- with no clear decrease in default rate as credit score increases.
-- Credit score alone therefore does not appear to be a strong indicator
-- of default risk in this dataset.

-- 1.6 Income analysis

-- Compare average income for defaulted and non-defaulted borrowers
SELECT
    status,
    ROUND(AVG(income), 2) AS average_income
FROM loan_default
GROUP BY status
ORDER BY status;

-- Interpretation:
-- Borrowers who defaulted had a lower average income than borrowers who
-- did not default, suggesting that lower income may be associated with
-- greater default risk.

-- Examine the distribution of borrower income
SELECT
    MIN(income) AS minimum_income,
    ROUND(AVG(income), 2) AS average_income,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY income)::numeric,
        2
    ) AS median_income,
    MAX(income) AS maximum_income
FROM loan_default;

-- Interpretation:
-- Average income is higher than median income, indicating that the income
-- distribution is right-skewed by a relatively small number of high-income
-- borrowers.

-- Compare default rates across income quartiles
WITH income_groups AS (
    SELECT
        status,
        income,
        NTILE(4) OVER (ORDER BY income) AS income_quartile
    FROM loan_default
)
SELECT
    income_quartile,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE status = 1) AS defaults,
    ROUND(
        COUNT(*) FILTER (WHERE status = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM income_groups
GROUP BY income_quartile
ORDER BY income_quartile;

-- Interpretation:
-- Default rates decrease as income quartile increases.
-- Borrowers in the lowest income quartile have the highest default rate,
-- suggesting that income is a useful indicator of default risk in this dataset.

-- SECTION 2: RISK FACTOR ANALYSIS

-- 2.1 Default rate by loan purpose

SELECT 
    loan_purpose,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE status = 1) AS defaults,
    ROUND(
        COUNT(*) FILTER (WHERE status = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM loan_default
GROUP BY loan_purpose
ORDER BY default_rate DESC;

-- Interpretation:
-- Loan purpose appears to be associated with default risk.
-- p2 has the highest default rate at approximately 33.1%,
-- while p4 has the lowest at approximately 23.0%.

-- 2.2 Default rate by loan type

SELECT 
    loan_type,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE status = 1) AS defaults,
    ROUND(
        COUNT(*) FILTER (WHERE status = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM loan_default
GROUP BY loan_type
ORDER BY default_rate DESC;

-- Interpretation:
-- Default rates vary substantially by loan type.
-- Type2 has the highest default rate at approximately 34.5%,
-- compared with 25.1% for type3 and 22.8% for type1.
-- This suggests loan type may be an important indicator of default risk.


-- 2.3 Business/commercial status

SELECT
    business_or_commercial,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE status = 1) AS defaults,
    ROUND(
        COUNT(*) FILTER (WHERE status = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM loan_default
GROUP BY business_or_commercial
ORDER BY default_rate DESC;

-- Interpretation:
-- Business/commercial loans have a substantially higher default rate
-- than non-business/commercial loans.


-- Investigate relationship between loan type and business/commercial status

SELECT DISTINCT
    business_or_commercial,
    loan_type
FROM loan_default
ORDER BY loan_type;

-- Interpretation:
-- All type2 loans are classified as business/commercial, while type1
-- and type3 loans are non-business/commercial.
-- Therefore, the elevated default rate observed for business/commercial
-- loans reflects the same group responsible for the high type2 default rate.

-- 2.4 Interaction between loan purpose and loan type

SELECT 
    loan_purpose,
    loan_type,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE status = 1) AS defaults,
    ROUND(
        COUNT(*) FILTER (WHERE status = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM loan_default
GROUP BY loan_purpose, loan_type
HAVING COUNT(*) >= 100
ORDER BY default_rate DESC;

-- Interpretation:
-- After excluding groups with fewer than 100 loans, p2/type2 has the
-- highest default rate at approximately 46.8%.
-- Type2 loans have relatively high default rates across multiple loan purposes.
-- P2 also remains relatively high-risk among type1 loans, suggesting its
-- elevated default rate is not explained solely by loan type.

-- 2.5 Default rate by occupancy type

SELECT
    occupancy_type,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE status = 1) AS defaults,
    ROUND(
        COUNT(*) FILTER (WHERE status = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM loan_default
GROUP BY occupancy_type
ORDER BY default_rate DESC;

-- Interpretation:
-- IR has the highest default rate at approximately 30.0%,
-- followed by SR at 27.1%, while PR has the lowest at 24.3%.
-- This suggests occupancy type may also be associated with default risk.

-- 2.6 Loan term analysis

WITH term_groups AS (
    SELECT
        status,
        CASE
            WHEN term IS NULL THEN 'Missing'
            WHEN term <= 180 THEN '<= 15 years'
            WHEN term <= 240 THEN '16-20 years'
            WHEN term <= 300 THEN '21-25 years'
            ELSE '>25 years'
        END AS term_band
    FROM loan_default
)

SELECT
    term_band,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE status = 1) AS defaults,
    ROUND(
        COUNT(*) FILTER (WHERE status = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM term_groups
GROUP BY term_band
ORDER BY default_rate DESC;

-- Interpretation:
-- Loans with terms of 21-25 years have the highest default rate
-- at approximately 53.7%.
-- The other major term groups have default rates of around 21-24%,
-- suggesting that the 21-25 year band warrants further investigation.

-- Investigate whether loan type explains the elevated 21-25 year default rate

SELECT
    loan_type,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE status = 1) AS defaults,
    ROUND(
        COUNT(*) FILTER (WHERE status = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM loan_default
WHERE term > 240
  AND term <= 300
GROUP BY loan_type
ORDER BY default_rate DESC;

-- Interpretation:
-- The elevated default rate among 21-25 year loans is present across
-- all three loan types, rather than being driven by only one category.
-- Type2 has the highest rate within this term band, followed by type1
-- and type3, suggesting loan term may contribute additional risk information.


-- Section 2 Summary:
-- Several loan characteristics appear to be associated with default risk.
-- Type2 loans consistently show higher default rates than type1 and type3.
-- Loan purpose, occupancy type and loan term also show meaningful differences.
-- The 21-25 year term band is particularly notable, with a default rate
-- of approximately 53.7%, and this elevated rate persists across loan types.

-- SECTION 3: MULTI_FACTOR RISK ANALYSIS

WITH income_groups AS (
    SELECT
        id,
        term,
        loan_type,
        status,
        income,
        NTILE(4) OVER (ORDER BY income) AS income_quartile
    FROM loan_default
),

risk_flags AS (
    SELECT
        id,
        status,

        CASE
            WHEN term > 240 AND term <= 300 THEN 1
            ELSE 0
        END AS high_risk_term,

        CASE
            WHEN loan_type = 'type2' THEN 1
            ELSE 0
        END AS high_risk_loan_type,

        CASE
            WHEN income_quartile = 1 THEN 1
            ELSE 0
        END AS high_risk_income

    FROM income_groups
),

risk_scores AS (
    SELECT
        id,
        status,
        high_risk_term,
        high_risk_loan_type,
        high_risk_income,
        high_risk_term
        + high_risk_loan_type
        + high_risk_income AS risk_score
    FROM risk_flags
)

SELECT
    risk_score,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE status = 1) AS defaults,
    ROUND(
        COUNT(*) FILTER (WHERE status = 1) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM risk_scores
GROUP BY risk_score
ORDER BY risk_score;

-- Interpretation:
-- The combined risk score separates the portfolio into clearly different
-- risk groups. Default rate rises consistently as the number of identified
-- risk factors increases:

-- Risk score 0: approximately 19.8%
-- Risk score 1: approximately 30.7%
-- Risk score 2: approximately 46.5%
-- Risk score 3: approximately 72.4%

-- This suggests that combining multiple borrower and loan characteristics
-- provides more useful risk segmentation than considering each factor alone.

-- SECTION 4: KEY FINDINGS AND LIMITATIONS

-- KEY FINDINGS:

-- 1. Overall portfolio risk
-- The dataset contains 148,670 loans, with an overall default rate
-- of approximately 24.64%.

-- 2. Income
-- Income showed a clear relationship with default risk.
-- The lowest-income quartile had a default rate of approximately 35.2%,
-- compared with 18.7% for the highest-income quartile.

-- 3. Credit score
-- Default rates were relatively similar across credit score bands,
-- suggesting that credit score alone was not a strong indicator of
-- default risk in this dataset.

-- 4. Loan characteristics
-- Type2 loans showed substantially higher default rates than type1
-- and type3 loans. Loan purpose and occupancy type also showed
-- differences in default risk.

-- 5. Loan term
-- Loans with terms of 21-25 years had a particularly high default
-- rate of approximately 53.7%. Further analysis showed that this
-- elevated rate was present across all three loan types.

-- 6. Multi-factor risk segmentation
-- Combining income, loan type and loan term into a simple descriptive
-- risk score produced clear differences between risk groups.
-- Default rates increased from approximately 19.8% for loans with
-- no identified risk factors to 72.4% for loans with all three.

-- Business Conclusion:
-- The analysis suggests that considering multiple borrower and loan
-- characteristics together may provide more useful risk segmentation
-- than relying on individual factors alone. Income, loan type and loan
-- term were particularly useful for distinguishing higher-risk groups
-- within this portfolio.

-- Limitations:
-- Some variables contain extreme or potentially unusual values, particularly
-- LTV, which may affect summary statistics and require further data-quality
-- investigation.

-- Several categorical variables use coded labels such as p1-p4 and type1-type3.
-- Their underlying business definitions should be confirmed before making
-- operational recommendations based on these categories.

-- The risk score developed in Section 3 is descriptive rather than a validated
-- predictive model. The risk factors were selected using patterns identified
-- within the same dataset, so the results would need to be validated on
-- separate data before being used for lending or credit-risk decisions.