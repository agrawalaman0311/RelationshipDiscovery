# APPROVED DECISIONS REGISTER (ADR)

Version: 1.0

Status: APPROVED

---

# ADR-001: Solution Type

## Decision

Relationship Discovery Framework

## Status

Approved

---

# ADR-002: Demonstration Use Case

## Decision

Product Master Data Management (MDM)

## Status

Approved

---

# ADR-003: Primary Capability

## Decision

Relationship Discovery

## Status

Approved

---

# ADR-004: Primary Asset

## Decision

RELATIONSHIP_CATALOG

## Status

Approved

---

# ADR-005: Source Systems

## Decision

The Product MDM demonstration will use:

* ERP_PRODUCT
* SUPPLIER_PRODUCT
* INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT

## Status

Approved

---

# ADR-006: Minimum Data Volume

## Decision

Minimum 10,000 records per source system.

## Status

Approved

---

# ADR-007: Canonical Product Attributes

## Decision

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

## Status

Approved

---

# ADR-008: Critical Attributes

## Decision

Critical attributes:

* BRAND
* PRODUCT_NAME

## Status

Approved

---

# ADR-009: Golden Key

## Decision

Golden Key format:

BRAND|PRODUCT_NAME|SIZE

## Status

Approved

---

# ADR-010: Processing Pattern

## Decision

Mandatory processing pattern:

BR → ACTION_LOG → DAL → INTM

## Status

Approved

---

# ADR-011: System of Record

## Decision

INTM_PRODUCT is the system of record.

## Status

Approved

---

# ADR-012: Relationship Discovery Method

## Decision

Pairwise relationship discovery across source systems.

## Status

Approved

---

# ADR-013: Relationship Validation Scope

## Decision

Relationship validation must operate against full datasets.

Sampling is not permitted.

## Status

Approved

---

# ADR-014: Relationship Catalog Granularity

## Decision

Relationships are stored at attribute level.

Example:

ERP.PRODUCT_CODE ↔ SUPPLIER.ITEM_CODE

## Status

Approved

---

# ADR-015: Relationship Catalog Strategy

## Decision

RELATIONSHIP_CATALOG is a reusable enterprise asset.

Discover once.

Reuse many times.

## Status

Approved

---

# ADR-016: Transformation Library

## Decision

Approved transformations:

* T0 Direct Match
* T1 Prefix/Suffix Removal
* T2 Left-N Character Match

## Status

Approved

---

# ADR-017: Source Harmonization Strategy

## Decision

Source-to-SOURCE_SUPERSET mappings are hardcoded.

## Status

Approved

---

# ADR-018: Data Quality Execution Point

## Decision

DQ executes only at SOURCE_SUPERSET.

## Status

Approved

---

# ADR-019: Survivorship Strategy

## Decision

Attribute-level survivorship.

Metadata-driven source priority.

## Status

Approved

---

# ADR-020: Relationship Discovery Evidence

## Decision

Accepted and rejected relationship candidates must be retained.

Supporting evidence must be retained.

## Status

Approved

---

# ADR-021: CREATE BR Responsibilities

## Decision

CREATE BR is responsible for:

* Golden Key generation
* Duplicate prevention
* Create eligibility determination
* Create action generation

## Status

Approved

---

# ADR-022: CREATE BR Duplicate Handling

## Decision

If Golden Key already exists:

* CREATE action is not executed
* Action is marked REDUNDANT

## Status

Approved

---

# ADR-023: UPDATE BR Responsibilities

## Decision

UPDATE BR is responsible for:

* Update eligibility determination
* Update action generation

## Status

Approved

---

# ADR-024: UPDATE BR Validation

## Decision

UPDATE actions are generated only when the Golden Key exists.

Otherwise:

* Action is not executed
* Action is marked REDUNDANT

## Status

Approved

---

# ADR-025: ACTION_LOG Strategy

## Decision

ACTION_LOG is the integration contract between BR and DAL.

## Status

Approved

---

# ADR-026: DAL Responsibilities

## Decision

DAL owns:

* State materialization
* Version creation
* Soft delete processing
* History maintenance

## Status

Approved

---

# ADR-027: INTM Strategy

## Decision

INTM_PRODUCT stores:

* Active records
* Historical records
* Lineage
* Enrichment results
* Version history

## Status

Approved

---

# ADR-028: Enrichment Processing

## Decision

Enrichments operate against all active INTM records.

## Status

Approved

---

# ADR-029: Enrichment Materialization

## Decision

All enrichment results must be materialized through:

BR → ACTION_LOG → DAL → INTM

## Status

Approved

---

# ADR-030: FINAL Layer Strategy

## Decision

FINAL_PRODUCT is a presentation layer.

FINAL_PRODUCT is not the system of record.

## Status

Approved

---

# ADR-031: AI Visibility

## Decision

Judges will see:

* Prompts
* Generated artifacts
* Generated implementation outputs

## Status

Approved

---

# ADR-032: Cortex Responsibilities

## Decision

Cortex generates:

* Source schemas
* DDL
* Synthetic data
* BR modules
* DAL modules
* Stored procedures
* Tasks
* Views
* Reporting objects

## Status

Approved

---

# ADR-033: Prompt Governance

## Decision

One Prompt = One Artifact

## Status

Approved

---

# ADR-034: Prompt Approval Process

## Decision

Every artifact must be approved before the next prompt is executed.

## Status

Approved

---

# ADR-035: Git Governance Strategy

## Decision

All governance artifacts, prompts, outputs, and implementation artifacts must be stored in Git for traceability and auditability.

## Status

Approved

# ADR-036: Environment Strategy

## Decision

Single database deployment.

Database

RELATIONSHIP_DISCOVERY_DB

## Status

Approved

# ADR-037: Schema Strategy

## Decision

The solution will use the following schemas:
| Schema | Purpose                         |
| ------ | ------------------------------- |
| SRC    | Source Systems                  |
| MD     | Metadata                        |
| LOG    | Action Logs                     |
| INTM   | Intermediate / System of Record |
| FINAL  | Presentation Layer              |
| RPT    | Reporting                       |

## Status

Approved

# ADR-038: Source Table Complexity

## Decision

Source tables will be intentionally lean.

Target:

8–10 columns per source table

Focus:

Relationship Discovery

not operational ERP realism.

# ADR-039: Source Table Standard

## Decision

All source tables shall include:

- Surrogate Identifier
- LOAD_DTTM

Primary key constraints are not required.

## Status

Approved

# ADR-040: Demo Data Volume

## Decision

10,000 rows per source system

Applies to:

ERP_PRODUCT
SUPPLIER_PRODUCT
INVENTORY_PRODUCT
ECOMMERCE_PRODUCT

## Status

Approved

# ADR-041
## Decision
Snowflake PK constraints are informational only.

AUTOINCREMENT + PRIMARY KEY is acceptable for metadata tables.

No FK enforcement required.

## Status

Approved

# ADR-042
## Decision
SOURCE_SUPERSET shall use a canonical expanded structure.

EAV / key-value representation is rejected.

## Reason
Simpler DQ, Relationship Discovery, BR, and demo experience.

## Status

Approved

# ADR-043

Intermediate Layer Refresh Strategy

## Decision:

All INTM objects shall be recreated using:

CREATE OR REPLACE TABLE

## Reason:

- Idempotent execution
- No duplicate data
- Faster development
- Easier debugging
- Repeatable demos

Applies To:

INTM.SOURCE_SUPERSET
INTM.DQ_RESULTS
INTM.DQ_RECORD_SUMMARY
INTM.RELATIONSHIP_CANDIDATES
INTM.RELATIONSHIP_CATALOG
INTM.BR_OUTPUT
INTM.GOLDEN_PRODUCT

Exception:

SRC.*
MD.*
LOG.*
RPT.*

remain persistent and shall use:

CREATE TABLE IF NOT EXISTS

## Status

Approved

# ADR-044

## Decision 

Intra-Source Deduplication

Within a consolidated relationship group, multiple records originating from the same source system may represent the same business product.

Prior to survivorship processing, the Business Rule shall select a single surviving source record per source system.

Selection shall use:

1. Highest RECORD_DQ_SCORE.
2. Lowest SOURCE_RECORD_ID as tie-breaker.

Non-surviving records shall be excluded from master candidate generation but retained in upstream lineage tables.
## Status

Approved
