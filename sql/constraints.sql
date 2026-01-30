-- ============================================================
-- RetailSQL
-- Constraints (PostgreSQL)
--
-- File: constraints.sql
-- Purpose:
--   - Enforce business rules and relational integrity
--   - Add UNIQUE, FOREIGN KEY, and CHECK constraints
--   - Idempotent: safe to re-run
-- ============================================================

-- ============================================================
-- STORE
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'uq_store_store_code'
  ) THEN
    ALTER TABLE retailsql.store
      ADD CONSTRAINT uq_store_store_code UNIQUE (store_code);
  END IF;
END $$;

-- ============================================================
-- PRODUCT
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'uq_product_sku'
  ) THEN
    ALTER TABLE retailsql.product
      ADD CONSTRAINT uq_product_sku UNIQUE (sku);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_product_list_price_nonnegative'
  ) THEN
    ALTER TABLE retailsql.product
      ADD CONSTRAINT ck_product_list_price_nonnegative CHECK (list_price >= 0);
  END IF;
END $$;

-- ============================================================
-- SALES_ORDER
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_sales_order_store'
  ) THEN
    ALTER TABLE retailsql.sales_order
      ADD CONSTRAINT fk_sales_order_store
      FOREIGN KEY (store_id)
      REFERENCES retailsql.store (store_id);
  END IF;
END $$;

-- ============================================================
-- SALES_ORDER_ITEM
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_sales_order_item_sales_order'
  ) THEN
    ALTER TABLE retailsql.sales_order_item
      ADD CONSTRAINT fk_sales_order_item_sales_order
      FOREIGN KEY (sales_order_id)
      REFERENCES retailsql.sales_order (sales_order_id)
      ON DELETE CASCADE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_sales_order_item_product'
  ) THEN
    ALTER TABLE retailsql.sales_order_item
      ADD CONSTRAINT fk_sales_order_item_product
      FOREIGN KEY (product_id)
      REFERENCES retailsql.product (product_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_sales_order_item_quantity_positive'
  ) THEN
    ALTER TABLE retailsql.sales_order_item
      ADD CONSTRAINT ck_sales_order_item_quantity_positive CHECK (quantity > 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_sales_order_item_unit_price_nonnegative'
  ) THEN
    ALTER TABLE retailsql.sales_order_item
      ADD CONSTRAINT ck_sales_order_item_unit_price_nonnegative CHECK (unit_price >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_sales_order_item_discount_nonnegative'
  ) THEN
    ALTER TABLE retailsql.sales_order_item
      ADD CONSTRAINT ck_sales_order_item_discount_nonnegative
      CHECK (discount_amount IS NULL OR discount_amount >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'uq_sales_order_item_order_product'
  ) THEN
    ALTER TABLE retailsql.sales_order_item
      ADD CONSTRAINT uq_sales_order_item_order_product UNIQUE (sales_order_id, product_id);
  END IF;
END $$;

-- ============================================================
-- INVENTORY_SNAPSHOT
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_inventory_snapshot_store'
  ) THEN
    ALTER TABLE retailsql.inventory_snapshot
      ADD CONSTRAINT fk_inventory_snapshot_store
      FOREIGN KEY (store_id)
      REFERENCES retailsql.store (store_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_inventory_snapshot_product'
  ) THEN
    ALTER TABLE retailsql.inventory_snapshot
      ADD CONSTRAINT fk_inventory_snapshot_product
      FOREIGN KEY (product_id)
      REFERENCES retailsql.product (product_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_inventory_snapshot_on_hand_nonnegative'
  ) THEN
    ALTER TABLE retailsql.inventory_snapshot
      ADD CONSTRAINT ck_inventory_snapshot_on_hand_nonnegative CHECK (on_hand >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'uq_inventory_snapshot_date_store_product'
  ) THEN
    ALTER TABLE retailsql.inventory_snapshot
      ADD CONSTRAINT uq_inventory_snapshot_date_store_product
      UNIQUE (snapshot_date, store_id, product_id);
  END IF;
END $$;
