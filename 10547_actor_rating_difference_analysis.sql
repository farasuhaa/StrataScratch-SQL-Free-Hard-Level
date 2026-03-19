-- =========================================================
-- Title: Actor Rating Difference Analysis
-- Language: PostgreSQL
-- Difficulty: Hard
-- Source: StrataScratch
-- ID: 10547
-- =========================================================

-- Problem:
-- You are given a dataset of actors and the films they have been involved in, 
-- including each film's release date and rating.
-- For each actor, calculate the difference between the rating of their most recent film 
-- and their average rating across all previous films (the average rating excludes the most recent one).

-- Output:
-- A list of actors, their average lifetime rating, the rating of their most recent film,
-- and the difference between the two ratings. 

-- Note:
-- Round the difference calculation to 2 decimal places. 
-- If an actor has only one film, return 0 for the difference and their only
-- film’s rating for both the average and latest rating fields.

-- Tables:

-- actor_rating_shift
-- _______________________________________
-- |  actor_name    |  text              |
-- |  film_rating   |  double precision  |
-- |  film_title    |  text              |
-- |  release_date  |  date              |

-- =====================================================================================
-- Approach
--
-- 1. Rank films per actor by release_date (descending) to identify the most recent film.
-- 2. Separate the most recent rating and compute the average rating of all previous films.
-- 3. Combine both metrics per actor, handling single-film cases using coalesce().
-- 4. Calculate and round the difference between recent rating and average rating.
-- =====================================================================================

with date_rank as (
    select
        actor_name
        , film_title
        , release_date
        , film_rating
        , row_number() over (partition by actor_name order by release_date desc) as date_ranking
    from actor_rating_shift
    -- where actor_name in ('Matt Damon', 'Angelina Jolie', 'Brad Pitt')
    order by release_date desc
)

, recent_rate as (
    select
        actor_name
        , film_rating
    from date_rank
    where date_ranking = 1
)

, avg_rate as (
    select
        actor_name
        , avg(film_rating) as avg_rating
    from date_rank
    where date_ranking > 1
    group by 1
)

, rate_combined as (
    select
        coalesce(r.actor_name, a.actor_name) as actor_name
        , coalesce(film_rating, avg_rating) as recent_rating
        , coalesce(avg_rating, film_rating) as avg_rating
    from recent_rate r
    left join avg_rate a    on r.actor_name = a.actor_name
)

select
    actor_name
    , recent_rating
    , avg_rating
    , round((recent_rating - avg_rating)::numeric,2) as diff_rating
from rate_combined
group by 1,2,3
