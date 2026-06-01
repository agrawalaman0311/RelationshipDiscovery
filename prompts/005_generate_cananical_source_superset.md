# PROMPT 005 – GENERATE CANONICAL SOURCE_SUPERSET

## Objective

Generate executable Snowflake SQL required to create and populate SOURCE_SUPERSET.

SOURCE_SUPERSET is the canonical integration layer for the Relationship Discovery Framework.

SOURCE_SUPERSET shall use an expanded canonical structure.

EAV (Entity Attribute Value) and Key-Value designs are prohibited.

The table must provide a standardized representation of all source systems.

---

## Output Location

sql/intm/005_source_superset.sql

Generate the contents of this file.

Do not generate any additional files.

---

## Governance Inputs

Read and comply with:

* governance/001_MASTER_CONSTITUTION.md
* governance/002_APPROVED_DECISIONS_REGISTER.md
* governance/003_PROMPT_OS.md
* governance/004_PROJECT_CONTEXT.md
* governance/005_METADATA_DESIGN.md
* governance/006_RELATIONSHIP_DISCOVERY_RULES.md

All approved decisions are mandatory.

---

## Existing Platform

Database:

RELATIONSHIP_DISCOVERY_DB

Source Schema:

SRC

Metadata Schema:

MD

Target Schema:

INTM

---

## Existing Source Tables

* ERP_PRODUCT
* SUPPLIER_PRODUCT
* INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT

---

## Existing Metadata Tables

* MD_ATTRIBUTE_DQ_RULES
* MD_ATTRIBUTE_SURVIVORSHIP
* MD_ATTRIBUTE_MAPPING

---

## Execution Strategy

SOURCE_SUPERSET is an intermediate processing object.

The implementation must use:

CREATE OR REPLACE TABLE

The implementation must be idempotent.

Repeated execution must produce identical results.

INSERT statements are prohibited.

The implementation must rebuild the entire table using a single:

CREATE OR REPLACE TABLE AS SELECT

statement.

---

## Core Requirement

SOURCE_SUPERSET shall use an expanded canonical structure.

Do NOT generate:

* ATTRIBUTE_NAME columns
* ATTRIBUTE_VALUE columns
* EAV models
* Key-Value models

---

## Table To Generate

RELATIONSHIP_DISCOVERY_DB.INTM.SOURCE_SUPERSET

---

## Required Columns

* SOURCE_SUPERSET_ID

* SOURCE_SYSTEM

* SOURCE_RECORD_ID

* BRAND

* PRODUCT_NAME

* CATEGORY

* MANUFACTURER

* SALE_PRICE

* SIZE

* LOAD_DTTM

* CREATED_DTTM

---

## SOURCE_SUPERSET_ID Requirement

Generate SOURCE_SUPERSET_ID using:

ROW_NUMBER()

Do NOT use AUTOINCREMENT.

The implementation must work within a CREATE OR REPLACE TABLE AS SELECT pattern.

---

## Approved Canonical Mapping

BRAND

* ERP_PRODUCT.BRAND_NAME
* SUPPLIER_PRODUCT.BRAND
* INVENTORY_PRODUCT.BRAND_CODE
* ECOMMERCE_PRODUCT.VENDOR_NAME

PRODUCT_NAME

* ERP_PRODUCT.PRODUCT_DESCRIPTION
* SUPPLIER_PRODUCT.ITEM_NAME
* INVENTORY_PRODUCT.SKU_DESCRIPTION
* ECOMMERCE_PRODUCT.LISTING_TITLE

CATEGORY

* ERP_PRODUCT.PRODUCT_CATEGORY
* SUPPLIER_PRODUCT.CATEGORY_DESCRIPTION
* INVENTORY_PRODUCT.STORAGE_CATEGORY
* ECOMMERCE_PRODUCT.WEB_CATEGORY

MANUFACTURER

* ERP_PRODUCT.MANUFACTURER_NAME
* SUPPLIER_PRODUCT.MFG_NAME
* INVENTORY_PRODUCT.BRAND_CODE
* ECOMMERCE_PRODUCT.SELLER_NAME

SALE_PRICE

* ERP_PRODUCT.LIST_PRICE
* SUPPLIER_PRODUCT.UNIT_COST
* INVENTORY_PRODUCT.REORDER_COST
* ECOMMERCE_PRODUCT.SELLING_PRICE

SIZE

* ERP_PRODUCT.PRODUCT_SIZE
* SUPPLIER_PRODUCT.PACK_SIZE
* INVENTORY_PRODUCT.WEIGHT_SIZE
* ECOMMERCE_PRODUCT.DISPLAY_SIZE

---

## Population Requirements

Populate SOURCE_SUPERSET from:

* ERP_PRODUCT
* SUPPLIER_PRODUCT
* INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT

Generate one row per source record.

Expected volume:

Approximately 42,450 rows.

---

## Source Record Identifier Rules

ERP_PRODUCT

SOURCE_RECORD_ID = ERP_PRODUCT_ID

SUPPLIER_PRODUCT

SOURCE_RECORD_ID = SUPPLIER_PRODUCT_ID

INVENTORY_PRODUCT

SOURCE_RECORD_ID = INVENTORY_PRODUCT_ID

ECOMMERCE_PRODUCT

SOURCE_RECORD_ID = ECOMMERCE_PRODUCT_ID

---

## Data Handling Rules

Do not:

* Remove records
* Filter records
* Apply DQ rules
* Apply survivorship
* Standardize values
* Discover relationships

SOURCE_SUPERSET is a canonical landing layer only.

---

## Implementation Pattern

The final solution should follow this pattern:

CREATE OR REPLACE TABLE ... AS

SELECT ... FROM ERP_PRODUCT

UNION ALL

SELECT ... FROM SUPPLIER_PRODUCT

UNION ALL

SELECT ... FROM INVENTORY_PRODUCT

UNION ALL

SELECT ... FROM ECOMMERCE_PRODUCT

The implementation must use a single table rebuild operation.

---

## Output Requirements

Output executable Snowflake SQL only.

Include:

* One CREATE OR REPLACE TABLE AS SELECT statement

Do not include:

* INSERT statements
* Documentation
* Explanations
* Alternative Designs

---

## Validation Requirements

Expected record count:

Approximately 42,450 rows.

Each source record must appear exactly once.

---

## Success Criteria

Execution must create and populate:

RELATIONSHIP_DISCOVERY_DB.INTM.SOURCE_SUPERSET

using a fully rebuildable, idempotent implementation.

The next artifact will be:

sql/intm/006_dq_results.sql
