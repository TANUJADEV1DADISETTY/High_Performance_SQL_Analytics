-- Query 3 (CTE Version): First and Last Order Per User (No Self-Joins)
WITH user_orders_agg AS (
    SELECT 
        user_id,
        MIN(created_at) AS first_order_date,
        MAX(created_at) AS last_order_date,
        (ARRAY_AGG(amount ORDER BY created_at ASC, order_id ASC))[1] AS first_order_amount,
        (ARRAY_AGG(amount ORDER BY created_at DESC, order_id DESC))[1] AS last_order_amount
    FROM orders
    GROUP BY user_id
)
SELECT 
    user_id,
    first_order_date,
    last_order_date,
    ROUND(first_order_amount::numeric, 2) AS first_order_amount,
    ROUND(last_order_amount::numeric, 2) AS last_order_amount
FROM user_orders_agg
ORDER BY user_id;
