-- Query 4 (Window Version): Customer Churn Risk using LAG()
WITH max_t AS (
    SELECT MAX(created_at) AS max_date FROM orders
),
periods AS (
    SELECT 
        o.user_id,
        CASE 
            WHEN o.created_at >= m.max_date - INTERVAL '30 days' THEN 2
            ELSE 1 
        END AS period_id,
        COUNT(*)::int AS order_cnt
    FROM orders o
    CROSS JOIN max_t m
    WHERE o.created_at >= m.max_date - INTERVAL '60 days'
    GROUP BY o.user_id, 
             CASE 
                 WHEN o.created_at >= m.max_date - INTERVAL '30 days' THEN 2
                 ELSE 1 
             END
),
windowed AS (
    SELECT 
        user_id,
        period_id,
        order_cnt AS orders_last_30d,
        LAG(order_cnt) OVER (PARTITION BY user_id ORDER BY period_id) AS orders_prev_30d
    FROM periods
)
SELECT 
    user_id,
    orders_last_30d,
    orders_prev_30d
FROM windowed
WHERE period_id = 2 
  AND orders_prev_30d IS NOT NULL 
  AND orders_last_30d < orders_prev_30d
ORDER BY user_id;
