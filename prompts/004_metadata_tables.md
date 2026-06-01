# PROMPT 004 – GENERATE COMPLETE METADATA FRAMEWORK

## Objective

Generate executable Snowflake SQL required to create and populate the approved metadata framework for the Relationship Discovery Framework.

The metadata framework will drive:

* Data Quality Validation
* Canonical Attribute Standardization
* Source-to-Canonical Mapping
* Survivorship Rules
* Relationship Discovery
* Business Rules
* SOURCE_SUPERSET Generation

---

## Output Location

sql/metadata/004_metadata_tables.sql

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

Do not redesign approved architecture.

---

## Existing Platform

Database:

RELATIONSHIP_DISCOVERY_DB

Schema:

MD

---

## Mandatory Validation Requirement

The generated output MUST contain exactly three CREATE TABLE statements.

The output is INVALID if any table is missing.

Required tables:

1. MD_ATTRIBUTE_DQ_RULES

2. MD_ATTRIBUTE_SURVIVORSHIP

3. MD_ATTRIBUTE_MAPPING

---

## Table 1

MD_ATTRIBUTE_DQ_RULES

Purpose:

Store attribute-level Data Quality requirements.

Required Columns:

* DQ_RULE_ID NUMBER AUTOINCREMENT
* ATTRIBUTE_NAME VARCHAR(100)
* IS_CRITICAL VARCHAR(1)
* NULL_ALLOWED VARCHAR(1)
* DQ_RULE_TYPE VARCHAR(50)
* DQ_RULE_DESCRIPTION VARCHAR(500)
* ACTIVE_FLAG VARCHAR(1)
* CREATED_DTTM TIMESTAMP

---

### Seed Records

Generate metadata for:

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

Approved Critical Attributes:

* BRAND
* PRODUCT_NAME
* SIZE

Approved Rules:

BRAND

* IS_CRITICAL = Y
* NULL_ALLOWED = N
* DQ_RULE_TYPE = NOT_NULL

PRODUCT_NAME

* IS_CRITICAL = Y
* NULL_ALLOWED = N
* DQ_RULE_TYPE = NOT_NULL

SIZE

* IS_CRITICAL = Y
* NULL_ALLOWED = N
* DQ_RULE_TYPE = NOT_NULL

CATEGORY

* IS_CRITICAL = N
* NULL_ALLOWED = Y

MANUFACTURER

* IS_CRITICAL = N
* NULL_ALLOWED = Y

SALE_PRICE

* IS_CRITICAL = N
* NULL_ALLOWED = Y

---

## Table 2

MD_ATTRIBUTE_SURVIVORSHIP

Purpose:

Store source prioritization and survivorship logic.

Required Columns:

* SURVIVORSHIP_RULE_ID NUMBER AUTOINCREMENT
* ATTRIBUTE_NAME VARCHAR(100)
* SOURCE_SYSTEM VARCHAR(100)
* PRIORITY_ORDER NUMBER
* ACTIVE_FLAG VARCHAR(1)
* CREATED_DTTM TIMESTAMP

---

### Approved Source Priority

Priority 1

ERP_PRODUCT

Priority 2

SUPPLIER_PRODUCT

Priority 3

ECOMMERCE_PRODUCT

Priority 4

INVENTORY_PRODUCT

---

### Seed Records

Generate survivorship records for:

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

Generate one record for every:

ATTRIBUTE × SOURCE_SYSTEM

combination.

---

## Table 3

MD_ATTRIBUTE_MAPPING

Purpose:

Store source-to-canonical attribute mappings.

This metadata will be consumed by:

* SOURCE_SUPERSET
* DQ Processing
* Relationship Discovery
* Business Rules

Required Columns:

* MAPPING_ID NUMBER AUTOINCREMENT
* CANONICAL_ATTRIBUTE VARCHAR(100)
* SOURCE_SYSTEM VARCHAR(100)
* SOURCE_ATTRIBUTE VARCHAR(100)
* ACTIVE_FLAG VARCHAR(1)
* CREATED_DTTM TIMESTAMP

---

### Approved Canonical Attributes

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

---

### Approved Source Attribute Mappings

BRAND

* ERP_PRODUCT → BRAND_NAME
* SUPPLIER_PRODUCT → BRAND
* INVENTORY_PRODUCT → BRAND_CODE
* ECOMMERCE_PRODUCT → VENDOR_NAME

PRODUCT_NAME

* ERP_PRODUCT → PRODUCT_DESCRIPTION
* SUPPLIER_PRODUCT → ITEM_NAME
* INVENTORY_PRODUCT → SKU_DESCRIPTION
* ECOMMERCE_PRODUCT → LISTING_TITLE

CATEGORY

* ERP_PRODUCT → PRODUCT_CATEGORY
* SUPPLIER_PRODUCT → CATEGORY_DESCRIPTION
* INVENTORY_PRODUCT → STORAGE_CATEGORY
* ECOMMERCE_PRODUCT → WEB_CATEGORY

MANUFACTURER

* ERP_PRODUCT → MANUFACTURER_NAME
* SUPPLIER_PRODUCT → MFG_NAME
* INVENTORY_PRODUCT → BRAND_CODE
* ECOMMERCE_PRODUCT → SELLER_NAME

SALE_PRICE

* ERP_PRODUCT → LIST_PRICE
* SUPPLIER_PRODUCT → UNIT_COST
* INVENTORY_PRODUCT → REORDER_COST
* ECOMMERCE_PRODUCT → SELLING_PRICE

SIZE

* ERP_PRODUCT → PRODUCT_SIZE
* SUPPLIER_PRODUCT → PACK_SIZE
* INVENTORY_PRODUCT → WEIGHT_SIZE
* ECOMMERCE_PRODUCT → DISPLAY_SIZE

Generate seed data for all approved mappings.

---

## Constraints

Do NOT generate:

* SOURCE_SUPERSET
* DQ Procedures
* Relationship Discovery Procedures
* Relationship Catalog
* Business Rules
* DAL
* Views
* Tasks
* Reports

Generate metadata tables only.

---

## Output Requirements

Output executable Snowflake SQL only.

Include:

* Three CREATE TABLE statements
* Metadata seed INSERT statements

Do not include:

* Documentation
* Markdown
* Explanations
* Alternative Designs

---

## Success Criteria

Execution must create and populate:

* RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_DQ_RULES
* RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_SURVIVORSHIP
* RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_MAPPING

The generated metadata must be sufficient to support a fully metadata-driven SOURCE_SUPERSET implementation.

The next artifact will be:

sql/intm/005_source_superset.sql
