-- ============================================================
-- RetailSQL
-- Seed Data (Simple & Technical)
--
-- File: seed.sql
-- Purpose:
--   - Populate minimal demo data
--   - Keep SQL readable and easy to reason about
--   - Idempotent: safe to re-run
-- ============================================================

BEGIN;

-- ============================================================
-- STORE
-- ============================================================
INSERT INTO retailsql.store (store_code, name, city, state) VALUES
  ('S001', 'RetailSQL Downtown', 'Sao Paulo', 'SP'),
  ('S002', 'RetailSQL Mall',     'Rio de Janeiro', 'RJ')
ON CONFLICT (store_code) DO NOTHING;

-- ============================================================
-- PRODUCT
-- ============================================================
INSERT INTO retailsql.product (sku, name, category, list_price) VALUES
  ('SKU-1001', 'Coffee Beans 1kg',      'Grocery',     79.90),
  ('SKU-1002', 'Oat Milk 1L',           'Grocery',     12.50),
  ('SKU-2001', 'Wireless Mouse',        'Electronics', 89.90),
  ('SKU-3001', 'Notebook A5',           'Stationery',  14.90)
ON CONFLICT (sku) DO NOTHING;

-- ============================================================
-- SALES_ORDER
-- ============================================================
-- Insert two deterministic orders, only if they don't exist yet.
INSERT INTO retailsql.sales_order (store_id, ordered_at, order_status)
SELECT s.store_id, '2026-01-05 10:30:00-03'::timestamptz, 'completed'
FROM retailsql.store s
WHERE s.store_code = 'S001'
  AND NOT EXISTS (
    SELECT 1
    FROM retailsql.sales_order so
    WHERE so.store_id = s.store_id
      AND so.ordered_at = '2026-01-05 10:30:00-03'::timestamptz
  );

INSERT INTO retailsql.sales_order (store_id, ordered_at, order_status)
SELECT s.store_id, '2026-01-06 18:45:00-03'::timestamptz, 'completed'
FROM retailsql.store s
WHERE s.store_code = 'S002'
  AND NOT EXISTS (
    SELECT 1
    FROM retailsql.sales_order so
    WHERE so.store_id = s.store_id
      AND so.ordered_at = '2026-01-06 18:45:00-03'::timestamptz
  );

-- ============================================================
-- SALES_ORDER_ITEM
-- ============================================================
-- Order 1 items (S001 @ 2026-01-05 10:30:00-03)
INSERT INTO retailsql.sales_order_item
  (sales_order_id, product_id, quantity, unit_price, discount_amount)
SELECT
  so.sales_order_id,
  p.product_id,
  2,
  p.list_price,
  0.00
FROM retailsql.sales_order so
JOIN retailsql.store s
  ON s.store_id = so.store_id
JOIN retailsql.product p
  ON p.sku = 'SKU-1001'
WHERE s.store_code = 'S001'
  AND so.ordered_at = '2026-01-05 10:30:00-03'::timestamptz
  AND NOT EXISTS (
    SELECT 1
    FROM retailsql.sales_order_item soi
    WHERE soi.sales_order_id = so.sales_order_id
      AND soi.product_id = p.product_id
  );

INSERT INTO retailsql.sales_order_item
  (sales_order_id, product_id, quantity, unit_price, discount_amount)
SELECT
  so.sales_order_id,
  p.product_id,
  1,
  p.list_price,
  5.00
FROM retailsql.sales_order so
JOIN retailsql.store s
  ON s.store_id = so.store_id
JOIN retailsql.product p
  ON p.sku = 'SKU-3001'
WHERE s.store_code = 'S001'
  AND so.ordered_at = '2026-01-05 10:30:00-03'::timestamptz
  AND NOT EXISTS (
    SELECT 1
    FROM retailsql.sales_order_item soi
    WHERE soi.sales_order_id = so.sales_order_id
      AND soi.product_id = p.product_id
  );

-- Order 2 items (S002 @ 2026-01-06 18:45:00-03)
INSERT INTO retailsql.sales_order_item
  (sales_order_id, product_id, quantity, unit_price, discount_amount)
SELECT
  so.sales_order_id,
  p.product_id,
  1,
  p.list_price,
  0.00
FROM retailsql.sales_order so
JOIN retailsql.store s
  ON s.store_id = so.store_id
JOIN retailsql.product p
  ON p.sku = 'SKU-2001'
WHERE s.store_code = 'S002'
  AND so.ordered_at = '2026-01-06 18:45:00-03'::timestamptz
  AND NOT EXISTS (
    SELECT 1
    FROM retailsql.sales_order_item soi
    WHERE soi.sales_order_id = so.sales_order_id
      AND soi.product_id = p.product_id
  );

-- ============================================================
-- INVENTORY_SNAPSHOT
-- ============================================================
-- Create a single snapshot date with deterministic on_hand.
INSERT INTO retailsql.inventory_snapshot
  (snapshot_date, store_id, product_id, on_hand)
SELECT
  '2026-01-07'::date,
  s.store_id,
  p.product_id,
  100
FROM retailsql.store s
CROSS JOIN retailsql.product p
ON CONFLICT (snapshot_date, store_id, product_id) DO NOTHING;

COMMIT;
