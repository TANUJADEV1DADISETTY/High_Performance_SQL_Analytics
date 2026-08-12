-- Query 4 (CTE Version): Customer Churn Risk joining separate temporal CTEs
WITH max_t AS (
    SELECT MAX(created_at) AS max_date FROM orders
),
last_30 AS (
    SELECT o.user_id, COUNT(*)::int AS orders_last_30d
    FROM orders o
    CROSS JOIN max_t m
    WHERE o.created_at >= m.max_date - INTERVAL '30 days'
    GROUP BY o.user_id
),
prev_30 AS (
    SELECT o.user_id, COUNT(*)::int AS orders_prev_30d
    FROM orders o
    CROSS JOIN max_t m
    WHERE o.created_at >= m.max_date - INTERVAL '60 days'
      AND o.created_at < m.max_date - INTERVAL '30 days'
    GROUP BY o.user_id
)
SELECT 
    p.user_id,
    COALESCE(l.orders_last_30d, 0) AS orders_last_30d,
    p.orders_prev_30d
FROM prev_30 p
LEFT JOIN last_30 l ON p.user_id = l.user_id
WHERE COALESCE(l.orders_last_30d, 0) < p.orders_prev_30d
ORDER BY p.user_id;
