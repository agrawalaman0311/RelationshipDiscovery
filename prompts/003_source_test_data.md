# PROMPT 003 – GENERATE RELATIONSHIP-CENTRIC SOURCE TEST DATA

## Objective

Generate Snowflake SQL to populate the approved source tables with synthetic data specifically designed to demonstrate the Relationship Discovery Framework.

The generated data must be relationship-centric, not source-centric.

---

## Output Location

sql/source/003_source_test_data.sql

Generate the contents of this file.

Do not generate any other files.

---

## Governance Inputs

Read and comply with:

* governance/001_MASTER_CONSTITUTION.md
* governance/002_APPROVED_DECISIONS_REGISTER.md
* governance/003_PROMPT_OS.md
* governance/004_PROJECT_CONTEXT.md
* governance/005_METADATA_DESIGN.md

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

The generated data must support Relationship Discovery.

Do NOT generate four independent datasets.

Generate a common logical product population first and derive all source systems from that population.

---

## Relationship Population Strategy

Create a shared logical product population.

Example structure:

PRODUCT_SEED

* PRODUCT_SEED_ID
* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SIZE

The PRODUCT_SEED population represents the enterprise product universe.

All source systems must be derived from PRODUCT_SEED.

---

## Source Derivation Rules

### ERP_PRODUCT

Generate the cleanest representation.

Characteristics:

* Standardized Brand
* Standardized Product Name
* Standardized Manufacturer
* Standardized Size

Highest quality source.

---

### SUPPLIER_PRODUCT

Generate records from PRODUCT_SEED.

Apply:

* Brand prefixes
* Manufacturer abbreviations
* Alternative size formatting
* Supplier naming conventions

---

### INVENTORY_PRODUCT

Generate records from PRODUCT_SEED.

Apply:

* Brand codes
* Abbreviated product names
* Condensed size formats
* Warehouse categories

---

### ECOMMERCE_PRODUCT

Generate records from PRODUCT_SEED.

Apply:

* SEO product titles
* Marketing-friendly brand names
* Verbose size descriptions
* Customer-facing naming conventions

---

## Data Volume Requirements

Generate between 10,000 and 11,000 rows per source.

Approved targets:

* ERP_PRODUCT = 10,250
* SUPPLIER_PRODUCT = 10,800
* INVENTORY_PRODUCT = 10,450
* ECOMMERCE_PRODUCT = 10,950

Requirements:

* Minimum 10,000 rows per source
* Maximum 11,000 rows per source

---

## Relationship Distribution Requirements

The PRODUCT_SEED population must intentionally produce:

### Direct Match Relationships

40%

Examples:

* Exact Brand Match
* Exact Product Name Match
* Exact Size Match

---

### Prefix/Suffix Relationships

30%

Examples:

ERP:
Acme Widget

Supplier:
Premium Acme Widget 500ML

---

### Left-N Relationships

20%

Examples:

ERP:
ACME

Inventory:
ACM

ERP:
NEXUS

Inventory:
NEX

---

### Rejected Candidates

10%

Examples:

* Similar names
* Different brands
* Similar categories
* Similar prices
* Similar manufacturers

These records must intentionally fail matching.

Relationships must be intentionally created.

Do not rely on randomness.

---

## Data Quality Characteristics

Intentionally generate:

### Missing Values

Only for non-critical attributes.

### Formatting Variations

* Manufacturer
* Product Name
* Size

### Case Variations

Examples:

* ACME
* Acme
* acme

### Abbreviations

Examples:

* Procter & Gamble
* P&G

---

## Data Generation Requirements

Use Snowflake-native generation techniques.

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
* Reproducible generation logic
* Consistent derivation from PRODUCT_SEED

---

## Constraints

Do NOT generate:

* Metadata tables
* SOURCE_SUPERSET
* DQ logic
* Relationship Discovery procedures
* Relationship Catalog tables
* BR modules
* DAL modules
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

The generated data must allow a future Relationship Discovery process to identify:

* Direct Matches
* Prefix/Suffix Matches
* Left-N Matches

using the generated source data.

Rejected candidates must also be present.

The same logical product must be traceable across multiple source systems.

---

## Success Criteria

Execution of the generated SQL should populate all four source tables with relationship-centric test data suitable for demonstrating the Relationship Discovery Framework.

The next artifact will be:

sql/metadata/004_metadata_tables.sql
