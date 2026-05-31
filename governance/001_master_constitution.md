# MASTER CONSTITUTION

## 1. Purpose

This solution is a Relationship Discovery Framework.

The Product Master Data Management (MDM) use case exists to demonstrate how discovered relationship intelligence can be operationalized into trusted Golden Records.

The primary capability is Relationship Discovery.

Golden Record creation, enrichment, and reporting are downstream consumers of discovered relationship intelligence.

---

## 2. Business Problem

Data architects spend significant effort manually identifying undocumented relationships between enterprise data sources before they can create trusted analytical models and master data entities.

Source systems frequently:

* Lack documented relationships.
* Use inconsistent identifiers.
* Use incompatible naming conventions.
* Require transformations before relationships can be established.

This process is manual, time-consuming, and difficult to scale.

The objective of this solution is to automate relationship discovery and operationalize the resulting relationship intelligence.

---

## 3. Core Objectives

### Primary Objective

Automatically discover, validate, score, and catalog trusted relationships between previously undocumented data sources.

### Secondary Objective

Use discovered relationships to create trusted Product Golden Records.

### Tertiary Objective

Enrich Product Golden Records and demonstrate business value.

---

## 4. Solution Scope

### In Scope

* Relationship Discovery
* Relationship Catalog Creation
* Product Golden Record Creation
* Product Enrichment
* Data Quality Assessment
* Traceability
* AI-Assisted Solution Generation

### Out of Scope

* Relationship Lifecycle Management
* Relationship Aging
* Relationship Drift Detection
* Human Stewardship Workflows
* Real-Time Event Processing
* Dynamic Transformation Generation
* Enterprise Governance Programs
* Multi-Domain Expansion

---

## 5. Architectural Principles

### AP-001

Modules communicate through persisted tables.

Persisted tables are the contracts between modules.

### AP-002

Stored procedures are orchestrators only.

Stored procedures must not contain significant business logic.

### AP-003

Business logic belongs in Business Rules (BR).

### AP-004

State management belongs in Data Access Layers (DAL).

### AP-005

Traceability is prioritized over minimizing object count.

---

## 6. Processing Pattern

All entity processing must follow:

STATE

↓

BR

↓

ACTION_LOG

↓

DAL

↓

NEW_STATE

This pattern is mandatory.

---

## 7. Relationship Discovery Principles

Relationship Discovery is the primary capability of the solution.

Discovery must:

* Operate pairwise across source systems.
* Evaluate full datasets.
* Discover candidate relationships.
* Apply approved transformations.
* Validate candidate relationships.
* Score candidate relationships.
* Preserve supporting evidence.
* Preserve rejected candidates.

---

## 8. Relationship Catalog Principles

RELATIONSHIP_CATALOG is a reusable enterprise asset.

The catalog must store:

* Accepted relationships.
* Rejected relationships.
* Evidence.
* Transformations used.
* Confidence scores.
* Relationship status.

The Relationship Catalog is not a temporary processing artifact.

---

## 9. Transformation Principles

Relationship Discovery must use a controlled transformation library.

Approved transformations:

### T0

Direct Match

### T1

Prefix/Suffix Removal

### T2

Left-N Character Matching

No dynamic transformation generation is permitted.

---

## 10. Source Superset Principles

SOURCE_SUPERSET is the canonical landing model.

Source-to-canonical mappings are intentionally hardcoded.

Attribute harmonization is a business modeling activity and is not part of Relationship Discovery.

---

## 11. Data Quality Principles

DQ executes only at SOURCE_SUPERSET.

DQ is metadata-driven.

DQ results must be preserved for traceability and reporting.

DQ supports relationship discovery and Golden Record creation.

---

## 12. Product Domain Principles

Product MDM is the demonstration use case.

Canonical Product Attributes:

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

Critical Attributes:

* BRAND
* PRODUCT_NAME

---

## 13. Golden Record Principles

Golden Record creation consumes:

* SOURCE_SUPERSET
* RELATIONSHIP_CATALOG

Golden Record creation is a consumer of relationship intelligence.

Golden Record creation is not the primary capability.

---

## 14. Golden Key Principles

Golden Key format:

BRAND|PRODUCT_NAME|SIZE

Golden Key generation is the responsibility of CREATE BR modules.

Golden Keys must be explainable and business-readable.

---

## 15. CREATE BR Principles

CREATE BR modules are responsible for:

* Golden Key generation.
* Duplicate prevention.
* Create eligibility determination.
* Create action generation.

CREATE BR must verify whether a Golden Key already exists in INTM before generating a CREATE action.

Duplicate creates must be marked REDUNDANT.

---

## 16. UPDATE BR Principles

UPDATE BR modules are responsible for:

* Update eligibility determination.
* Update action generation.

UPDATE BR must verify that the target Golden Key exists before generating an UPDATE action.

Invalid updates must be marked REDUNDANT.

---

## 17. ACTION_LOG Principles

ACTION_LOG is the integration contract.

BR modules write actions.

DAL modules consume actions.

ACTION_LOG stores business intent.

---

## 18. DAL Principles

DAL modules own:

* State materialization.
* Version creation.
* Soft delete processing.
* History maintenance.

DAL modules do not make business decisions.

---

## 19. INTM Principles

INTM is the system of record.

INTM stores:

* Active records.
* Historical records.
* Enrichment results.
* Lineage.
* Version history.

All business state transitions must materialize through INTM.

---

## 20. Enrichment Principles

Enrichments execute after Golden Record creation.

Enrichments:

* Read active INTM records.
* Evaluate all active records.
* Generate UPDATE actions.
* Materialize through DAL.

All enrichments must be stored in INTM.

---

## 21. FINAL Principles

FINAL entities are presentation layers.

FINAL entities consume INTM.

FINAL entities are not systems of record.

---

## 22. Survivorship Principles

Survivorship is attribute-level.

Survivorship rules are metadata-driven.

Different attributes may have different source priorities.

---

## 23. AI Generation Principles

Cortex is responsible for generating implementation artifacts.

Humans are responsible for:

* Architectural decisions.
* Prompt approvals.
* Artifact approvals.

AI generation must be governed by approved prompts and approved artifacts.

---

## 24. Prompt Governance Principles

One Prompt = One Artifact.

Every prompt must:

* Have a single objective.
* Produce a single reviewable artifact.
* Remain within scope.
* Wait for approval before proceeding.

Future-phase artifact generation is prohibited.

---

## 25. Success Criteria

Success is measured by:

* Discovery of trusted relationships from previously undocumented sources.
* Creation of a reusable Relationship Catalog.
* Creation of trusted Product Golden Records.
* Demonstration of enrichment capabilities.
* Full traceability from source data to final output.
* Demonstration of governed AI-assisted solution delivery.
