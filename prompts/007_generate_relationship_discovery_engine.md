# PROMPT 007 – GENERATE RELATIONSHIP DISCOVERY ENGINE

## Objective

Generate executable Snowflake SQL required to create and populate RELATIONSHIP_CANDIDATES.

The Relationship Discovery Engine must identify candidate relationships between records originating from different source systems.

The engine must implement relationship logic defined in:

governance/006_RELATIONSHIP_DISCOVERY_RULES.md

The output will support:

* Relationship Discovery
* Match Confidence Scoring
* Golden Record Processing
* Relationship Catalog Creation

---

## Output Location

sql/intm/007_relationship_candidates.sql

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

Intermediate Schema:

INTM

Metadata Schema:

MD

---

## Existing Tables

### Intermediate

* SOURCE_SUPERSET
* DQ_RESULTS
* DQ_RECORD_SUMMARY

### Metadata

* MD_ATTRIBUTE_DQ_RULES
* MD_ATTRIBUTE_SURVIVORSHIP
* MD_ATTRIBUTE_MAPPING

---

## Execution Strategy

RELATIONSHIP_CANDIDATES is an intermediate processing object.

The implementation must use:

CREATE OR REPLACE TABLE AS SELECT

The implementation must be idempotent.

Repeated execution must produce identical results.

INSERT statements are prohibited.

---

## Table To Generate

RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CANDIDATES

---

## Required Columns

* RELATIONSHIP_ID

* LEFT_SOURCE_SYSTEM

* LEFT_SOURCE_RECORD_ID

* RIGHT_SOURCE_SYSTEM

* RIGHT_SOURCE_RECORD_ID

* MATCH_TYPE

* MATCH_SCORE

* MATCH_CONFIDENCE

* DQ_WEIGHTED_SCORE

* CREATED_DTTM

---

## Relationship Types

Implement the approved relationship definitions.

### T0

Exact Match

Definition:

BRAND matches exactly

AND

PRODUCT_NAME matches exactly

---

### T1

Prefix / Suffix Match

Definition:

One PRODUCT_NAME contains the other

OR

One BRAND contains the other

---

### T2

Left-N Match

Definition:

LEFT(BRAND,3) matches

OR

LEFT(PRODUCT_NAME,3) matches

---

### T3

Rejected Candidate

Definition:

Potential candidate exists

But does not satisfy T0, T1 or T2.

---

## Source Pairing Rules

Relationships must be discovered only across different source systems.

Allowed:

ERP_PRODUCT ↔ SUPPLIER_PRODUCT

ERP_PRODUCT ↔ INVENTORY_PRODUCT

ERP_PRODUCT ↔ ECOMMERCE_PRODUCT

SUPPLIER_PRODUCT ↔ INVENTORY_PRODUCT

SUPPLIER_PRODUCT ↔ ECOMMERCE_PRODUCT

INVENTORY_PRODUCT ↔ ECOMMERCE_PRODUCT

Prohibited:

ERP_PRODUCT ↔ ERP_PRODUCT

SUPPLIER_PRODUCT ↔ SUPPLIER_PRODUCT

etc.

---

## Candidate Generation Scope

Use:

SOURCE_SUPERSET

as the canonical source.

Use:

DQ_RECORD_SUMMARY

to obtain record quality scores.

---

## Match Scoring Rules

T0

MATCH_SCORE = 100

MATCH_CONFIDENCE = HIGH

---

T1

MATCH_SCORE = 85

MATCH_CONFIDENCE = MEDIUM

---

T2

MATCH_SCORE = 70

MATCH_CONFIDENCE = LOW

---

T3

MATCH_SCORE = 0

MATCH_CONFIDENCE = REJECTED

---

## DQ Weighted Score

Calculate:

Average of:

LEFT_RECORD_DQ_SCORE

and

RIGHT_RECORD_DQ_SCORE

Store as:

DQ_WEIGHTED_SCORE

---

## RELATIONSHIP_ID Requirement

Generate:

RELATIONSHIP_ID

using:

ROW_NUMBER()

Do not use AUTOINCREMENT.

---

## Deduplication Rules

A relationship pair may only appear once.

Allowed:

ERP_PRODUCT 1 ↔ SUPPLIER_PRODUCT 10

Prohibited:

SUPPLIER_PRODUCT 10 ↔ ERP_PRODUCT 1

Duplicate reverse relationships are not allowed.

---

## Constraints

Do NOT generate:

* Relationship Catalog
* Business Rules
* Survivorship Logic
* Golden Record Logic
* Tasks
* Views
* Reports

Generate relationship candidates only.

---

## Output Requirements

Output executable Snowflake SQL only.

Include:

* CREATE OR REPLACE TABLE AS SELECT statement

Do not include:

* INSERT statements
* Documentation
* Explanations
* Alternative Designs

---

## Validation Requirements

Output must contain:

* T0 relationships
* T1 relationships
* T2 relationships

Each relationship must include:

* Match Type
* Match Score
* Match Confidence
* DQ Weighted Score

---

## Success Criteria

Execution must create and populate:

RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CANDIDATES

The resulting table must provide relationship candidates suitable for downstream relationship catalog processing.

The next artifact will be:

sql/intm/008_relationship_catalog.sql
