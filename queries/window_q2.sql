-- Query 2 (Window Version): Rank Users by Lifetime Spend within Cohort (Top 10)
WITH user_spend AS (
    SELECT 
        u.cohort_month,
        u.user_id,
        ROUND(SUM(o.amount)::numeric, 2) AS total_spend,
        DENSE_RANK() OVER (
            PARTITION BY u.cohort_month 
            ORDER BY SUM(o.amount) DESC
        )::int AS rank_in_cohort
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.cohort_month, u.user_id
)
SELECT 
    cohort_month,
    user_id,
    total_spend,
    rank_in_cohort
FROM user_spend
WHERE rank_in_cohort <= 10
ORDER BY cohort_month ASC, rank_in_cohort ASC;
