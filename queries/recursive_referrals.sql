-- Phase 4: Recursive CTE for Referral Chain Depth Analysis
WITH top_100 AS (
    SELECT user_id
    FROM orders
    GROUP BY user_id
    ORDER BY COUNT(*) DESC
    LIMIT 100
),
RECURSIVE referral_tree AS (
    -- Anchor member: top 100 users at depth 1
    SELECT 
        t.user_id AS root_user_id,
        u.user_id AS current_user_id,
        1 AS depth
    FROM top_100 t
    JOIN users u ON t.user_id = u.user_id

    UNION ALL

    -- Recursive member: find users referred by the current user level
    SELECT 
        rt.root_user_id,
        u.user_id AS current_user_id,
        rt.depth + 1 AS depth
    FROM referral_tree rt
    JOIN users u ON rt.current_user_id = u.referred_by
    WHERE rt.depth < 100 -- cycle protection guard
)
SELECT 
    root_user_id AS user_id,
    MAX(depth) AS chain_depth
FROM referral_tree
GROUP BY root_user_id
ORDER BY chain_depth DESC, root_user_id ASC;
