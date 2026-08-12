-- Query 1 (Window Version): 7-Day Rolling Revenue Average for Last 90 Days
WITH daily AS (
    SELECT 
        created_at::date AS day,
        SUM(amount) AS daily_revenue
    FROM orders
    WHERE created_at >= (SELECT MAX(created_at::date) - INTERVAL '89 days' FROM orders)
    GROUP BY created_at::date
)
SELECT 
    day,
    ROUND(daily_revenue::numeric, 2) AS daily_revenue,
    ROUND(AVG(daily_revenue) OVER (
        ORDER BY day 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )::numeric, 2) AS rolling_7d_avg
FROM daily
ORDER BY day;
