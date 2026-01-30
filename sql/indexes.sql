-- ============================================================
-- RetailSQL
-- Physical Indexes
--
-- File: indexes.sql
-- Purpose:
--   - Support relational joins (FK lookups)
--   - Support common temporal access patterns
--   - Keep the physical model explicit and reviewable
--   - Idempotent: safe to re-run
-- ============================================================

-- ============================================================
-- Foreign Key Support Indexes
-- ============================================================

-- SALES_ORDER -> STORE
CREATE INDEX IF NOT EXISTS idx_sales_order_store_id
    ON retailsql.sales_order (store_id);

-- SALES_ORDER_ITEM -> SALES_ORDER
CREATE INDEX IF NOT EXISTS idx_sales_order_item_sales_order_id
    ON retailsql.sales_order_item (sales_order_id);

-- SALES_ORDER_ITEM -> PRODUCT
CREATE INDEX IF NOT EXISTS idx_sales_order_item_product_id
    ON retailsql.sales_order_item (product_id);

-- INVENTORY_SNAPSHOT -> STORE
CREATE INDEX IF NOT EXISTS idx_inventory_snapshot_store_id
    ON retailsql.inventory_snapshot (store_id);

-- INVENTORY_SNAPSHOT -> PRODUCT
CREATE INDEX IF NOT EXISTS idx_inventory_snapshot_product_id
    ON retailsql.inventory_snapshot (product_id);

-- ============================================================
-- Temporal Access Indexes
-- ============================================================

-- Order date access (time filtering)
CREATE INDEX IF NOT EXISTS idx_sales_order_ordered_at
    ON retailsql.sales_order (ordered_at);

-- Inventory snapshot date access
CREATE INDEX IF NOT EXISTS idx_inventory_snapshot_snapshot_date
    ON retailsql.inventory_snapshot (snapshot_date);
