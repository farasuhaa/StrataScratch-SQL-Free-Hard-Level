-- =========================================================
-- Title: Best Selling Item
-- Language: PostgreSQL
-- Difficulty: Hard
-- Source: StrataScratch
-- ID: 10172
-- =========================================================

-- Problem:
-- Find the best-selling item for each month (no need to separate months by year). 

-- Note:
-- The best-selling item is determined by the highest total sales amount, calculated as: total_paid = unitprice * quantity. 
-- A negative quantity indicates a return or cancellation (the invoice number begins with 'C'. 
-- To calculate sales, ignore returns and cancellations. 

-- Output: the month, description of the item, and the total amount paid.

-- Tables:

-- online_retail
-- ______________________________________
-- |  country      |  text              |
-- |  customerid   |  double precision  |
-- |  description  |  text              |
-- |  invoicedate  |  date              |
-- |  invoiceno    |  text              |
-- |  quantity     |  bigint            |
-- |  stockcode    |  text              |
-- |  unitprice    |  double precision  |

-- =====================================================================================
-- Approach
--
-- 1. Exclude cancelled/returned transactions based on invoice number pattern.
-- 2. Compute total sales per item per month (quantity * unitprice).
-- 3. Rank items within each month by total sales in descending order.
-- 4. Select the top-ranked item per month as the best-selling item.
-- =====================================================================================

with base as (
    select
        invoiceno
        , stockcode
        , description
        , quantity
        , extract(month from invoicedate) as invoice_month
        , unitprice
    from online_retail
    where invoiceno not in (select invoiceno from online_retail where invoiceno ilike '%c%')
    order by invoiceno
)

, amount as(
    select
        stockcode
        , description
        , invoice_month
        , sum(quantity * unitprice) as total_paid
    from base
    group by 1,2,3
)

, ranking as (
    select
        stockcode
        , description
        , invoice_month
        , total_paid
        , row_number() over (partition by invoice_month order by total_paid desc) as item_rnk
    from amount
)

select
    invoice_month
    , description
    , total_paid
from ranking
where item_rnk = 1
