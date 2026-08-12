-- Query 3 (Window Version): First and Last Order Per User (No Self-Joins)
WITH ranked_orders AS (
    SELECT 
        user_id,
        created_at,
        amount,
        FIRST_VALUE(created_at) OVER (
            PARTITION BY user_id 
            ORDER BY created_at ASC, order_id ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS first_order_date,
        FIRST_VALUE(amount) OVER (
            PARTITION BY user_id 
            ORDER BY created_at ASC, order_id ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS first_order_amount,
        LAST_VALUE(created_at) OVER (
            PARTITION BY user_id 
            ORDER BY created_at ASC, order_id ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_order_date,
        LAST_VALUE(amount) OVER (
            PARTITION BY user_id 
            ORDER BY created_at ASC, order_id ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_order_amount,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at ASC, order_id ASC) AS rn
    FROM orders
)
SELECT 
    user_id,
    first_order_date,
    last_order_date,
    ROUND(first_order_amount::numeric, 2) AS first_order_amount,
    ROUND(last_order_amount::numeric, 2) AS last_order_amount
FROM ranked_orders
WHERE rn = 1
ORDER BY user_id;
