# PROMPT 006 – GENERATE DQ SCORING FRAMEWORK

## Objective

Generate executable Snowflake SQL required to create and populate a metadata-driven Data Quality framework.

The framework must evaluate SOURCE_SUPERSET records and generate:

* Attribute-Level DQ Results
* Record-Level DQ Summary
* DQ Scores
* DQ Statuses

The results will be consumed by future Relationship Discovery processing.

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

All approved decisions are mandatory.

---

## Existing Platform

Database:

RELATIONSHIP_DISCOVERY_DB

Metadata Schema:

MD

Intermediate Schema:

INTM

---

## Existing Metadata Tables

* MD_ATTRIBUTE_DQ_RULES
* MD_ATTRIBUTE_SURVIVORSHIP
* MD_ATTRIBUTE_MAPPING

---

## Existing Intermediate Tables

* SOURCE_SUPERSET

---

## Execution Strategy

DQ_RESULTS and DQ_RECORD_SUMMARY are intermediate processing objects.

The implementation must use:

CREATE OR REPLACE TABLE

The implementation must be idempotent.

Repeated execution must produce identical results.

INSERT statements are prohibited.

The implementation must rebuild the tables using:

CREATE OR REPLACE TABLE AS SELECT

patterns.

---

## Core Requirement

DQ evaluation must be metadata-driven.

MD_ATTRIBUTE_DQ_RULES is the authoritative source of DQ rules.

The implementation must use metadata from:

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_DQ_RULES

---

## Table 1

RELATIONSHIP_DISCOVERY_DB.INTM.DQ_RESULTS

---

## Required Columns

* DQ_RESULT_ID
* SOURCE_SYSTEM
* SOURCE_RECORD_ID
* ATTRIBUTE_NAME
* ATTRIBUTE_VALUE
* DQ_STATUS
* DQ_SCORE
* DQ_MESSAGE
* CREATED_DTTM

---

## Attributes To Evaluate

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

---

## Scoring Rules

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

## DQ Status Rules

PASS

Attribute satisfies metadata rule.

FAIL

Attribute violates metadata rule.

---

## DQ Message Rules

PASS

Attribute passed validation.

FAIL

Critical attribute missing.

Required value is null.

---

## Population Requirements

Generate one DQ_RESULTS record per:

SOURCE_RECORD × ATTRIBUTE

Expected volume:

Approximately 254,700 rows.

(42,450 × 6)

---

## DQ_RESULT_ID Requirement

Generate DQ_RESULT_ID using:

ROW_NUMBER()

Do NOT use AUTOINCREMENT.

The implementation must work inside:

CREATE OR REPLACE TABLE AS SELECT

---

## Attribute Extraction Requirement

Because SOURCE_SUPERSET uses an expanded structure, attribute extraction may use CASE logic.

This is acceptable.

However:

DQ rule evaluation must come from MD_ATTRIBUTE_DQ_RULES.

Hardcoded DQ rule definitions are prohibited.

---

## Table 2

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

Average of all attribute-level DQ scores.

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

## Record Status Rules

PASS

RECORD_DQ_SCORE >= 80

WARNING

RECORD_DQ_SCORE >= 60 and < 80

FAIL

RECORD_DQ_SCORE < 60

---

## Implementation Pattern

Table 1:

CREATE OR REPLACE TABLE INTM.DQ_RESULTS AS
SELECT ...

Table 2:

CREATE OR REPLACE TABLE INTM.DQ_RECORD_SUMMARY AS
SELECT ...
FROM INTM.DQ_RESULTS

No INSERT statements.

No TRUNCATE statements.

The implementation must fully rebuild both tables.

---

## Constraints

Do NOT generate:

* Relationship Discovery Logic
* Relationship Catalog
* Business Rules
* Golden Record Logic
* Tasks
* Views
* Reports

Generate DQ processing only.

---

## Output Requirements

Output executable Snowflake SQL only.

Include:

* CREATE OR REPLACE TABLE AS SELECT statements

Do not include:

* INSERT statements
* Documentation
* Explanations
* Alternative Designs

---

## Validation Requirements

Expected volumes:

DQ_RESULTS ≈ 254,700 rows

DQ_RECORD_SUMMARY ≈ 42,450 rows

The implementation must be fully rerunnable without producing duplicate records.

---

## Success Criteria

Execution must create and populate:

* RELATIONSHIP_DISCOVERY_DB.INTM.DQ_RESULTS
* RELATIONSHIP_DISCOVERY_DB.INTM.DQ_RECORD_SUMMARY

using a fully rebuildable and idempotent implementation.

The next artifact will be:

sql/intm/007_relationship_candidates.sql
