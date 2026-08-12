-- Query 5 (CTE Version): Order Share of User Lifetime Spend
WITH user_totals AS (
    SELECT 
        user_id,
        SUM(amount) AS total_user_spend
    FROM orders
    GROUP BY user_id
)
SELECT 
    o.order_id,
    o.user_id,
    ROUND(o.amount::numeric, 2) AS amount,
    ROUND((o.amount / ut.total_user_spend * 100)::numeric, 4) AS lifetime_share_pct
FROM orders o
JOIN user_totals ut ON o.user_id = ut.user_id
ORDER BY o.user_id, o.order_id;
