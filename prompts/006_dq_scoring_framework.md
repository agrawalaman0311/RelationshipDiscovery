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

Repeated execution must produce identical record counts.

CREATE TABLE IF NOT EXISTS is prohibited.

---

## Core Requirement

DQ evaluation must be metadata-driven.

MD_ATTRIBUTE_DQ_RULES is the authoritative source of DQ rules.

---

## Table 1

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

## Attributes To Evaluate

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

---

## Scoring Rules

Critical Attribute

If populated:

DQ_SCORE = 100

If null:

DQ_SCORE = 0

---

Non-Critical Attribute

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

---

## Population Requirements

Generate one DQ_RESULTS record per:

SOURCE_RECORD × ATTRIBUTE

Expected volume:

Approximately 254,700 rows.

(42,450 × 6)

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

Average all attribute-level DQ scores for the record.

---

## Record Status Rules

PASS

RECORD_DQ_SCORE >= 80

WARNING

RECORD_DQ_SCORE >= 60 and < 80

FAIL

RECORD_DQ_SCORE < 60

---

## Output Requirements

Output executable Snowflake SQL only.

Include:

* CREATE OR REPLACE TABLE statements
* Population SQL

Do not include:

* Documentation
* Explanations
* Alternative Designs

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

---

## Success Criteria

Execution must create and populate:

* INTM.DQ_RESULTS
* INTM.DQ_RECORD_SUMMARY

Expected volumes:

DQ_RESULTS ≈ 254,700

DQ_RECORD_SUMMARY ≈ 42,450

The next artifact will be:

sql/intm/007_relationship_candidates.sql
