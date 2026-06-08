# PROMPT 010 – GENERATE MASTER CANDIDATE CREATE ACTIONS

## Objective

Generate executable Snowflake SQL that creates Product Master candidate CREATE actions.

The implementation shall:

* Use SOURCE_SUPERSET as the canonical source.
* Deduplicate records within each source system.
* Create a wide product view using FULL OUTER JOIN.
* Apply metadata-driven attribute survivorship.
* Capture attribute-level lineage.
* Perform final master deduplication.
* Generate deterministic ENTITY_KEY values.
* Generate CREATE actions only.

Physical master creation remains the responsibility of DAL.

---

# Output

Generate SQL for:

sql/br/010_generate_master_candidate_actions.sql

Generate only the SQL contents of this file.

---

# Governance Inputs

Read and comply with:

* governance/001_MASTER_CONSTITUTION.md
* governance/002_APPROVED_DECISIONS_REGISTER.md
* governance/003_PROMPT_OS.md
* governance/004_PROJECT_CONTEXT.md
* governance/005_METADATA_DESIGN.md

All approved decisions are mandatory.

---

# Source Tables

## Canonical Source

RELATIONSHIP_DISCOVERY_DB.INTM.SOURCE_SUPERSET

## Data Quality

RELATIONSHIP_DISCOVERY_DB.INTM.DQ_RECORD_SUMMARY

## Metadata

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_SURVIVORSHIP

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_DQ_RULES

## Target

RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG

---

# Business Context

This Business Rule demonstrates Product Master Data Management using canonicalized product data.

The implementation shall use:

* source-system deduplication
* metadata-driven survivorship
* data quality governance
* deterministic master generation

The implementation must remain explainable, auditable and repeatable.

The design shall follow:

```text
SOURCE_SUPERSET
      ↓
NORMALIZATION
      ↓
SOURCE DEDUPLICATION
      ↓
SOURCE SEGMENTATION
      ↓
FULL OUTER JOIN
      ↓
WIDE PRODUCT VIEW
      ↓
ATTRIBUTE SURVIVORSHIP
      ↓
ATTRIBUTE LINEAGE
      ↓
MASTER RECORD
      ↓
MASTER DEDUPLICATION
      ↓
ENTITY_KEY GENERATION
      ↓
CREATE ACTION
```

---

# Phase 1 – Canonical Normalization

Read records from SOURCE_SUPERSET.

Create:

* NORMALIZED_BRAND
* NORMALIZED_PRODUCT_NAME
* NORMALIZED_SIZE

using:

* UPPER()
* TRIM()

Convert NULL values to empty strings for normalization purposes only.

Original source values must remain unchanged.

---

# Phase 2 – Source-System Deduplication

Deduplicate records independently within each source system.

Duplicate detection must use:

* SOURCE_SYSTEM
* NORMALIZED_BRAND
* NORMALIZED_PRODUCT_NAME
* NORMALIZED_SIZE

Within each duplicate group retain exactly one surviving record.

Selection order:

1. Highest RECORD_DQ_SCORE
2. Lowest SOURCE_RECORD_ID

Use:

ROW_NUMBER()

for deterministic selection.

Exclude all non-surviving records from downstream processing.

SOURCE_SUPERSET must never be modified.

---

# Phase 3 – Source Segmentation

Create separate datasets for:

* ERP_PRODUCT
* SUPPLIER_PRODUCT
* INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT

Each dataset shall contain only surviving records from Phase 2.

---

# Phase 4 – Wide Product Assembly

Using the source-specific datasets:

* ERP_PRODUCT
* SUPPLIER_PRODUCT
* INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT

Create a single wide product view using FULL OUTER JOIN operations.

Join using:

* NORMALIZED_BRAND
* NORMALIZED_PRODUCT_NAME
* NORMALIZED_SIZE

The objective is to align source-system representations of the same business product into a single consolidated record.

No source system shall be treated as the driving source.

Do not create:

* Business Key Universe
* Entity Registry
* Neutral Driver Dataset
* Product Identity Dataset
* Any intermediary identity table

The wide product view must be assembled directly from the source-specific datasets.

The resulting wide record shall contain source-specific versions of all attributes.

Example:

ERP_BRAND

ERP_PRODUCT_NAME

ERP_CATEGORY

ERP_MANUFACTURER

ERP_SALE_PRICE

ERP_SIZE

SUPPLIER_BRAND

SUPPLIER_PRODUCT_NAME

SUPPLIER_CATEGORY

SUPPLIER_MANUFACTURER

SUPPLIER_SALE_PRICE

SUPPLIER_SIZE

INVENTORY_BRAND

INVENTORY_PRODUCT_NAME

INVENTORY_CATEGORY

INVENTORY_MANUFACTURER

INVENTORY_SALE_PRICE

INVENTORY_SIZE

ECOMMERCE_BRAND

ECOMMERCE_PRODUCT_NAME

ECOMMERCE_CATEGORY

ECOMMERCE_MANUFACTURER

ECOMMERCE_SALE_PRICE

ECOMMERCE_SIZE

Generate:

SOURCE_COVERAGE

representing the number of participating source systems contributing to the assembled record.

All source-specific attributes must remain available for survivorship processing.

---

# Phase 5 – Data Quality Governance

Create a centralized DQ threshold.

MIN_DQ_SCORE = 60

Only attribute values originating from records meeting the minimum DQ threshold may participate in survivorship.

Attribute values from records below the threshold shall be ignored during survivorship processing.

The threshold shall be defined once and reused throughout the implementation.

Hard-coded DQ thresholds scattered throughout the SQL are prohibited.

---

# Phase 6 – Metadata-Driven Attribute Survivorship

Apply survivorship independently for:

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

Use:

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_SURVIVORSHIP

as the authoritative source priority configuration.

Hard-coded source precedence is prohibited.

The implementation must use a metadata-driven survivorship framework.

Avoid unnecessary duplication of survivorship logic.

For each attribute:

1. Evaluate all source-specific values available in the wide product record.
2. Ignore NULL values.
3. Ignore blank values.
4. Ignore values from records below MIN_DQ_SCORE.
5. Apply source priority from metadata.
6. Select the highest-priority valid value.
7. Produce a single surviving value.
8. Capture the contributing source system.

Example:

ERP_BRAND = NULL

SUPPLIER_BRAND = CATALYST

ECOMMERCE_BRAND = CATALYST CORP

Result:

MASTER_BRAND = CATALYST

Null values must never win survivorship.

A lower-priority source may win when higher-priority sources contain NULL, blank, or low-quality values.

---

# Phase 7 – Attribute Lineage

For every survived attribute generate lineage.

Create:

* MASTER_BRAND_SOURCE
* MASTER_PRODUCT_NAME_SOURCE
* MASTER_CATEGORY_SOURCE
* MASTER_MANUFACTURER_SOURCE
* MASTER_SALE_PRICE_SOURCE
* MASTER_SIZE_SOURCE

Example:

MASTER_BRAND = CATALYST

MASTER_BRAND_SOURCE = SUPPLIER_PRODUCT

All survivorship decisions must be auditable.

Lineage must identify exactly which source system contributed the surviving value.

---

# Phase 8 – Master Record Creation

Create a mastered product record using survived attributes.

Generate:

* MASTER_BRAND
* MASTER_PRODUCT_NAME
* MASTER_CATEGORY
* MASTER_MANUFACTURER
* MASTER_SALE_PRICE
* MASTER_SIZE

If survivorship does not produce a value for a critical attribute, apply fallback logic using the normalized value available in the assembled record.

Critical attributes:

* BRAND
* PRODUCT_NAME
* SIZE

The same values used for the mastered record must be used for:

* master deduplication
* ENTITY_KEY generation

This prevents inconsistencies.

---

# Phase 9 – Final Master Deduplication

After survivorship completes:

Deduplicate mastered records using:

* MASTER_BRAND
* MASTER_PRODUCT_NAME
* MASTER_SIZE

using normalized comparison logic.

The purpose is to remove duplicate mastered products that may result from source-system variations or survivorship outcomes.

Within duplicate groups retain exactly one master record.

Selection order:

1. Highest SOURCE_COVERAGE
2. Highest AVG_RECORD_DQ_SCORE
3. Lowest representative source record identifier

Only one mastered record may survive for a given:

* MASTER_BRAND
* MASTER_PRODUCT_NAME
* MASTER_SIZE

combination.

Do not generate or persist ENTITY_MEMBER_COUNT.

Master deduplication exists solely to guarantee uniqueness of the final mastered product.

---

# Phase 10 – ENTITY_KEY Generation

Generate ENTITY_KEY only after final master deduplication.

Generate ENTITY_KEY using:

* MASTER_BRAND
* MASTER_PRODUCT_NAME
* MASTER_SIZE

Generate:

MD5_HEX(
UPPER(TRIM(MASTER_BRAND))
|| '|'
|| UPPER(TRIM(MASTER_PRODUCT_NAME))
|| '|'
|| UPPER(TRIM(MASTER_SIZE))
)

Requirements:

* deterministic
* repeatable
* stable across executions
* independent of execution order

The same mastered product must always generate the same ENTITY_KEY.

Do not use:

* ROW_NUMBER
* AUTOINCREMENT
* SEQUENCES

for ENTITY_KEY generation.

---

# Phase 11 – Final Quality Protection

Before CREATE action generation:

Exclude records where:

* MASTER_BRAND is NULL
* MASTER_PRODUCT_NAME is NULL
* MASTER_SIZE is NULL

Exclude records where:

* MASTER_BRAND is blank
* MASTER_PRODUCT_NAME is blank
* MASTER_SIZE is blank

Only complete master records may proceed.

---

# Phase 12 – CREATE Action Generation

Insert one CREATE action into:

RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG

for each mastered product.

Populate:

ACTION_TYPE = 'CREATE'

ACTION_STATUS = 'PENDING'

ACTIONED_FLAG = 'N'

Populate:

* ENTITY_KEY
* ERP_PRODUCT_ID
* SUPPLIER_PRODUCT_ID
* INVENTORY_PRODUCT_ID
* ECOMMERCE_PRODUCT_ID
* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

Populate:

SOURCE_EXECUTION_REFERENCE

using lineage generated during survivorship.

Populate derived attributes as NULL.

---

# Phase 13 – Final Uniqueness Protection

Before insertion into ACTION_LOG:

Apply:

ROW_NUMBER()

partitioned by:

ENTITY_KEY

Retain:

ROW_NUMBER = 1

This guarantees:

One ENTITY_KEY = One CREATE Action

Duplicate CREATE actions are prohibited.

---

# Validation Requirements

The generated SQL must support validation proving:

1. ENTITY_KEY count equals CREATE action count.
2. Duplicate ENTITY_KEY values do not exist.
3. Survivorship decisions are reproducible.
4. DQ thresholds are consistently enforced.
5. Source lineage is auditable.
6. Critical attributes are always populated.

---

# Constraints

Do NOT generate:

* DAL logic
* UPDATE actions
* DELETE actions
* MERGE actions
* SPLIT actions
* Versioning logic
* Tasks
* Procedures
* Streams
* Views

Generate CREATE actions only.

---

# Success Criteria

Execution populates ACTION_LOG with trusted master candidate CREATE actions generated through:

* source-system deduplication
* wide product assembly
* metadata-driven survivorship
* attribute lineage
* master deduplication
* deterministic ENTITY_KEY generation

The next artifact will be:

sql/dal/011_create_master_records.sql

which consumes CREATE actions and creates physical master records.

# Phase 14 – Implementation Guardrails

## Purpose

This section defines mandatory implementation constraints.

These constraints override any inferred implementation decisions made by the SQL generation process.

If any generated implementation conflicts with these guardrails, the guardrails take precedence.

---

## Wide Product Assembly Constraints

The implementation shall create the wide product view directly from the source-specific datasets.

Required processing flow:

SOURCE_SUPERSET
→ SOURCE DEDUPLICATION
→ SOURCE SEGMENTATION
→ FULL OUTER JOIN
→ WIDE PRODUCT VIEW

The implementation must not introduce intermediary identity structures.

Do not generate:

* Business Key Universe
* Entity Registry
* Neutral Driver Dataset
* Product Identity Dataset
* Canonical Identity Dataset
* Master Driver Dataset

No source system shall be treated as the driving source.

The wide product view must be assembled directly from:

* ERP_PRODUCT
* SUPPLIER_PRODUCT
* INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT

using FULL OUTER JOIN operations.

---

## Survivorship Constraints

Survivorship shall be attribute-driven.

The implementation must not perform:

* Record-level survivorship
* Golden record selection
* Source winner selection
* Single-record consolidation

The implementation shall:

1. Assemble the wide product view.
2. Evaluate source-specific attributes.
3. Apply metadata-driven survivorship.
4. Produce surviving attribute values.

Attribute-level survivorship is mandatory.

---

## Source Priority Constraints

Source precedence shall be obtained exclusively from:

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_SURVIVORSHIP

Hard-coded source precedence is prohibited.

Examples of prohibited logic:

ERP → SUPPLIER → INVENTORY → ECOMMERCE

SUPPLIER → ERP → INVENTORY → ECOMMERCE

or any other manually coded ordering.

Source precedence must always originate from metadata.

---

## Data Quality Constraints

Only attribute values originating from records meeting:

MIN_DQ_SCORE

may participate in survivorship.

Records below the threshold may remain visible in the wide product view but their attribute values must not win survivorship.

Null values must never win survivorship.

Blank values must never win survivorship.

---

## Attribute Lineage Constraints

Every survived attribute must retain lineage.

Required lineage attributes:

* MASTER_BRAND_SOURCE
* MASTER_PRODUCT_NAME_SOURCE
* MASTER_CATEGORY_SOURCE
* MASTER_MANUFACTURER_SOURCE
* MASTER_SALE_PRICE_SOURCE
* MASTER_SIZE_SOURCE

The lineage value must identify the source system contributing the surviving value.

All survivorship decisions must be fully auditable.

---

## Non-Critical Attribute Fallback Constraints

For:

* CATEGORY
* MANUFACTURER
* SALE_PRICE

If survivorship does not produce a value:

Fallback to the first available source value according to metadata-defined source priority.

Fallback must occur before:

* master deduplication
* ENTITY_KEY generation
* CREATE action generation

---

## Master Deduplication Constraints

Master deduplication shall occur only after:

* wide product assembly
* attribute survivorship
* master record creation

Deduplication shall operate on:

* MASTER_BRAND
* MASTER_PRODUCT_NAME
* MASTER_SIZE

using normalized comparison logic.

No source-specific attributes may participate in final master deduplication.

Selection order:

1. Highest SOURCE_COVERAGE
2. Highest AVG_RECORD_DQ_SCORE

If ties remain:

Use the lowest available participating source identifier across all contributing systems.

No source system shall be favoured.

ERP_PRODUCT_ID must not be used as a dedicated tie breaker.

---

## ENTITY_KEY Constraints

ENTITY_KEY generation shall occur only after final master deduplication.

ENTITY_KEY must be generated using:

* MASTER_BRAND
* MASTER_PRODUCT_NAME
* MASTER_SIZE

Required implementation:

MD5_HEX(
UPPER(TRIM(MASTER_BRAND))
|| '|'
|| UPPER(TRIM(MASTER_PRODUCT_NAME))
|| '|'
|| UPPER(TRIM(MASTER_SIZE))
)

MD5 must not be used.

ROW_NUMBER, AUTOINCREMENT and SEQUENCE-based entity keys are prohibited.

The same mastered product must always generate the same ENTITY_KEY.

---

## Relationship Discovery Constraints

Relationship Discovery remains a platform capability.

However this Business Rule shall not use:

* Graph Traversal
* Connected Components
* Relationship Catalog Consolidation
* Relationship-Based Entity Resolution

Master candidate creation in this Business Rule is driven by:

* SOURCE_SUPERSET
* Metadata-Driven Survivorship
* Data Quality Governance
* Wide Product Consolidation

---

## Prohibited Concepts

Do not generate:

* Business Key Universe
* Entity Registry
* Neutral Driver Dataset
* Product Identity Dataset
* Canonical Identity Dataset
* Golden Record Selection
* Record Winner Selection
* Graph Traversal
* Connected Component Processing
* Relationship-Based Consolidation

The implementation must remain a metadata-driven MDM consolidation process built directly from SOURCE_SUPERSET.
