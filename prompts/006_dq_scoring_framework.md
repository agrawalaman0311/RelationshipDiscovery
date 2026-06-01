# PROMPT 006 – GENERATE DQ SCORING FRAMEWORK

## Objective

Generate executable Snowflake SQL required to create and populate a metadata-driven Data Quality Results layer.

The DQ framework must evaluate records in SOURCE_SUPERSET using rules defined in MD_ATTRIBUTE_DQ_RULES.

The output must support:

* Record Quality Assessment
* Relationship Discovery Confidence
* Future Survivorship Processing
* Golden Record Creation

---

## Output Location

sql/intm/006_dq_results.sql

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

---

## Existing Platform

Database:

RELATIONSHIP_DISCOVERY_DB

Source Schema:

SRC

Metadata Schema:

MD

Intermediate Schema:

INTM

---

## Existing Tables

### Source

* ERP_PRODUCT
* SUPPLIER_PRODUCT
* INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT

### Metadata

* MD_ATTRIBUTE_DQ_RULES
* MD_ATTRIBUTE_SURVIVORSHIP
* MD_ATTRIBUTE_MAPPING

### Intermediate

* SOURCE_SUPERSET

---

## Core Requirement

DQ processing must be metadata-driven.

MD_ATTRIBUTE_DQ_RULES is the authoritative source of DQ requirements.

Hardcoded DQ rules are prohibited.

---

## Table To Generate

Create:

RELATIONSHIP_DISCOVERY_DB.INTM.DQ_RESULTS

---

## Required Columns

* DQ_RESULT_ID NUMBER AUTOINCREMENT
* SOURCE_SYSTEM VARCHAR(100)
* SOURCE_RECORD_ID VARCHAR(100)
* ATTRIBUTE_NAME VARCHAR(100)
* ATTRIBUTE_VALUE VARCHAR(5000)
* DQ_STATUS VARCHAR(20)
* DQ_SCORE NUMBER(5,2)
* DQ_MESSAGE VARCHAR(500)
* CREATED_DTTM TIMESTAMP

---

## DQ Evaluation Scope

Evaluate the following canonical attributes:

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

---

## Approved DQ Rules

Read rules from:

MD_ATTRIBUTE_DQ_RULES

Current metadata includes:

Critical:

* BRAND
* PRODUCT_NAME
* SIZE

Rule:

NOT_NULL

---

## Scoring Model

### Critical Attribute

If populated:

DQ_SCORE = 100

If null:

DQ_SCORE = 0

---

### Non-Critical Attribute

If populated:

DQ_SCORE = 100

If null:

DQ_SCORE = 50

---

## DQ Status Logic

PASS

Attribute satisfies metadata rule.

FAIL

Attribute violates metadata rule.

---

## DQ Message Logic

Examples:

PASS

"Attribute passed validation"

FAIL

"Critical attribute missing"

FAIL

"Required value is null"

---

## Population Requirements

Generate one DQ_RESULTS row for each:

SOURCE_RECORD × ATTRIBUTE

Expected scale:

Approximately:

42,450 source records

×

6 attributes

≈ 254,700 DQ evaluations

---

## Record-Level DQ Summary

Additionally create:

RELATIONSHIP_DISCOVERY_DB.INTM.DQ_RECORD_SUMMARY

---

## Required Columns

* SOURCE_SYSTEM
* SOURCE_RECORD_ID
* TOTAL_ATTRIBUTES
* PASSED_ATTRIBUTES
* FAILED_ATTRIBUTES
* RECORD_DQ_SCORE
* RECORD_DQ_STATUS
* CREATED_DTTM

---

## Record Score Calculation

Calculate:

Average of attribute-level DQ scores.

Example:

BRAND = 100

PRODUCT_NAME = 100

CATEGORY = 50

MANUFACTURER = 100

SALE_PRICE = 100

SIZE = 0

Record Score:

450 / 6

= 75

---

## Record Status

PASS

RECORD_DQ_SCORE >= 80

WARNING

RECORD_DQ_SCORE >= 60 and < 80

FAIL

RECORD_DQ_SCORE < 60

---

## Constraints

Do NOT generate:

* Relationship Discovery Logic
* Relationship Catalog
* Business Rules
* Survivorship Logic
* Golden Records
* Tasks
* Views
* Reports

Generate DQ processing only.

---

## Output Requirements

Output executable Snowflake SQL only.

Include:

* CREATE TABLE statements
* Population SQL

Do not include:

* Documentation
* Explanations
* Markdown
* Alternative Designs

---

## Success Criteria

Execution must create and populate:

* INTM.DQ_RESULTS
* INTM.DQ_RECORD_SUMMARY

The resulting DQ scores must be usable by future Relationship Discovery processing.

The next artifact will be:

sql/procedures/007_relationship_discovery.sql
