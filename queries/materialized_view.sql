-- Phase 5: Materialized View Strategy for Query 1 (7-Day Rolling Revenue Average)

DROP MATERIALIZED VIEW IF EXISTS daily_revenue_stats;

CREATE MATERIALIZED VIEW daily_revenue_stats AS
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

CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_revenue_stats_day ON daily_revenue_stats (day);
