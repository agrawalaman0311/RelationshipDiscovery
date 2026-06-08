Create a complete production-ready Snowflake Streamlit application for my Master Data Management (MDM) project.

Technology Requirements

* Snowflake Streamlit
* Snowpark Python
* Plotly for visualizations
* st.metric for KPI cards
* st.tabs for navigation
* st.dataframe for tabular displays
* Use Snowflake session object
* Use reusable query functions
* Use caching where appropriate
* Include loading indicators
* Include error handling
* Generate a single runnable Python application
* Generate production-ready code

Output Requirements

Generate only the complete Python Streamlit application.

Do not provide explanations.

Do not provide pseudocode.

Do not provide partial code.

Generate complete executable code.

---

Database

RELATIONSHIP_DISCOVERY_DB

---

Tables Available

MDM Tables

RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG

RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER

RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER

Metadata Tables

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_DQ_RULES

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_SURVIVORSHIP

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_MAPPING

---

Application Title

Enterprise Product Master Data Quality & Governance Dashboard

---

Create 5 Tabs

1. Executive Summary

2. Data Quality

3. MDM Processing

4. Lineage & Audit

5. Metadata & Governance

---

TAB 1 – Executive Summary

Purpose

Provide an executive overview of the MDM solution.

Data Source

RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER

Display KPI Cards

* Total Products
* Product Families
* Product Groups
* Product Statuses

Additional KPI Cards

* Active DQ Rules
* Active Survivorship Rules
* Active Attribute Mappings

Queries

Count records from:

MD.MD_ATTRIBUTE_DQ_RULES
MD.MD_ATTRIBUTE_SURVIVORSHIP
MD.MD_ATTRIBUTE_MAPPING

Visualizations

1. Product Family Distribution

Use:

DERIVED_PRODUCT_FAMILY

2. Product Group Distribution

Use:

DERIVED_PRODUCT_GROUP

3. Product Status Distribution

Use:

DERIVED_PRODUCT_STATUS

Use interactive Plotly charts.

---

TAB 2 – Data Quality

Purpose

Measure data quality and completeness of mastered data.

Data Source

RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER

Calculate Completeness %

For:

* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE

Formula

(Populated Records / Total Records) * 100

Display

* Data Quality Score
* Attribute Completeness Table
* Missing Value Counts
* Horizontal Completeness Chart

Display overall DQ Score.

Overall DQ Score Formula

Average of all attribute completeness percentages.

Highlight critical attributes:

BRAND
PRODUCT_NAME
SIZE

These are defined in:

MD.MD_ATTRIBUTE_DQ_RULES

---

TAB 3 – MDM Processing

Purpose

Monitor MDM execution and action processing.

Data Source

RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG

KPI Cards

* Total Actions
* CREATE Actions
* UPDATE Actions
* DELETE Actions

Status Metrics

* COMPLETED
* FAILED
* SKIPPED
* PENDING

Visualizations

1. Actions By Status

ACTION_STATUS

2. Actions By Type

ACTION_TYPE

3. Actions By Source

ACTION_SOURCE

Display interactive charts.

Display action summary tables.

---

TAB 4 – Lineage & Audit

Purpose

Demonstrate versioning, lineage and auditability.

Data Source

RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER

Create an ENTITY_KEY selector.

When selected display:

* ENTITY_KEY
* VERSION_NO
* ACTION_SOURCE
* ACTIVE_FLAG
* CREATED_DTTM
* UPDATED_DTTM

Display:

1. Version History Table

2. Version Timeline

3. Version Count

Order by:

VERSION_NO

Ascending.

Show lineage created by:

P10_MASTER_CREATION

P12_PRODUCT_FAMILY

P13_PRODUCT_GROUP

P14_PRODUCT_STATUS

This tab should clearly demonstrate version evolution.

---

TAB 5 – Metadata & Governance

Purpose

Demonstrate governance, DQ framework and survivorship configuration.

---

Section 1 – DQ Rules

Source

MD.MD_ATTRIBUTE_DQ_RULES

Display:

* Total Active Rules
* Critical Attributes
* DQ Rules Table

Visualizations

DQ Rules By Type

Critical vs Non-Critical Attributes

---

Section 2 – Survivorship Rules

Source

MD.MD_ATTRIBUTE_SURVIVORSHIP

Display:

* Survivorship Rules Table
* Attribute Priority Matrix

Visualizations

Source System Priority Distribution

Show priority order by attribute.

Example

BRAND

ERP_PRODUCT → 1
SUPPLIER_PRODUCT → 2
ECOMMERCE_PRODUCT → 3
INVENTORY_PRODUCT → 4

---

Section 3 – Attribute Mapping

Source

MD.MD_ATTRIBUTE_MAPPING

Display:

* Mapping Table

Visualizations

Canonical Attribute Coverage

Show mappings by:

* Canonical Attribute
* Source System

Example

BRAND

ERP_PRODUCT → BRAND_NAME

SUPPLIER_PRODUCT → BRAND

INVENTORY_PRODUCT → BRAND_CODE

ECOMMERCE_PRODUCT → VENDOR_NAME

---

Design Requirements

Use:

* Clean modern enterprise styling
* Responsive layout
* Plotly interactive charts
* Wide page layout
* Professional color palette
* Section headers
* Helpful descriptions
* Expanders where appropriate

---

Error Handling

Handle:

* Empty tables
* Missing records
* Failed queries

Display user-friendly messages.

---

Performance

Use cached query functions.

Avoid repeated database queries.

Reuse loaded datasets where possible.

---

Success Criteria

The application should clearly demonstrate:

1. Master Data Quality
2. MDM Processing
3. Versioning
4. Lineage
5. Governance
6. Survivorship Rules
7. Attribute Mapping
8. Business Rule Execution
9. Action Processing
10. Final Published Master Data

Generate complete runnable Snowflake Streamlit Python code.
