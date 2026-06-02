# PROMPT 010 – GENERATE ENTITY RESOLUTION

## Objective

Generate executable Snowflake SQL required to create and populate ENTITY_RESOLUTION.

ENTITY_RESOLUTION is the first mastering layer following relationship discovery.

The purpose of this layer is to transform source records into business entities representing real-world products.

For this implementation, entity formation must be based on deterministic business-key matching rather than graph traversal.

The implementation must identify records representing the same product and assign them to a common ENTITY_KEY.

This layer is responsible only for entity formation.

No survivorship processing should occur.

No canonical attribute selection should occur.

No ACTION_LOG processing should occur.

No DAL processing should occur.

---

## Output Location

sql/intm/010_entity_resolution.sql

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

Schema:

INTM

---

## Existing Tables

### Intermediate

* SOURCE_SUPERSET
* DQ_RESULTS
* DQ_RECORD_SUMMARY
* RELATIONSHIP_CANDIDATES
* RELATIONSHIP_CATALOG

### Framework

* INTM_PRODUCT_MASTER

### Logging

* ACTION_LOG

---

## Architectural Context

Relationship Discovery has already been completed.

Source systems may contain duplicate records representing the same real-world product.

Duplicates may exist:

* Within the same source system
* Across multiple source systems

The purpose of this layer is to resolve these records into business entities.

Entity Resolution must create one business entity representing one real-world product.

---

## Entity Formation Strategy

For this implementation, Entity Resolution must use deterministic business-key matching.

Business entities must be formed using normalized values of:

* BRAND
* PRODUCT_NAME
* SIZE

The implementation must standardize these attributes prior to grouping.

Typical standardization may include:

* UPPER casing
* Trimming whitespace
* Removing formatting inconsistencies

Records sharing the same normalized business key must be assigned to the same ENTITY_KEY.

Relationship graph traversal is not required.

Recursive connected-component logic is not required.

The objective is to create a stable and explainable business entity representing a single real-world product.

---

## Execution Strategy

ENTITY_RESOLUTION is an intermediate processing object.

The implementation must use:

CREATE OR REPLACE TABLE AS SELECT

The implementation must be idempotent.

Repeated execution must produce identical results.

INSERT statements are prohibited.

---

## Table To Generate

RELATIONSHIP_DISCOVERY_DB.INTM.ENTITY_RESOLUTION

---

## Required Output Columns

### Entity Identification

* ENTITY_KEY

### Business Key

* NORMALIZED_BRAND

* NORMALIZED_PRODUCT_NAME

* NORMALIZED_SIZE

### Source Lineage

* SOURCE_SYSTEM

* SOURCE_RECORD_ID

### Source Attributes

* BRAND

* PRODUCT_NAME

* CATEGORY

* MANUFACTURER

* SALE_PRICE

* SIZE

### Quality Metrics

* RECORD_DQ_SCORE

### Audit

* CREATED_DTTM

---

## Business Key Rules

Generate the following normalized attributes:

### NORMALIZED_BRAND

Based on:

BRAND

Apply:

* UPPER
* TRIM

### NORMALIZED_PRODUCT_NAME

Based on:

PRODUCT_NAME

Apply:

* UPPER
* TRIM

### NORMALIZED_SIZE

Based on:

SIZE

Apply:

* UPPER
* TRIM

The implementation may perform reasonable formatting standardization where appropriate.

---

## Entity Resolution Rules

Approved Business Key:

NORMALIZED_BRAND
+
NORMALIZED_PRODUCT_NAME
+
NORMALIZED_SIZE

All records sharing the same normalized business key must belong to the same ENTITY_KEY.

The implementation must preserve complete lineage for all participating source records.

Relationship information may be used for validation and diagnostics but is not required for entity formation.

---

## Entity Key Rules

Generate:

ENTITY_KEY

using deterministic ordering.

Format:

PRODUCT_000000001

PRODUCT_000000002

PRODUCT_000000003

Use:

ROW_NUMBER()

Do not use AUTOINCREMENT.

Repeated execution must generate identical ENTITY_KEY values.

---

## DQ Enrichment

Join to:

DQ_RECORD_SUMMARY

Populate:

RECORD_DQ_SCORE

for each participating source record.

---

## Lineage Requirements

Every source record participating in an entity must be retained.

The implementation must not:

* Select a winning record
* Remove lower DQ records
* Apply survivorship
* Collapse lineage

Complete lineage must be preserved.

Multiple source records may belong to the same ENTITY_KEY.

Multiple records from the same source system may belong to the same ENTITY_KEY.

---

## Source Ownership Validation

Each source record must belong to exactly one ENTITY_KEY.

The implementation must guarantee:

SOURCE_SYSTEM
+
SOURCE_RECORD_ID

appears only once in ENTITY_RESOLUTION.

No source record may belong to multiple entities.

---

## Constraints

Do NOT generate:

* Survivorship logic
* Canonical attribute selection
* Derived attribute logic
* ACTION_LOG processing
* DAL logic
* CREATE actions
* UPDATE actions
* DELETE actions
* MERGE actions
* SPLIT actions
* Tasks
* Procedures
* Streams
* Views
* Reports

Generate entity resolution only.

---

## Output Requirements

Output executable Snowflake SQL only.

Include:

* CREATE OR REPLACE TABLE AS SELECT

Do not include:

* INSERT statements
* Documentation
* Explanations
* Alternative Designs

---

## Validation Requirements

Each source record must belong to exactly one ENTITY_KEY.

No source record may belong to multiple entities.

ENTITY_KEY may contain:

* One source record
* Multiple source records
* Multiple records from the same source system

All lineage must be preserved.

---

## Success Criteria

Execution must create and populate:

RELATIONSHIP_DISCOVERY_DB.INTM.ENTITY_RESOLUTION

The resulting table must represent resolved business entities derived from standardized business-key matching.

Complete lineage must be preserved.

No survivorship processing should have occurred.

No mastering actions should have been generated.

The next artifact will be:

sql/br/011_generate_create_actions.sql

where survivorship logic and canonical attribute selection will be applied to generate CREATE actions for ACTION_LOG.
