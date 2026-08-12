-- Initialize High-Performance SQL Analytics Schema and Data

CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    cohort_month DATE NOT NULL,
    referred_by INT NULL REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id),
    product_id INT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed 200,000 users if table is empty
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM users) < 200000 THEN
        TRUNCATE TABLE orders CASCADE;
        TRUNCATE TABLE users CASCADE;

        INSERT INTO users (user_id, email, cohort_month, referred_by)
        SELECT 
            i AS user_id,
            'user_' || i || '@analytics.io' AS email,
            (DATE '2024-09-01' + ((i % 24) || ' month')::interval)::date AS cohort_month,
            CASE 
                WHEN i > 1 AND random() < 0.40 THEN floor(1 + random() * (i - 1))::int
                ELSE NULL 
            END AS referred_by
        FROM generate_series(1, 200000) AS i;

        -- Seed 1,000,000 orders with power-law user distribution
        INSERT INTO orders (order_id, user_id, product_id, amount, status, created_at, updated_at)
        SELECT 
            i AS order_id,
            LEAST(200000, GREATEST(1, floor(1 + 200000 * (1.0 - sqrt(random())))::int)) AS user_id,
            floor(1 + random() * 500)::int AS product_id,
            round((random() * 490 + 10)::numeric, 2) AS amount,
            (ARRAY['completed', 'completed', 'completed', 'shipped', 'pending', 'cancelled'])[floor(random() * 6 + 1)] AS status,
            NOW() - (random() * 120 || ' days')::interval AS created_at,
            NOW() - (random() * 120 || ' days')::interval AS updated_at
        FROM generate_series(1, 1000000) AS i;
    END IF;
END $$;
