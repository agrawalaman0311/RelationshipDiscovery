# PROMPT 003 – GENERATE RELATIONSHIP-CENTRIC SOURCE TEST DATA

## Objective

Generate executable Snowflake SQL to populate the approved source tables with synthetic data specifically designed to validate the Relationship Discovery Framework.

The generated dataset must be relationship-centric.

The purpose of the dataset is to demonstrate T0, T1, T2 and T3 relationship discovery patterns as defined in governance/006_RELATIONSHIP_DISCOVERY_RULES.md.

---

## Output Location

sql/source/003_source_test_data.sql

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

Do not redesign approved architecture.

---

## Existing Platform

Database:

RELATIONSHIP_DISCOVERY_DB

Schema:

SRC

Existing Tables:

* ERP_PRODUCT
* SUPPLIER_PRODUCT
* INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT

---

## Core Requirement

The generated data must be relationship-centric.

Do NOT generate four independent datasets.

Do NOT generate four independent PRODUCT_SEED populations.

There shall be exactly one PRODUCT_SEED population.

The PRODUCT_SEED population must be materialized once and reused by all source systems.

---

## Shared Product Population

Create:

PRODUCT_SEED

The PRODUCT_SEED population represents the enterprise product universe.

Recommended attributes:

* PRODUCT_SEED_ID
* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SIZE
* BASE_PRICE
* RELATIONSHIP_TYPE

PRODUCT_SEED must contain exactly:

10,000 logical products.

---

## Relationship Distribution

Populate PRODUCT_SEED according to:

| Relationship Type | Distribution |
| ----------------- | ------------ |
| T0                | 40%          |
| T1                | 30%          |
| T2                | 20%          |
| T3                | 10%          |

Relationship types must comply with:

governance/006_RELATIONSHIP_DISCOVERY_RULES.md

The distribution must be deterministic.

Do not rely on random chance.

---

## Source Derivation Strategy

All source systems must be generated from PRODUCT_SEED.

### ERP_PRODUCT

Generate the cleanest representation.

Characteristics:

* Standardized Brand
* Standardized Product Name
* Standardized Manufacturer
* Standardized Size

ERP is the highest quality source.

---

### SUPPLIER_PRODUCT

Derive from PRODUCT_SEED.

Apply transformations based on RELATIONSHIP_TYPE.

Examples:

T0

Exact values

T1

Prefix/Suffix variations

Examples:

* Premium Acme Widget
* Acme Widget 500ML

T2

Abbreviations

Examples:

* ACM
* NEX

T3

Intentional mismatch values

---

### INVENTORY_PRODUCT

Derive from PRODUCT_SEED.

Apply:

* Brand codes
* Abbreviated product names
* Condensed size formats

according to RELATIONSHIP_TYPE.

---

### ECOMMERCE_PRODUCT

Derive from PRODUCT_SEED.

Apply:

* SEO titles
* Marketing names
* Verbose size descriptions

according to RELATIONSHIP_TYPE.

---

## Source Volumes

Generate:

ERP_PRODUCT

10,250 rows

SUPPLIER_PRODUCT

10,800 rows

INVENTORY_PRODUCT

10,450 rows

ECOMMERCE_PRODUCT

10,950 rows

---

## Additional Source Records

After generating records derived from PRODUCT_SEED, generate source-specific records to achieve target row counts.

Examples:

ERP-only products

Supplier-only products

Inventory-only products

Ecommerce-only products

These records must not belong to PRODUCT_SEED.

Purpose:

Demonstrate:

* Orphan Records
* Unmatched Records
* Source-Specific Records

---

## Data Quality Characteristics

Intentionally generate:

### Missing Values

For non-critical attributes only.

### Case Variations

Examples:

* ACME
* Acme
* acme

### Abbreviations

Examples:

* Procter & Gamble
* P&G

### Formatting Variations

Examples:

* 500ML
* 500 ML
* 0.5L

---

## Data Generation Requirements

Use Snowflake-native generation.

Preferred:

* TABLE(GENERATOR())
* SEQ4()
* RANDOM()
* UNIFORM()
* ARRAY_CONSTRUCT()
* CASE

Do not generate thousands of hardcoded INSERT statements.

Generate scalable SQL.

---

## Data Integrity Requirements

* No duplicate source identifiers
* Valid LOAD_DTTM values
* One shared PRODUCT_SEED population
* All relationship records derived from PRODUCT_SEED
* Source-specific records generated separately

---

## Constraints

Do NOT generate:

* Metadata Tables
* SOURCE_SUPERSET
* DQ Logic
* Relationship Discovery Procedures
* Relationship Catalog Tables
* BR Modules
* DAL Modules
* Tasks
* Views
* Reports

Generate source test data only.

---

## Output Requirements

Output executable Snowflake SQL only.

Do not include:

* Markdown
* Documentation
* Explanations
* Design Notes
* Alternative Approaches

---

## Validation Requirements

The generated dataset must allow a future Relationship Discovery process to identify:

* T0 Exact Match relationships
* T1 Prefix/Suffix relationships
* T2 Left-N relationships
* T3 Rejected candidates

The same logical product must be traceable across multiple source systems.

---

## Success Criteria

Execution of the generated SQL should create a relationship-centric dataset suitable for demonstrating the Relationship Discovery Framework.

The next artifact will be:

sql/metadata/004_metadata_tables.sql
