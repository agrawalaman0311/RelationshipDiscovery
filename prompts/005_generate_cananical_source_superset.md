# PROMPT 005 – GENERATE CANONICAL SOURCE_SUPERSET

## Objective

Generate executable Snowflake SQL required to create and populate SOURCE_SUPERSET.

SOURCE_SUPERSET is the canonical integration layer for the Relationship Discovery Framework.

SOURCE_SUPERSET shall use an expanded canonical structure.

EAV (Entity Attribute Value) / Key-Value designs are prohibited.

The table must provide a single standardized view of all source systems.

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

## Core Requirement

SOURCE_SUPERSET must be canonical and expanded.

Do NOT generate:

* Key-Value structures
* EAV models
* ATTRIBUTE_NAME columns
* ATTRIBUTE_VALUE columns

The resulting structure must be easy to consume by:

* DQ Processing
* Relationship Discovery
* Business Rules
* Golden Record Processing

---

## Table To Generate

Create:

RELATIONSHIP_DISCOVERY_DB.INTM.SOURCE_SUPERSET

---

## Required Columns

* SOURCE_SUPERSET_ID NUMBER AUTOINCREMENT

* SOURCE_SYSTEM VARCHAR(100)

* SOURCE_RECORD_ID VARCHAR(100)

* BRAND VARCHAR(500)

* PRODUCT_NAME VARCHAR(1000)

* CATEGORY VARCHAR(500)

* MANUFACTURER VARCHAR(500)

* SALE_PRICE NUMBER(18,2)

* SIZE VARCHAR(200)

* LOAD_DTTM TIMESTAMP

* CREATED_DTTM TIMESTAMP

---

## Metadata Driven Requirement

MD_ATTRIBUTE_MAPPING is the authoritative mapping source.

Hardcoded mapping logic should be avoided wherever practical.

The implementation must align with metadata definitions stored in:

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_MAPPING

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

Populate SOURCE_SUPERSET from all source systems.

Generate one SOURCE_SUPERSET record per source record.

Expected volumes:

ERP_PRODUCT

10,250 rows

SUPPLIER_PRODUCT

10,800 rows

INVENTORY_PRODUCT

10,450 rows

ECOMMERCE_PRODUCT

10,950 rows

Expected total:

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

## Data Quality Handling

Do not exclude records.

Do not remove nulls.

Do not standardize values.

Do not apply survivorship.

Do not perform matching.

SOURCE_SUPERSET is a landing layer only.

---

## Constraints

Do NOT generate:

* DQ Processing Logic
* Relationship Discovery Logic
* Relationship Catalog
* Business Rules
* DAL
* Golden Record Logic
* Tasks
* Views
* Reports

Generate SOURCE_SUPERSET only.

---

## Output Requirements

Output executable Snowflake SQL only.

Include:

* CREATE TABLE statement
* Population SQL

Do not include:

* Documentation
* Markdown
* Explanations
* Alternative Designs

---

## Validation Requirements

The final table must contain:

* One row per source record
* Standardized canonical column names
* Records from all source systems
* Traceability back to source systems

The resulting dataset must support future:

* DQ Processing
* Relationship Discovery
* Business Rules
* Golden Record Processing

---

## Success Criteria

Execution should create and populate:

RELATIONSHIP_DISCOVERY_DB.INTM.SOURCE_SUPERSET

The resulting table should provide a canonical expanded representation of all source records.

The next artifact will be:

sql/procedures/006_dq_processing.sql
