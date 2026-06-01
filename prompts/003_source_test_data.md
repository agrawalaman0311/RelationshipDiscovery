# PROMPT 003 – GENERATE SOURCE TEST DATA

## Objective

Generate Snowflake SQL to populate the approved source tables with synthetic data required to demonstrate the Relationship Discovery Framework.

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

## Task

Generate executable Snowflake SQL to populate:

* RELATIONSHIP_DISCOVERY_DB.SRC.ERP_PRODUCT
* RELATIONSHIP_DISCOVERY_DB.SRC.SUPPLIER_PRODUCT
* RELATIONSHIP_DISCOVERY_DB.SRC.INVENTORY_PRODUCT
* RELATIONSHIP_DISCOVERY_DB.SRC.ECOMMERCE_PRODUCT

with synthetic test data.

---

## Data Volume Requirements

Generate between 10,000 and 11,000 rows for each source table.

Approved target volumes:

* ERP_PRODUCT: 10,250 rows
* SUPPLIER_PRODUCT: 10,800 rows
* INVENTORY_PRODUCT: 10,450 rows
* ECOMMERCE_PRODUCT: 10,950 rows

Requirements:

* Minimum 10,000 rows per source
* Maximum 11,000 rows per source
* No source may fall outside the approved range

---

## Data Generation Requirements

Use Snowflake-native generation techniques.

Preferred techniques:

* TABLE(GENERATOR())
* SEQ4()
* RANDOM()
* UNIFORM()
* ARRAY_CONSTRUCT()
* CASE expressions

Do NOT generate thousands of hardcoded INSERT statements.

Generate scalable SQL.

---

## Canonical Attribute Coverage

Generated data must support the approved canonical attributes:

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

---

## Relationship Discovery Test Coverage

The generated data must intentionally create relationship discovery opportunities.

### T0 Direct Match

Target distribution:

40%

Examples:

* Exact Brand Matches
* Exact Product Name Matches
* Exact Size Matches

---

### T1 Prefix/Suffix Match

Target distribution:

30%

Examples:

* Acme Widget
* Acme Widget 500ML
* Premium Acme Widget
* Acme Widget Large

---

### T2 Left-N Character Match

Target distribution:

20%

Examples:

* ACM
* ACME
* ACME_CORP

---

### Rejected Candidates

Target distribution:

10%

Examples:

* Similar product names
* Different brands
* Similar categories
* Similar prices
* Similar manufacturers

These records must intentionally fail relationship matching.

---

## Source-Specific Characteristics

### ERP_PRODUCT

Generate:

* Clean brand names
* Standard product names
* Standardized sizes
* Standardized manufacturers

This should be the highest quality source.

---

### SUPPLIER_PRODUCT

Generate:

* Brand prefixes
* Manufacturer abbreviations
* Alternative size formatting
* Supplier-specific naming conventions

---

### INVENTORY_PRODUCT

Generate:

* Brand codes
* Abbreviated product names
* Warehouse-oriented categories
* Condensed size values

---

### ECOMMERCE_PRODUCT

Generate:

* SEO-optimized product titles
* Marketing-friendly brand names
* Verbose size descriptions
* Customer-facing product descriptions

---

## Data Quality Characteristics

Intentionally generate:

### Missing Values

For selected non-critical attributes.

### Formatting Variations

For:

* Size
* Manufacturer
* Product Name

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

## Data Integrity Requirements

* No duplicate source identifiers
* Every row must have a valid source identifier
* Every table must contain valid LOAD_DTTM values
* Data must be reproducible
* Data must be suitable for relationship discovery testing

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
* Explanations
* Documentation
* Design Notes
* Alternative Approaches

---

## Success Criteria

Execution of the generated SQL should populate all four source tables with realistic test data supporting:

* Direct Match Discovery
* Prefix/Suffix Discovery
* Left-N Discovery
* Rejected Candidate Validation

The next artifact will be:

sql/metadata/004_metadata_tables.sql
