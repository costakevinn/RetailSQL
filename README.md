# RetailSQL — Relational Data Platform (PostgreSQL)

RetailSQL is a **production-oriented relational data platform** designed to model and enforce core retail business processes such as **sales transactions, product catalog, store operations, and inventory tracking**.

The project focuses on **data modeling, integrity, and correctness**, treating the database as a **core system component**, not an analytical artifact.

---

## What This Product Solves

RetailSQL provides a **clean, normalized transactional data layer** that:

* Encodes **business rules directly in the database**
* Guarantees **referential and domain integrity**
* Avoids redundant or derived data
* Serves as a reliable foundation for analytics and ML systems

The scope is intentionally **structural**, not analytical.

---

## Data Modeling Approach

The model was developed using a layered methodology commonly applied in production systems:

1. Business rules definition
2. Conceptual modeling (entities and relationships)
3. Logical modeling (attributes, keys, constraints)
4. Physical implementation (PostgreSQL)

This separation ensures that **business semantics remain stable** even as physical implementation evolves.

---

## Entity–Relationship Model

The core domain is represented by the following entities:

* **STORE** — physical retail locations
* **PRODUCT** — product catalog
* **SALES_ORDER** — transactional sales events
* **SALES_ORDER_ITEM** — line-level order details
* **INVENTORY_SNAPSHOT** — point-in-time inventory state

![RetailSQL ERD](./erd/erd.jpeg)

All many-to-many relationships are resolved explicitly, and the model adheres to standard normalization practices.

---

## Physical Structure (PostgreSQL)

The physical model is implemented with clear separation of responsibilities:

* **Tables & primary keys** (`schema.sql`)
* **Business rules & referential integrity** (`constraints.sql`)
* **Indexing strategy** (`indexes.sql`)
* **Deterministic seed data** (`seed.sql`)
* **Inspection queries** (`queries.sql`)

This structure mirrors how relational databases are maintained in real systems.

---

## Business Rules at the Database Level

Examples of enforced rules include:

* Positive quantities and non-negative monetary values
* Unique products per sales order
* One inventory snapshot per *(date, store, product)*
* Mandatory relationships between orders, products, and stores

These constraints ensure that **invalid states cannot be stored**, independent of application logic.

---

## Model Validation (Selected Outputs)

### Schema Objects

```text
retailsql | inventory_snapshot
retailsql | product
retailsql | sales_order
retailsql | sales_order_item
retailsql | store
```

### Referential Integrity

```text
sales_order_item → sales_order → store
sales_order_item → product
inventory_snapshot → store
inventory_snapshot → product
```

### Sample Relational Join

```text
sales_order_id | store_code | sku      | quantity
---------------+------------+----------+----------
1              | S001       | SKU-1001 | 2
1              | S001       | SKU-3001 | 1
2              | S002       | SKU-2001 | 1
```

Full inspection results are available in `docs/sample_output.txt`.

---

## Project Structure

```text
RetailSQL/
├── erd/
│   ├── retailsql.mmd
│   └── erd.jpeg
├── sql/
│   ├── schema.sql
│   ├── constraints.sql
│   ├── indexes.sql
│   ├── seed.sql
│   └── queries.sql
└── docs/
    └── sample_output.txt
```

---

## Why This Matters

RetailSQL demonstrates the ability to:

* Translate **business rules into enforceable data models**
* Design **normalized relational schemas**
* Think in terms of **data foundations**, not just queries
* Build database structures that safely support **analytics and machine learning pipelines**

This is the kind of data layer expected in production environments where **data quality directly impacts downstream models and decisions**.
