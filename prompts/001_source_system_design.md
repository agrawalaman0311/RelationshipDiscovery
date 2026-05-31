# PROMPT 001 – SOURCE SYSTEM DESIGN

## Objective

Design the source systems required for the Product Master Data Management (MDM) demonstration use case of the Relationship Discovery Framework.

## Required Context

Read and comply with:

* 001_MASTER_CONSTITUTION.md
* 002_APPROVED_DECISIONS_REGISTER.md
* 003_PROMPT_OS.md
* 004_PROJECT_CONTEXT.md
* 005_METADATA_DESIGN.md

All approved decisions are mandatory.

Do not redesign previously approved architecture.

---

## Approved Decisions

The following source systems have already been approved:

* ERP_PRODUCT
* SUPPLIER_PRODUCT
* INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT

The following canonical attributes have already been approved:

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

Relationship Discovery is the primary capability.

Product MDM is the demonstration use case.

---

## Task

Design the approved source systems.

For each source system provide:

### Purpose

Business purpose of the source.

### Business Ownership

Who owns and maintains the source.

### Attributes

List all source attributes.

### Canonical Attribute Coverage

Identify which canonical attributes are supplied by the source.

### Data Quality Characteristics

Describe expected completeness and quality characteristics.

### Relationship Discovery Opportunities

Intentionally embed opportunities for:

* Direct Match
* Prefix/Suffix Match
* Left-N Character Match
* Rejected Relationship Candidates

---

## Constraints

Do NOT generate:

* SQL
* DDL
* Synthetic Data
* Metadata Tables
* DQ Rules
* Relationship Discovery Logic
* Relationship Catalog Design
* BR Modules
* DAL Modules
* Stored Procedures
* Tasks
* Views
* Reports

Do NOT design downstream artifacts.

Only design source systems.

---

## Output Requirements

Generate a single artifact:

001_source_system_design.md

The artifact must contain:

1. Objective
2. Inputs
3. Decisions Made
4. Constraints Applied
5. Approval Status

---

## Success Criteria

The source system design must provide sufficient information to allow the next artifact:

SOURCE_SUPERSET DESIGN

to be created without making additional assumptions.
