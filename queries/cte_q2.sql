-- Query 2 (CTE Version): Rank Users by Lifetime Spend within Cohort (Top 10)
WITH user_totals AS (
    SELECT 
        u.cohort_month,
        u.user_id,
        ROUND(SUM(o.amount)::numeric, 2) AS total_spend
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.cohort_month, u.user_id
),
cohorts AS (
    SELECT DISTINCT cohort_month FROM user_totals
)
SELECT 
    c.cohort_month,
    top_users.user_id,
    top_users.total_spend,
    top_users.rank_in_cohort
FROM cohorts c
CROSS JOIN LATERAL (
    SELECT 
        ut.user_id,
        ut.total_spend,
        (
            SELECT COUNT(DISTINCT ut2.total_spend) + 1
            FROM user_totals ut2
            WHERE ut2.cohort_month = c.cohort_month 
              AND ut2.total_spend > ut.total_spend
        )::int AS rank_in_cohort
    FROM user_totals ut
    WHERE ut.cohort_month = c.cohort_month
    ORDER BY ut.total_spend DESC
    LIMIT 10
) top_users
ORDER BY c.cohort_month ASC, top_users.rank_in_cohort ASC;
