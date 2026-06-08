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

The dashboard shall support:

* Hackathon Demonstrations
* Executive Walkthroughs
* Architecture Reviews
* MDM Capability Assessments

---

Output

Generate:

app/streamlit_app.py

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

* ERP_PRODUCT
* SUPPLIER_PRODUCT
* INVENTORY_PRODUCT
* ECOMMERCE_PRODUCT

into governed golden records.

The dashboard is the primary business-facing interface for the platform.

The dashboard must explain:

Source Records
↓
Relationship Discovery
↓
Relationship Cataloging
↓
Mastering
↓
Governance
↓
Security
↓
Golden Records

---

Database

RELATIONSHIP_DISCOVERY_DB

---

Source Tables

RELATIONSHIP_DISCOVERY_DB.INTM.SOURCE_SUPERSET

Purpose:

Canonical harmonized source layer.

RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CANDIDATES

Purpose:

Stores all discovered candidate matches.

RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CATALOG

Purpose:

Stores best-match relationships.

RELATIONSHIP_DISCOVERY_DB.INTM.DQ_RECORD_SUMMARY

Purpose:

Stores record-level DQ scores.

RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER

Purpose:

Stores versioned master history.

RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER

Purpose:

Stores active golden records.

RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG

Purpose:

Stores CREATE and UPDATE actions.

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

Executive narrative explaining the business value of the platform.

Requirements

Display:

* Problem Statement
* Relationship Discovery Pipeline
* Consolidation Funnel
* Source System Distribution
* Platform Differentiators
* Executive KPI Row

Relationship Discovery Pipeline

Display:

42,450 Source Records

↓

21,797,578 Candidate Pairs

↓

30,000 Cataloged Relationships

↓

5,567 Golden Records

↓

86.9% Deduplication
