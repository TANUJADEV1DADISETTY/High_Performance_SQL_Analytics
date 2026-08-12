-- Query 5 (Window Version): Order Share of User Lifetime Spend
SELECT 
    order_id,
    user_id,
    ROUND(amount::numeric, 2) AS amount,
    ROUND((amount / SUM(amount) OVER (PARTITION BY user_id) * 100)::numeric, 4) AS lifetime_share_pct
FROM orders
ORDER BY user_id, order_id;
