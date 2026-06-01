# PROMPT 004 – GENERATE METADATA TABLES

## Objective

Generate executable Snowflake SQL required to create and populate the approved metadata tables for the Relationship Discovery Framework.

These metadata tables will drive:

- Data Quality Validation
- Survivorship Rules
- Future Business Rules
- Relationship Discovery

---

## Output Location

sql/metadata/004_metadata_tables.sql

Generate the contents of this file.

Do not generate any additional files.

---

## Governance Inputs

Read and comply with:

- governance/001_MASTER_CONSTITUTION.md
- governance/002_APPROVED_DECISIONS_REGISTER.md
- governance/003_PROMPT_OS.md
- governance/004_PROJECT_CONTEXT.md
- governance/005_METADATA_DESIGN.md
- governance/006_RELATIONSHIP_DISCOVERY_RULES.md

All approved decisions are mandatory.

Do not redesign approved architecture.

---

## Existing Platform

Database:

RELATIONSHIP_DISCOVERY_DB

Schema:

MD

---

## Tables To Generate

1. MD_ATTRIBUTE_DQ_RULES

Purpose:
Store attribute-level data quality rules.

2. MD_ATTRIBUTE_SURVIVORSHIP

Purpose:
Store source priority and survivorship logic.

---

## Generate Table: MD_ATTRIBUTE_DQ_RULES

Required Columns:

- ATTRIBUTE_NAME
- IS_CRITICAL
- NULL_ALLOWED
- DQ_RULE_TYPE
- DQ_RULE_DESCRIPTION
- ACTIVE_FLAG
- CREATED_DTTM

Generate seed metadata records for:

- BRAND
- PRODUCT_NAME
- CATEGORY
- MANUFACTURER
- SALE_PRICE
- SIZE

Approved Critical Attributes:

- BRAND
- PRODUCT_NAME
- SIZE

Approved DQ Rules:

BRAND
- IS_CRITICAL = Y
- NULL_ALLOWED = N
- DQ_RULE_TYPE = NOT_NULL

PRODUCT_NAME
- IS_CRITICAL = Y
- NULL_ALLOWED = N
- DQ_RULE_TYPE = NOT_NULL

SIZE
- IS_CRITICAL = Y
- NULL_ALLOWED = N
- DQ_RULE_TYPE = NOT_NULL

CATEGORY
- IS_CRITICAL = N
- NULL_ALLOWED = Y

MANUFACTURER
- IS_CRITICAL = N
- NULL_ALLOWED = Y

SALE_PRICE
- IS_CRITICAL = N
- NULL_ALLOWED = Y

---

## Generate Table: MD_ATTRIBUTE_SURVIVORSHIP

Required Columns:

- ATTRIBUTE_NAME
- SOURCE_SYSTEM
- PRIORITY_ORDER
- ACTIVE_FLAG
- CREATED_DTTM

Generate survivorship metadata for:

- BRAND
- PRODUCT_NAME
- CATEGORY
- MANUFACTURER
- SALE_PRICE
- SIZE

Approved Source Priority:

1 = ERP_PRODUCT

2 = SUPPLIER_PRODUCT

3 = ECOMMERCE_PRODUCT

4 = INVENTORY_PRODUCT

Generate survivorship records for every attribute/source combination.

Example:

ATTRIBUTE_NAME = BRAND
SOURCE_SYSTEM = ERP_PRODUCT
PRIORITY_ORDER = 1

ATTRIBUTE_NAME = BRAND
SOURCE_SYSTEM = SUPPLIER_PRODUCT
PRIORITY_ORDER = 2

ATTRIBUTE_NAME = BRAND
SOURCE_SYSTEM = ECOMMERCE_PRODUCT
PRIORITY_ORDER = 3

ATTRIBUTE_NAME = BRAND
SOURCE_SYSTEM = INVENTORY_PRODUCT
PRIORITY_ORDER = 4

Repeat for all approved attributes.

---

## Constraints

Do NOT generate:

- SOURCE_SUPERSET
- DQ Procedures
- Relationship Discovery Procedures
- Relationship Catalog
- Business Rules
- DAL
- Views
- Tasks
- Reports

Generate metadata tables only.

---

## Output Requirements

Output executable Snowflake SQL only.

Include:

- CREATE TABLE statements
- Metadata seed INSERT statements

Do not include:

- Markdown
- Documentation
- Explanations
- Alternative Designs

---

## Success Criteria

Execution should create:

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_DQ_RULES

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_SURVIVORSHIP

and populate them with approved metadata.

The next artifact will be:

sql/intm/005_source_superset.sql
