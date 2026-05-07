-- =========================================================
-- Title: Best Selling Item
-- Language: PostgreSQL
-- Difficulty: Hard
-- Source: StrataScratch
-- ID: 10314
-- =========================================================

-- Problem:
-- Find the 3-month rolling average of total revenue from purchases given a table with users, their purchase amount, and date purchased. 
-- Do not include returns which are represented by negative purchase values. 

-- Output: the year-month (YYYY-MM) and 3-month rolling average of revenue, sorted from earliest month to latest month.

-- Note:
-- A 3-month rolling average is defined by calculating the average total revenue from all user purchases for the current month and previous two months. 
-- The first two months will not be a true 3-month rolling average since we are not given data from last year. 
-- Assume each month has at least one purchase.

-- Table:

-- amazon_purchases
-- _____________________________
-- |  created_at    |  date    |
-- |  purchase_amt  |  bigint  |
-- |  user_id       |  bigint  |


-- =====================================================================================
-- Approach
--
-- 1. Aggregate monthly revenue by extracting the year-month from purchase dates.
-- 2. Exclude returned purchases by filtering out negative purchase amounts.
-- 3. Use a window function with ROWS BETWEEN 2 PRECEDING AND CURRENT ROW to calculate the 3-month rolling average revenue.
-- 4. Round the rolling average to 2 decimal places and sort chronologically by month.
-- =====================================================================================

with monthly_revenue as (
    select 
        to_char(created_at, 'YYYY-MM') as year_month
        , date_trunc('month', created_at) as month_date
        , sum(purchase_amt) as total_amt
    from amazon_purchases
    where purchase_amt > 0
    group by 1,2
    order by 1
)

select 
    year_month
    , round(avg(total_amt) over (order by month_date rows between 2 preceding and current row), 2) as rolling_avg
from monthly_revenue
