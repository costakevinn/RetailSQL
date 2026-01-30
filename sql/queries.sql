-- ============================================================
-- RetailSQL
-- Verification & Inspection Queries
--
-- File: queries.sql
-- Purpose:
--   - Validate data model correctness after build
--   - Provide quick inspection queries (model-focused, not analytics)
-- ============================================================

\pset pager off
\timing off

-- ------------------------------------------------------------
-- Q1) List tables in schema
-- ------------------------------------------------------------
\echo '--- Q1) Tables in schema retailsql ---'
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'retailsql'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ------------------------------------------------------------
-- Q2) Row counts (seed verification)
-- ------------------------------------------------------------
\echo '--- Q2) Row counts ---'
SELECT 'store' AS table_name, COUNT(*) AS row_count FROM retailsql.store
UNION ALL SELECT 'product', COUNT(*) FROM retailsql.product
UNION ALL SELECT 'sales_order', COUNT(*) FROM retailsql.sales_order
UNION ALL SELECT 'sales_order_item', COUNT(*) FROM retailsql.sales_order_item
UNION ALL SELECT 'inventory_snapshot', COUNT(*) FROM retailsql.inventory_snapshot;

-- ------------------------------------------------------------
-- Q3) Foreign keys (integrity inspection)
-- ------------------------------------------------------------
\echo '--- Q3) Foreign keys ---'
SELECT
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS referenced_table,
  ccu.column_name AS referenced_column,
  tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
 AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'retailsql'
ORDER BY tc.table_name, kcu.column_name;

-- ------------------------------------------------------------
-- Q4) Constraints per table (sanity)
-- ------------------------------------------------------------
\echo '--- Q4) Constraints ---'
SELECT
  n.nspname AS schema_name,
  t.relname AS table_name,
  c.conname AS constraint_name,
  pg_get_constraintdef(c.oid) AS definition
FROM pg_constraint c
JOIN pg_class t ON t.oid = c.conrelid
JOIN pg_namespace n ON n.oid = t.relnamespace
WHERE n.nspname = 'retailsql'
ORDER BY table_name, constraint_name;

-- ------------------------------------------------------------
-- Q5) Indexes (physical model inspection)
-- ------------------------------------------------------------
\echo '--- Q5) Indexes ---'
SELECT
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'retailsql'
ORDER BY tablename, indexname;

-- ------------------------------------------------------------
-- Q6) Sample data (quick browse)
-- ------------------------------------------------------------
\echo '--- Q6) Sample rows: store ---'
SELECT * FROM retailsql.store ORDER BY store_code;

\echo '--- Q6) Sample rows: product ---'
SELECT * FROM retailsql.product ORDER BY sku;

\echo '--- Q6) Sample rows: sales_order ---'
SELECT * FROM retailsql.sales_order ORDER BY ordered_at;

\echo '--- Q6) Sample rows: sales_order_item ---'
SELECT * FROM retailsql.sales_order_item ORDER BY sales_order_id, product_id;

\echo '--- Q6) Sample rows: inventory_snapshot (LIMIT 10) ---'
SELECT *
FROM retailsql.inventory_snapshot
ORDER BY snapshot_date, store_id, product_id
LIMIT 10;

-- ------------------------------------------------------------
-- Q7) Basic join check (model relationship validation)
-- ------------------------------------------------------------
\echo '--- Q7) Join validation ---'
SELECT
  so.sales_order_id,
  s.store_code,
  so.ordered_at,
  so.order_status,
  p.sku,
  soi.quantity,
  soi.unit_price,
  COALESCE(soi.discount_amount, 0) AS discount_amount
FROM retailsql.sales_order so
JOIN retailsql.store s
  ON s.store_id = so.store_id
JOIN retailsql.sales_order_item soi
  ON soi.sales_order_id = so.sales_order_id
JOIN retailsql.product p
  ON p.product_id = soi.product_id
ORDER BY so.sales_order_id, p.sku;

-- ------------------------------------------------------------
-- Q8) Computed totals (still "pure query", no view)
-- ------------------------------------------------------------
\echo '--- Q8) Computed totals: net revenue by store (completed orders) ---'
SELECT
  s.store_code,
  SUM((soi.quantity * soi.unit_price) - COALESCE(soi.discount_amount, 0)) AS net_revenue
FROM retailsql.sales_order so
JOIN retailsql.store s
  ON s.store_id = so.store_id
JOIN retailsql.sales_order_item soi
  ON soi.sales_order_id = so.sales_order_id
WHERE so.order_status = 'completed'
GROUP BY s.store_code
ORDER BY net_revenue DESC;
