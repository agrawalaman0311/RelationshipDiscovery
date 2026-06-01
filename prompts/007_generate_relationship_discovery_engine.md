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

## Performance Requirement

Cross joining SOURCE_SUPERSET is prohibited.

Unrestricted SOURCE_SUPERSET self-joins are prohibited.

The implementation must use blocking to reduce candidate volume before relationship evaluation.

Blocking must occur in the JOIN condition.

Approved blocking keys:

* LEFT(UPPER(BRAND),3)
* LEFT(UPPER(PRODUCT_NAME),3)

The implementation must only compare records that share at least one blocking key.

---

## Source Pairing Rules

Relationships must only be discovered across different source systems.

Allowed:

* ERP_PRODUCT ↔ SUPPLIER_PRODUCT
* ERP_PRODUCT ↔ INVENTORY_PRODUCT
* ERP_PRODUCT ↔ ECOMMERCE_PRODUCT
* SUPPLIER_PRODUCT ↔ INVENTORY_PRODUCT
* SUPPLIER_PRODUCT ↔ ECOMMERCE_PRODUCT
* INVENTORY_PRODUCT ↔ ECOMMERCE_PRODUCT

Prohibited:

* ERP_PRODUCT ↔ ERP_PRODUCT
* SUPPLIER_PRODUCT ↔ SUPPLIER_PRODUCT
* INVENTORY_PRODUCT ↔ INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT ↔ ECOMMERCE_PRODUCT

Duplicate reverse relationships are prohibited.

The implementation must ensure:

```sql
L.SOURCE_SYSTEM < R.SOURCE_SYSTEM
```

or equivalent logic.

---

## Relationship Types

### T0 – Exact Match

Definition:

* BRAND matches exactly
  AND
* PRODUCT_NAME matches exactly

Score:

* MATCH_SCORE = 100
* MATCH_CONFIDENCE = HIGH

---

### T1 – Partial Match

Definition:

One PRODUCT_NAME contains the other

OR

One BRAND contains the other

Score:

* MATCH_SCORE = 85
* MATCH_CONFIDENCE = MEDIUM

---

### T2 – Prefix Match

Definition:

LEFT(BRAND,3) matches

OR

LEFT(PRODUCT_NAME,3) matches

Score:

* MATCH_SCORE = 70
* MATCH_CONFIDENCE = LOW

---

### T3 – Rejected

Do not store T3 rows.

Only T0, T1 and T2 relationships should be persisted.

---

## DQ Integration

Use:

RELATIONSHIP_DISCOVERY_DB.INTM.DQ_RECORD_SUMMARY

to obtain:

RECORD_DQ_SCORE

for both records.

Calculate:

```text
DQ_WEIGHTED_SCORE
=
Average(
LEFT_RECORD_DQ_SCORE,
RIGHT_RECORD_DQ_SCORE
)
```

---

## RELATIONSHIP_ID Requirement

Generate:

RELATIONSHIP_ID

using:

ROW_NUMBER()

Do not use AUTOINCREMENT.

---

## Snowflake Compatibility Requirements

Use:

```sql
LENGTH()
```

Do NOT use:

```sql
LEN()
```

The generated SQL must be Snowflake compatible.

---

## Candidate Volume Requirement

The blocking strategy must significantly reduce comparison volume.

The implementation must not attempt a full pairwise comparison of all SOURCE_SUPERSET records.

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

* One CREATE OR REPLACE TABLE AS SELECT statement

Do not include:

* INSERT statements
* Documentation
* Explanations
* Alternative Designs

---

## Success Criteria

Execution must create and populate:

RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CANDIDATES

The implementation must:

* Use blocking
* Avoid candidate explosion
* Generate T0/T1/T2 relationships
* Include DQ-weighted confidence scoring
* Be fully rerunnable

The next artifact will be:

sql/intm/008_relationship_catalog.sql
