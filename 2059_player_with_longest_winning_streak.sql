-- =========================================================
-- Title: Player with Longest Streak
-- Language: PostgreSQL
-- Difficulty: Hard
-- Source: StrataScratch
-- ID: 2059
-- =========================================================

-- Problem:
-- You are given a table of tennis players and their matches that they could either win (W) or lose (L). 
-- Find the longest streak of wins. 
-- A streak is a set of consecutive won matches of one player. 
-- The streak ends once a player loses their next match.

-- Note:
-- For this question, disregard edge cases such as: players who never lose, streaks that start before the first loss, 
-- and streaks that continue after the final match.

-- Output: player_id, longest streak

-- Tables:

-- players_results
-- _____________________________
-- |  match_date    |  date    |
-- |  match_result  |  text    |
-- |  player_id     |  bigint  |

-- =====================================================================================
-- Approach

-- 1. Create a streak identifier by cumulatively counting losses (L) per player to segment match sequences.
-- 2. Filter only winning matches (W) and group by player and streak to count consecutive wins.
-- 3. Calculate the length of each win streak using count(*).
-- 4. Select the maximum streak length per player as the longest win streak.
-- =====================================================================================

with base as (
    select
        player_id
        , match_date
        , match_result
        , sum(case when match_result in ('L') then 1 else 0 end) over (partition by player_id order by match_date) as streak
    from players_results
    -- where player_id = 402
    group by 1,2,3
)

, win_streaks as (
    select
        player_id
        , streak
        , count(*) as win_streak
    from base
    where match_result in ('W')
    group by 1,2
)

select
    player_id
    , win_streak as longest_win_streak
from win_streaks
where win_streak = (select max(win_streak) from win_streaks)
group by 1,2
order by 2 desc
