-- Query 1 (CTE Version): 7-Day Rolling Revenue Average for Last 90 Days
WITH daily AS (
    SELECT 
        created_at::date AS day,
        SUM(amount) AS daily_revenue
    FROM orders
    WHERE created_at >= (SELECT MAX(created_at::date) - INTERVAL '89 days' FROM orders)
    GROUP BY created_at::date
)
SELECT 
    d1.day,
    ROUND(d1.daily_revenue::numeric, 2) AS daily_revenue,
    ROUND((
        SELECT AVG(d2.daily_revenue)
        FROM daily d2
        WHERE d2.day BETWEEN d1.day - INTERVAL '6 days' AND d1.day
    )::numeric, 2) AS rolling_7d_avg
FROM daily d1
ORDER BY d1.day;
