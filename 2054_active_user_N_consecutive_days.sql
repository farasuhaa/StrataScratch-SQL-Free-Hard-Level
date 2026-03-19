-- =========================================================
-- Title: Consecutive Days
-- Language: PostgreSQL
-- Difficulty: Hard
-- Source: StrataScratch
-- ID: 2054
-- =========================================================

-- Problem:
-- Find all the users who were active for 3 consecutive days or more.

-- Output: list of user_id

-- Tables:

-- sf_events
--  ______________________________________
-- |  account_id   |  character varying  |
-- |  record_date  |  date               |
-- |  user_id      |  character varying  |

-- =====================================================================================
-- Approach

-- 1. Remove duplicate user activity to ensure each record_date is counted once per user.
-- 2. Assign a sequential order of dates per user using row_number().
-- 3. Normalize dates by subtracting the row number to identify consecutive day streaks.
-- 4. Group by user and streak, then filter for streaks with at least 3 consecutive days.
-- =====================================================================================

with base as (
    select
        distinct  user_id
        , record_date
    from sf_events
    order by 1, 2
)

, day_diff as (
    select
        user_id
        , record_date
        , record_date - row_number() over (partition by user_id order by record_date) * interval '1 day' as rnk
    from base
)

select
    user_id
from day_diff
group by 1, rnk
having count(*) >= 3
