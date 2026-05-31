# PROMPT 002 – GENERATE SOURCE TABLES

## Objective

Generate the Snowflake DDL required to create the approved source tables for the Relationship Discovery Framework Product MDM demonstration.

---

## Output Location

sql/source/002_source_tables.sql

Generate the contents of this file.

Do not generate any other files.

---

## Governance Inputs

Read and comply with:

* governance/001_MASTER_CONSTITUTION.md
* governance/002_APPROVED_DECISIONS_REGISTER.md
* governance/003_PROMPT_OS.md
* governance/004_PROJECT_CONTEXT.md
* governance/005_METADATA_DESIGN.md

All approved decisions are mandatory.

Do not redesign approved architecture.

---

## Approved Platform Structure

Database:

RELATIONSHIP_DISCOVERY_DB

Schema:

SRC

All source tables must be created in:

RELATIONSHIP_DISCOVERY_DB.SRC

---

## Approved Source Systems

Generate DDL for:

* ERP_PRODUCT
* SUPPLIER_PRODUCT
* INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT

---

## Source Table Standards

All source tables must:

1. Use Snowflake SQL.
2. Include a primary business identifier column.
3. Include LOAD_DTTM TIMESTAMP.
4. Support a minimum of 10,000 records.
5. Be optimized for Relationship Discovery.
6. Remain intentionally lean (8–10 columns per table).

---

## Mandatory Canonical Attribute Support

Across the four source systems, the following approved canonical attributes must be represented:

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

Source-specific naming differences should be intentionally preserved to support Relationship Discovery.

---

## Relationship Discovery Requirements

The source tables must support future generation of:

### T0

Direct Match

### T1

Prefix/Suffix Match

### T2

Left-N Character Match

### Rejected Candidates

False-positive relationship scenarios

The table structures must make these future scenarios possible.

---

## Recommended Source Columns

### ERP_PRODUCT

* ERP_PRODUCT_ID
* PRODUCT_CODE
* BRAND_NAME
* PRODUCT_DESCRIPTION
* PRODUCT_CATEGORY
* MANUFACTURER_NAME
* LIST_PRICE
* PRODUCT_SIZE
* LOAD_DTTM

### SUPPLIER_PRODUCT

* SUPPLIER_PRODUCT_ID
* ITEM_CODE
* ITEM_NAME
* BRAND
* CATEGORY_DESCRIPTION
* MFG_NAME
* UNIT_COST
* PACK_SIZE
* LOAD_DTTM

### INVENTORY_PRODUCT

* INVENTORY_PRODUCT_ID
* SKU_CODE
* SKU_DESCRIPTION
* BRAND_CODE
* STORAGE_CATEGORY
* REORDER_COST
* WEIGHT_SIZE
* LOAD_DTTM

### ECOMMERCE_PRODUCT

* ECOMMERCE_PRODUCT_ID
* VENDOR_CODE
* LISTING_TITLE
* VENDOR_NAME
* WEB_CATEGORY
* SELLER_NAME
* SELLING_PRICE
* DISPLAY_SIZE
* LOAD_DTTM

These columns are approved and should be used unless a compelling architectural reason exists not to.

---

## Constraints

Do NOT generate:

* INSERT statements
* Test data
* SOURCE_SUPERSET
* Metadata tables
* DQ tables
* Relationship Catalog tables
* BR modules
* DAL modules
* Procedures
* Tasks
* Views
* Reporting objects

Generate source table DDL only.

---

## Output Requirements

Output executable Snowflake SQL only.

Do not include:

* Explanations
* Markdown
* Documentation
* Design Notes
* Alternative Designs

---

## Success Criteria

The generated SQL must execute successfully in Snowflake.

The generated artifact must create all approved source tables.

The next artifact will be:

sql/source/003_source_test_data.sql
