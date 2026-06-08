PROMPT 017 – STREAMLIT DASHBOARD IMPLEMENTATION

Objective

Generate a production-quality Snowflake Streamlit dashboard that provides a complete business, technical and governance view of the Relationship Discovery and Master Data Management platform.

The dashboard shall demonstrate:

* Relationship Discovery
* Relationship Cataloging
* Data Quality
* Golden Record Creation
* Metadata Governance
* Security Governance
* Auditability
* Architecture Transparency
* Interactive Record-Level Exploration

The dashboard shall support:

* Hackathon Demonstrations
* Executive Walkthroughs
* Architecture Reviews
* MDM Capability Assessments

---

Output

Generate:

relationship_discovery_framework/streamlit_app.py

Generate only the complete executable Streamlit application.

---

Governance Inputs

Read and comply with:

* governance/001_MASTER_CONSTITUTION.md
* governance/002_APPROVED_DECISIONS_REGISTER.md
* governance/003_PROMPT_OS.md
* governance/004_PROJECT_CONTEXT.md
* governance/005_METADATA_DESIGN.md
* governance/006_SECURITY_ARCHITECTURE.md

All approved decisions are mandatory.

---

Business Context

The platform resolves fragmented product records across:

* ERP_PRODUCT (10,250 records, 35 distinct brands)
* SUPPLIER_PRODUCT (10,800 records, 33 distinct brands)
* INVENTORY_PRODUCT (10,450 records, 53 distinct brands)
* ECOMMERCE_PRODUCT (10,950 records, 33 distinct brands)

into governed golden records.

The dashboard is the primary business-facing interface for the platform.

The dashboard must visually explain:

Source Records (42,450)
↓
Relationship Discovery (21,797,578 candidates)
↓
Relationship Cataloging (30,000 best matches)
↓
Mastering (5,567 golden records)
↓
Governance (metadata-driven)
↓
Security (RBAC + masking)
↓
Golden Records (86.9% deduplication)

---

Database

RELATIONSHIP_DISCOVERY_DB

---

Source Tables — Schema & Column Inventory

RELATIONSHIP_DISCOVERY_DB.INTM.SOURCE_SUPERSET

Purpose:

Canonical harmonized source layer.

Columns:

* SOURCE_SUPERSET_ID (NUMBER)
* SOURCE_SYSTEM (VARCHAR)
* SOURCE_RECORD_ID (VARCHAR)
* BRAND (VARCHAR)
* PRODUCT_NAME (VARCHAR)
* CATEGORY (VARCHAR)
* MANUFACTURER (VARCHAR)
* SALE_PRICE (NUMBER)
* SIZE (VARCHAR)
* LOAD_DTTM (TIMESTAMP)
* CREATED_DTTM (TIMESTAMP)

Records:

42,450

---

RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CANDIDATES

Purpose:

Stores all discovered candidate matches via pairwise comparison and blocking.

Columns:

* RELATIONSHIP_ID (NUMBER)
* LEFT_SOURCE_SYSTEM (VARCHAR)
* LEFT_SOURCE_RECORD_ID (VARCHAR)
* RIGHT_SOURCE_SYSTEM (VARCHAR)
* RIGHT_SOURCE_RECORD_ID (VARCHAR)
* MATCH_TYPE (VARCHAR)
* MATCH_SCORE (NUMBER)
* MATCH_CONFIDENCE (VARCHAR)
* DQ_WEIGHTED_SCORE (NUMBER)
* CREATED_DTTM (TIMESTAMP)

Records:

21,797,578

Distribution:

* T0 HIGH: 1,779,560
* T1 MEDIUM: 10,552,796
* T2 LOW: 9,465,222

---

RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CATALOG

Purpose:

Stores best-match relationships after ranking.

Columns:

* CATALOG_RELATIONSHIP_ID (NUMBER)
* LEFT_SOURCE_SYSTEM (VARCHAR)
* LEFT_SOURCE_RECORD_ID (VARCHAR)
* RIGHT_SOURCE_SYSTEM (VARCHAR)
* RIGHT_SOURCE_RECORD_ID (VARCHAR)
* MATCH_TYPE (VARCHAR)
* MATCH_SCORE (NUMBER)
* MATCH_CONFIDENCE (VARCHAR)
* DQ_WEIGHTED_SCORE (NUMBER)
* MATCH_PRIORITY (NUMBER)
* IS_BEST_MATCH (VARCHAR)
* CREATED_DTTM (TIMESTAMP)

Records:

30,000

Distribution By System Pair:

* INVENTORY → SUPPLIER: 10,000
* ERP → INVENTORY: 6,002
* ECOMMERCE → INVENTORY: 5,332
* ERP → SUPPLIER: 3,998
* ECOMMERCE → ERP: 3,668
* ECOMMERCE → SUPPLIER: 1,000

---

RELATIONSHIP_DISCOVERY_DB.INTM.DQ_RECORD_SUMMARY

Purpose:

Stores record-level DQ scores computed using metadata-driven rules.

Columns:

* SOURCE_SYSTEM (VARCHAR)
* SOURCE_RECORD_ID (VARCHAR)
* TOTAL_ATTRIBUTES (NUMBER)
* PASSED_ATTRIBUTES (NUMBER)
* FAILED_ATTRIBUTES (NUMBER)
* RECORD_DQ_SCORE (NUMBER)
* RECORD_DQ_STATUS (VARCHAR)
* CREATED_DTTM (TIMESTAMP)

Records:

42,450

Distribution:

* ECOMMERCE: 10,783 PASS, 167 WARNING
* ERP: 10,150 PASS, 100 WARNING
* INVENTORY: 10,450 PASS
* SUPPLIER: 10,633 PASS, 167 WARNING

---

RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER

Purpose:

Stores versioned mastered history and serves as system of record.

Columns:

* ENTITY_KEY (VARCHAR)
* VERSION_NO (NUMBER)
* ACTIVE_FLAG (VARCHAR)
* ACTION_SOURCE (VARCHAR)
* BRAND
* PRODUCT_NAME
* CATEGORY
* MANUFACTURER
* SALE_PRICE
* SIZE
* DERIVED_PRODUCT_FAMILY
* DERIVED_PRODUCT_GROUP
* DERIVED_PRODUCT_STATUS
* ERP_PRODUCT_ID
* SUPPLIER_PRODUCT_ID
* INVENTORY_PRODUCT_ID
* ECOMMERCE_PRODUCT_ID
* CREATED_DTTM
* UPDATED_DTTM

Records:

22,268

Version Pattern:

* V1 – P10_MASTER_CREATION
* V2 – P12_PRODUCT_FAMILY
* V3 – P13_PRODUCT_GROUP
* V4 – P14_PRODUCT_STATUS

---

RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER

Purpose:

Stores active golden records.

Columns:

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
* DERIVED_PRODUCT_FAMILY
* DERIVED_PRODUCT_GROUP
* DERIVED_PRODUCT_STATUS
* SOURCE_EXECUTION_REFERENCE
* ACTION_SOURCE
* VERSION_NO
* CREATED_DTTM
* UPDATED_DTTM

Records:

5,567

Source Coverage:

* ERP_PRODUCT_ID: 130 (2.3%)
* SUPPLIER_PRODUCT_ID: 227 (4.1%)
* INVENTORY_PRODUCT_ID: 3,238 (58.2%)
* ECOMMERCE_PRODUCT_ID: 1,976 (35.5%)

---

RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG

Purpose:

Stores CREATE and UPDATE actions with full audit trail.

Records:

22,268

Distribution:

* CREATE + COMPLETED: 5,567
* UPDATE + P12_PRODUCT_FAMILY: 5,567
* UPDATE + P13_PRODUCT_GROUP: 5,567
* UPDATE + P14_PRODUCT_STATUS: 5,567

---

Metadata Tables

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_DQ_RULES

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_SURVIVORSHIP

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_MAPPING

Purpose:

Stores governance metadata used by the platform.

---

Technical Standards

Use:

from snowflake.snowpark.context import get_active_session

session = get_active_session()

Use:

@st.cache_data(ttl=600)

for all query functions.

All SQL must use fully-qualified table names.

Use Snowflake Streamlit compatible code only.

No comments in generated code.

---

Visualization Standards

Use:

* Streamlit Native Components
* Altair

Do not use:

* Plotly
* Matplotlib
* Seaborn

---

Styling Requirements

Apply custom CSS using:

st.markdown(..., unsafe_allow_html=True)

Requirements:

* Gradient metric cards
* Hover lift effects
* Pill-style tab navigation
* Gradient hero title
* Callout boxes
* Section dividers
* Modern typography

Color Palette:

* Indigo: #4f46e5
* Violet: #7c3aed
* Emerald: #10b981
* Amber: #f59e0b
* Rose: #f43f5e
* Sky: #0ea5e9

---

Dashboard Structure

Implement exactly six tabs:

1. The Story
2. Live Explorer
3. Discovery Engine
4. Data Quality
5. Golden Master
6. Architecture

---

Tab 1 – The Story

Purpose

Provide an executive narrative explaining the business value of the platform.

Requirements

1. Display a problem statement callout explaining fragmented product data across disconnected systems.

2. Display a relationship discovery pipeline:

42,450 Source Records

↓

21,797,578 Candidate Pairs

↓

30,000 Cataloged Relationships

↓

5,567 Golden Records

↓

86.9% Deduplication

3. Display a consolidation funnel using Altair.

4. Display source system distribution.

5. Display three differentiators:

* Multi-Tier Matching
* DQ-Weighted Discovery
* Metadata-Driven Governance

6. Display KPI row:

* Consolidation Ratio
* Deduplication %
* Precision Filter %
* DQ Pass Rate
* Versions Tracked

---

Tab 2 – Live Explorer

Purpose

Primary hackathon demonstration tab.

Implement:

st.radio(horizontal=True)

Modes:

1. Before / After — Source vs Golden
2. Entity Deep Dive
3. Relationship Lookup

---

Mode 1 – Before / After

Requirements

* Select Golden Record
* Retrieve linked source records
* Display raw source differences
* Display resolved golden record
* Highlight attribute conflicts
* Explain survivorship decisions
* Explain ERP priority rules

---

Mode 2 – Entity Deep Dive

Requirements

* Select Entity
* Display version timeline
* Display version history
* Display active version
* Display processing lineage
* Display auditability metrics

---

Mode 3 – Relationship Lookup

Requirements

* Select Source System
* Select Source Record
* Display discovered relationships
* Display match scores
* Display confidence
* Display DQ weighted scores
* Handle no results gracefully

---

Tab 3 – Discovery Engine

Purpose

Demonstrate relationship discovery innovation.

Requirements

1. Narrative callout explaining blocking strategy and multi-tier matching.

2. KPI row:

* Candidates Generated
* Cataloged Relationships
* Reduction %
* Average DQ Score

3. Match Tier Analysis:

* T0 – Exact Match
* T1 – Fuzzy Match
* T2 – Prefix Match

Include confidence level distribution.

4. Relationship Density Heatmap

Display cross-system relationship counts.

5. Selectivity Analysis

Compare:

Candidates

vs

Cataloged

for each matching tier.
