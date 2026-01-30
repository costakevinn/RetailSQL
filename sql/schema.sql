-- ============================================================
-- RetailSQL
-- Physical Data Model (PostgreSQL)
--
-- File: schema.sql
-- Purpose:
--   - Create schema namespace
--   - Define base tables and primary keys only
--   - Business rules and constraints are defined separately
-- ============================================================

CREATE SCHEMA IF NOT EXISTS retailsql;

-- ============================================================
-- STORE
-- ============================================================
CREATE TABLE IF NOT EXISTS retailsql.store (
    store_id    BIGSERIAL PRIMARY KEY,
    store_code  TEXT NOT NULL,
    name        TEXT NOT NULL,
    city        TEXT,
    state       TEXT
);

-- ============================================================
-- PRODUCT
-- ============================================================
CREATE TABLE IF NOT EXISTS retailsql.product (
    product_id   BIGSERIAL PRIMARY KEY,
    sku          TEXT NOT NULL,
    name         TEXT NOT NULL,
    category     TEXT,
    list_price   NUMERIC(12,2) NOT NULL
);

-- ============================================================
-- SALES_ORDER
-- ============================================================
CREATE TABLE IF NOT EXISTS retailsql.sales_order (
    sales_order_id BIGSERIAL PRIMARY KEY,
    store_id       BIGINT NOT NULL,
    ordered_at     TIMESTAMPTZ NOT NULL,
    order_status   TEXT
);

-- ============================================================
-- SALES_ORDER_ITEM
-- ============================================================
CREATE TABLE IF NOT EXISTS retailsql.sales_order_item (
    sales_order_item_id BIGSERIAL PRIMARY KEY,
    sales_order_id      BIGINT NOT NULL,
    product_id          BIGINT NOT NULL,
    quantity            INTEGER NOT NULL,
    unit_price          NUMERIC(12,2) NOT NULL,
    discount_amount     NUMERIC(12,2)
);

-- ============================================================
-- INVENTORY_SNAPSHOT
-- ============================================================
CREATE TABLE IF NOT EXISTS retailsql.inventory_snapshot (
    inventory_snapshot_id BIGSERIAL PRIMARY KEY,
    snapshot_date         DATE NOT NULL,
    store_id              BIGINT NOT NULL,
    product_id            BIGINT NOT NULL,
    on_hand               INTEGER NOT NULL
);
